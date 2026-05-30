import '../constants/level_config.dart';

class LevelCalculator {
  static int calculateLevel(int totalCheckIns) {
    int level = 1;
    for (final config in GameConfig.levels) {
      if (totalCheckIns >= config.requiredCheckIns) {
        level = config.level;
      } else {
        break;
      }
    }
    return level;
  }

  static int calculateRank(int currentStreak) {
    int rank = 1;
    for (final config in GameConfig.ranks) {
      if (currentStreak >= config.requiredStreakDays) {
        rank = config.rank;
      } else {
        break;
      }
    }
    return rank;
  }

  static LevelConfig getLevelConfig(int level) {
    return GameConfig.levels.firstWhere(
      (c) => c.level == level,
      orElse: () => GameConfig.levels.first,
    );
  }

  static RankConfig getRankConfig(int rank) {
    return GameConfig.ranks.firstWhere(
      (c) => c.rank == rank,
      orElse: () => GameConfig.ranks.first,
    );
  }

  static double getLevelProgress(int totalCheckIns) {
    final currentLevel = calculateLevel(totalCheckIns);
    final currentConfig = getLevelConfig(currentLevel);

    if (currentLevel >= GameConfig.levels.length) return 1.0;

    final nextConfig = GameConfig.levels[currentLevel];
    final range = nextConfig.requiredCheckIns - currentConfig.requiredCheckIns;
    final progress = totalCheckIns - currentConfig.requiredCheckIns;
    return progress / range;
  }

  static double getRankProgress(int currentStreak) {
    final currentRank = calculateRank(currentStreak);
    final currentConfig = getRankConfig(currentRank);

    if (currentRank >= GameConfig.ranks.length) return 1.0;

    final nextConfig = GameConfig.ranks[currentRank];
    final range = nextConfig.requiredStreakDays - currentConfig.requiredStreakDays;
    final progress = currentStreak - currentConfig.requiredStreakDays;
    return progress / range;
  }

  static int getNextLevelCheckIns(int totalCheckIns) {
    final currentLevel = calculateLevel(totalCheckIns);
    if (currentLevel >= GameConfig.levels.length) return totalCheckIns;
    return GameConfig.levels[currentLevel].requiredCheckIns;
  }

  static int getNextRankDays(int currentStreak) {
    final currentRank = calculateRank(currentStreak);
    if (currentRank >= GameConfig.ranks.length) return currentStreak;
    return GameConfig.ranks[currentRank].requiredStreakDays;
  }
}
