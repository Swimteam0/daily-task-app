class UserStats {
  final int id;
  int totalCheckIns;
  int currentStreak;
  int maxStreak;
  String? lastCheckInDate;
  int level;
  int rank;
  String updatedAt;

  UserStats({
    this.id = 1,
    this.totalCheckIns = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastCheckInDate,
    this.level = 1,
    this.rank = 1,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_check_ins': totalCheckIns,
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'last_check_in_date': lastCheckInDate,
      'level': level,
      'rank': rank,
      'updated_at': updatedAt,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      id: map['id'] as int,
      totalCheckIns: map['total_check_ins'] as int,
      currentStreak: map['current_streak'] as int,
      maxStreak: map['max_streak'] as int,
      lastCheckInDate: map['last_check_in_date'] as String?,
      level: map['level'] as int,
      rank: map['rank'] as int,
      updatedAt: map['updated_at'] as String,
    );
  }

  UserStats copyWith({
    int? totalCheckIns,
    int? currentStreak,
    int? maxStreak,
    String? lastCheckInDate,
    int? level,
    int? rank,
    String? updatedAt,
  }) {
    return UserStats(
      id: id,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      level: level ?? this.level,
      rank: rank ?? this.rank,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
