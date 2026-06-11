import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_text_styles.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/calendar_widget.dart';
import '../utils/date_utils.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedDate = AppDateUtils.todayString();
  bool _showCalendar = false;
  int? _lastRank;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      final userProvider = context.read<UserProvider>();
      userProvider.loadUserStats().then((_) {
        _lastRank = userProvider.rank;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = _selectedDate == AppDateUtils.todayString();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isToday
                  ? '${AppDateUtils.fullDateString(now)} ${AppDateUtils.weekdayName(now.weekday)}'
                  : _selectedDate,
              style: AppTextStyles.h2,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.calendar_today : Icons.calendar_month_outlined),
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 根据选择的日期获取任务
          final dayTasks = isToday
              ? taskProvider.todayTasks
              : taskProvider.getTasksByDate(_selectedDate);
          final pending = dayTasks.where((t) => !taskProvider.isTaskCheckedIn(t.id!)).toList();
          final completed = dayTasks.where((t) => taskProvider.isTaskCheckedIn(t.id!)).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 日历视图
              if (_showCalendar) ...[
                CalendarWidget(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  checkinDates: {}, // TODO: 从数据库加载打卡日期
                ),
                const SizedBox(height: 16),
              ],

              // 补签提示（如果不是今天）
              if (!isToday) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '查看历史日期的任务，可进行补签',
                            style: AppTextStyles.caption,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = AppDateUtils.todayString();
                            });
                          },
                          child: const Text('回到今天'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // 空状态
              if (pending.isEmpty && completed.isEmpty)
                const EmptyState(
                  icon: Icons.task_alt,
                  title: '还没有任务',
                  subtitle: '点击右下角按钮添加新任务',
                ),

              // Pending count header
              if (pending.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${pending.length}个任务待完成',
                    style: AppTextStyles.body.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),

              // Pending tasks
              ...pending.map((task) => TaskCard(
                    task: task,
                    isCheckedIn: false,
                    onCheckIn: () => _handleCheckIn(context, task.id!),
                    onTap: () => _editTask(context, task),
                    onDelete: () => _deleteTask(context, task.id!),
                  )),

              // Completed section
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '已完成 (${completed.length})',
                    style: AppTextStyles.body.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                ...completed.map((task) => TaskCard(
                      task: task,
                      isCheckedIn: true,
                      onCheckIn: () {},
                      onTap: () => _editTask(context, task),
                      onDelete: () => _deleteTask(context, task.id!),
                    )),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleCheckIn(BuildContext context, int taskId) async {
    final taskProvider = context.read<TaskProvider>();
    final userProvider = context.read<UserProvider>();

    // 根据选择的日期决定是正常打卡还是补签
    final isToday = _selectedDate == AppDateUtils.todayString();
    final checkIn = isToday
        ? await taskProvider.checkIn(taskId)
        : await taskProvider.makeupCheckIn(taskId, _selectedDate);

    if (checkIn != null) {
      await userProvider.onCheckIn();

      if (!mounted) return;

      // Check for level up
      final oldLevel = userProvider.stats?.level ?? 1;
      await userProvider.loadUserStats();
      final newLevel = userProvider.stats?.level ?? 1;
      if (newLevel > oldLevel) {
        _showLevelUpDialog(context, userProvider);
      }

      // Check for rank up
      final oldRank = _lastRank ?? 1;
      final newRank = userProvider.rank;
      if (newRank > oldRank) {
        _showRankUpDialog(context, userProvider);
      }
      _lastRank = newRank;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isToday ? '打卡成功! ${userProvider.levelIcon}' : '补签成功! ${userProvider.levelIcon}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showLevelUpDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(userProvider.levelIcon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('恭喜升级!', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              '${userProvider.levelName} Lv.${userProvider.level}',
              style: AppTextStyles.h2.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('太棒了!'),
          ),
        ],
      ),
    );
  }

  void _showRankUpDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(userProvider.rankIcon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('段位提升!', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              userProvider.rankName,
              style: AppTextStyles.h2.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '连续打卡 ${userProvider.currentStreak} 天',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续努力!'),
          ),
        ],
      ),
    );
  }

  void _addTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
  }

  void _editTask(BuildContext context, task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  Future<void> _deleteTask(BuildContext context, int taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除任务'),
        content: const Text('确定要删除这个任务吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<TaskProvider>().deleteTask(taskId);
    }
  }
}
