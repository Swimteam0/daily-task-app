import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_text_styles.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/date_utils.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  int _taskType = 1;
  DateTime? _taskDate;
  TimeOfDay? _remindTime;
  bool _remindEnabled = false;
  final Set<int> _repeatDays = {};

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    if (isEditing) {
      _taskType = widget.task!.taskType;
      _remindEnabled = widget.task!.remindEnabled;
      if (widget.task!.taskDate != null) {
        _taskDate = DateTime.tryParse(widget.task!.taskDate!);
      }
      if (widget.task!.remindTime != null) {
        final parts = widget.task!.remindTime!.split(':');
        _remindTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      if (widget.task!.repeatDays != null) {
        _repeatDays.addAll(
          widget.task!.repeatDays!.split(',').map(int.parse),
        );
      }
    } else {
      // 新建单日任务时默认选择今天
      if (_taskType == 2) {
        _taskDate = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑任务' : '添加任务'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: '任务名称',
                hintText: '例如：阅读30分钟',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入任务名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              style: AppTextStyles.body,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '任务描述（可选）',
                hintText: '添加更多细节...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Task type
            Text('任务类型', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('每日重复')),
                ButtonSegment(value: 2, label: Text('单日任务')),
              ],
              selected: {_taskType},
              onSelectionChanged: (values) {
                setState(() {
                  _taskType = values.first;
                  if (_taskType == 2) {
                    _repeatDays.clear();
                    _remindEnabled = false;
                    _taskDate ??= DateTime.now();
                  }
                });
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Task date (only for single-day tasks)
            if (_taskType == 2) ...[
              Text('任务日期', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _taskDate != null
                            ? '${_taskDate!.year}-${_taskDate!.month.toString().padLeft(2, '0')}-${_taskDate!.day.toString().padLeft(2, '0')}'
                            : '选择日期',
                        style: AppTextStyles.body,
                      ),
                      const Spacer(),
                      if (_taskDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _taskDate = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Repeat days (only for recurring tasks)
            if (_taskType == 1) ...[
              Text('重复日', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final names = ['一', '二', '三', '四', '五', '六', '日'];
                  final selected = _repeatDays.contains(day);
                  return FilterChip(
                    label: Text('周${names[index]}'),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _repeatDays.add(day);
                        } else {
                          _repeatDays.remove(day);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              if (_repeatDays.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '不选择则每天重复',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],

            // Remind time
            if (_taskType == 1) ...[
              SwitchListTile(
                title: const Text('开启提醒', style: AppTextStyles.h3),
                subtitle: Text(
                  _remindEnabled && _remindTime != null
                      ? '提醒时间: ${_remindTime!.hour.toString().padLeft(2, '0')}:${_remindTime!.minute.toString().padLeft(2, '0')}'
                      : '设置提醒时间',
                  style: AppTextStyles.caption,
                ),
                value: _remindEnabled,
                onChanged: (value) {
                  setState(() {
                    _remindEnabled = value;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              if (_remindEnabled) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _remindTime != null
                          ? '${_remindTime!.hour.toString().padLeft(2, '0')}:${_remindTime!.minute.toString().padLeft(2, '0')}'
                          : '选择时间',
                      style: AppTextStyles.h2,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],

            // Submit button
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? '保存修改' : '添加任务',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _remindTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (time != null) {
      setState(() {
        _remindTime = time;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _taskDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _taskDate = date;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();
    final now = AppDateUtils.nowDateTimeString();

    String? remindTimeStr;
    if (_remindEnabled && _remindTime != null) {
      remindTimeStr =
          '${_remindTime!.hour.toString().padLeft(2, '0')}:${_remindTime!.minute.toString().padLeft(2, '0')}';
    }

    String? repeatDaysStr;
    if (_taskType == 1 && _repeatDays.isNotEmpty) {
      final sorted = _repeatDays.toList()..sort();
      repeatDaysStr = sorted.join(',');
    }

    String? taskDateStr;
    if (_taskType == 2 && _taskDate != null) {
      taskDateStr = '${_taskDate!.year}-${_taskDate!.month.toString().padLeft(2, '0')}-${_taskDate!.day.toString().padLeft(2, '0')}';
    }

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      taskType: _taskType,
      taskDate: taskDateStr,
      remindTime: remindTimeStr,
      remindEnabled: _remindEnabled,
      repeatDays: repeatDaysStr,
      createdAt: widget.task?.createdAt ?? now,
    );

    bool success;
    if (isEditing) {
      success = await taskProvider.updateTask(task);
    } else {
      success = await taskProvider.addTask(task);
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteTask() async {
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
      await context.read<TaskProvider>().deleteTask(widget.task!.id!);
      if (mounted) Navigator.pop(context);
    }
  }
}
