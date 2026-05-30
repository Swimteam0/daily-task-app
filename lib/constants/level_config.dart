class LevelConfig {
  final int level;
  final String name;
  final String icon;
  final int requiredCheckIns;

  const LevelConfig({
    required this.level,
    required this.name,
    required this.icon,
    required this.requiredCheckIns,
  });
}

class RankConfig {
  final int rank;
  final String name;
  final String icon;
  final int requiredStreakDays;

  const RankConfig({
    required this.rank,
    required this.name,
    required this.icon,
    required this.requiredStreakDays,
  });
}

class GameConfig {
  static const List<LevelConfig> levels = [
    LevelConfig(level: 1, name: '初心者', icon: '🌱', requiredCheckIns: 0),
    LevelConfig(level: 2, name: '坚持者', icon: '🌿', requiredCheckIns: 10),
    LevelConfig(level: 3, name: '勤勉者', icon: '🌳', requiredCheckIns: 30),
    LevelConfig(level: 4, name: '执着者', icon: '⭐', requiredCheckIns: 60),
    LevelConfig(level: 5, name: '自律者', icon: '🌙', requiredCheckIns: 100),
    LevelConfig(level: 6, name: '领悟者', icon: '☀️', requiredCheckIns: 150),
    LevelConfig(level: 7, name: '大师', icon: '🌟', requiredCheckIns: 220),
    LevelConfig(level: 8, name: '宗师', icon: '👑', requiredCheckIns: 300),
    LevelConfig(level: 9, name: '传奇', icon: '💎', requiredCheckIns: 400),
    LevelConfig(level: 10, name: '不朽', icon: '🔱', requiredCheckIns: 500),
  ];

  static const List<RankConfig> ranks = [
    RankConfig(rank: 1, name: '黑铁', icon: '⚫', requiredStreakDays: 1),
    RankConfig(rank: 2, name: '青铜', icon: '🟤', requiredStreakDays: 3),
    RankConfig(rank: 3, name: '白银', icon: '⚪', requiredStreakDays: 7),
    RankConfig(rank: 4, name: '黄金', icon: '🟡', requiredStreakDays: 14),
    RankConfig(rank: 5, name: '铂金', icon: '🔵', requiredStreakDays: 21),
    RankConfig(rank: 6, name: '钻石', icon: '💠', requiredStreakDays: 30),
    RankConfig(rank: 7, name: '星耀', icon: '✨', requiredStreakDays: 45),
    RankConfig(rank: 8, name: '王者', icon: '🏆', requiredStreakDays: 60),
  ];
}