import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_text_styles.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import '../utils/date_utils.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      context.read<UserProvider>().loadUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppDateUtils.fullDateString(now)} ${AppDateUtils.weekdayName(now.weekday)}',
              style: AppTextStyles.h2,
            ),
          ],
        ),
        actions: [
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

          final pending = taskProvider.pendingTasks;
          final completed = taskProvider.completedTasks;

          if (pending.isEmpty && completed.isEmpty) {
            return const EmptyState(
              icon: Icons.task_alt,
              title: '还没有任务',
              subtitle: '点击右下角按钮添加新任务',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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

    final checkIn = await taskProvider.checkIn(taskId);
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('打卡成功! ${userProvider.levelIcon}'),
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
