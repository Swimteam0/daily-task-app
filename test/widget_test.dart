import 'package:flutter_test/flutter_test.dart';
import 'package:daily_task_app/utils/date_utils.dart';
import 'package:daily_task_app/utils/level_calculator.dart';
import 'package:daily_task_app/constants/level_config.dart';

void main() {
  group('LevelCalculator', () {
    test('should return level 1 for 0 check-ins', () {
      expect(LevelCalculator.calculateLevel(0), 1);
    });

    test('should return level 2 for 10 check-ins', () {
      expect(LevelCalculator.calculateLevel(10), 2);
    });

    test('should return level 10 for 500 check-ins', () {
      expect(LevelCalculator.calculateLevel(500), 10);
    });

    test('should return rank 1 for 1 day streak', () {
      expect(LevelCalculator.calculateRank(1), 1);
    });

    test('should return rank 8 for 60 day streak', () {
      expect(LevelCalculator.calculateRank(60), 8);
    });

    test('should have correct number of levels', () {
      expect(GameConfig.levels.length, 10);
    });

    test('should have correct number of ranks', () {
      expect(GameConfig.ranks.length, 8);
    });
  });

  group('AppDateUtils', () {
    test('should format date correctly', () {
      final date = DateTime(2026, 5, 30);
      expect(AppDateUtils.formatDate(date), '2026-05-30');
    });

    test('should return correct weekday name', () {
      expect(AppDateUtils.weekdayName(1), '周一');
      expect(AppDateUtils.weekdayName(7), '周日');
    });

    test('should calculate days between dates', () {
      expect(AppDateUtils.daysBetween('2026-05-01', '2026-05-30'), 29);
    });
  });
}
