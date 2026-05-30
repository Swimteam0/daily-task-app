class FocusSession {
  final int? id;
  final String startTime;
  String? endTime;
  int durationMinutes;
  int interruptionCount;
  final String createdAt;

  FocusSession({
    this.id,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.interruptionCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'start_time': startTime,
      'end_time': endTime,
      'duration_minutes': durationMinutes,
      'interruption_count': interruptionCount,
      'created_at': createdAt,
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as int?,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String?,
      durationMinutes: map['duration_minutes'] as int,
      interruptionCount: map['interruption_count'] as int,
      createdAt: map['created_at'] as String,
    );
  }
}
