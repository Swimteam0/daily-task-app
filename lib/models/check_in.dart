class CheckIn {
  final int? id;
  final int taskId;
  final String checkInDate; // YYYY-MM-DD
  final String checkInTime; // HH:mm:ss
  final String createdAt;

  CheckIn({
    this.id,
    required this.taskId,
    required this.checkInDate,
    required this.checkInTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'check_in_date': checkInDate,
      'check_in_time': checkInTime,
      'created_at': createdAt,
    };
  }

  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      checkInDate: map['check_in_date'] as String,
      checkInTime: map['check_in_time'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
