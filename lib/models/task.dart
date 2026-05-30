class Task {
  final int? id;
  final String title;
  final String? description;
  final int taskType; // 1=每日重复, 2=单日任务
  final String? remindTime; // HH:mm
  final bool remindEnabled;
  final String? repeatDays; // "1,2,3,4,5"
  final String createdAt;
  final bool isActive;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.taskType,
    this.remindTime,
    this.remindEnabled = false,
    this.repeatDays,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'task_type': taskType,
      'remind_time': remindTime,
      'remind_enabled': remindEnabled ? 1 : 0,
      'repeat_days': repeatDays,
      'created_at': createdAt,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      taskType: map['task_type'] as int,
      remindTime: map['remind_time'] as String?,
      remindEnabled: (map['remind_enabled'] as int) == 1,
      repeatDays: map['repeat_days'] as String?,
      createdAt: map['created_at'] as String,
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    int? taskType,
    String? remindTime,
    bool? remindEnabled,
    String? repeatDays,
    String? createdAt,
    bool? isActive,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      remindTime: remindTime ?? this.remindTime,
      remindEnabled: remindEnabled ?? this.remindEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
