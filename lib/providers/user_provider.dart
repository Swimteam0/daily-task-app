import 'package:flutter/foundation.dart';
import '../models/user_stats.dart';
import '../database/user_dao.dart';
import '../database/check_in_dao.dart';
import '../utils/date_utils.dart';
import '../utils/level_calculator.dart';

class UserProvider extends ChangeNotifier {
  final UserDao _userDao = UserDao();
  final CheckInDao _checkInDao = CheckInDao();

  UserStats? _stats;
  UserStats? get stats => _stats;

  int get totalCheckIns => _stats?.totalCheckIns ?? 0;
  int get currentStreak => _stats?.currentStreak ?? 0;
  int get maxStreak => _stats?.maxStreak ?? 0;
  int get level => _stats?.level ?? 1;
  int get rank => _stats?.rank ?? 1;

  String get levelName => LevelCalculator.getLevelConfig(level).name;
  String get levelIcon => LevelCalculator.getLevelConfig(level).icon;
  String get rankName => LevelCalculator.getRankConfig(rank).name;
  String get rankIcon => LevelCalculator.getRankConfig(rank).icon;

  double get levelProgress => LevelCalculator.getLevelProgress(totalCheckIns);
  double get rankProgress => LevelCalculator.getRankProgress(currentStreak);
  int get nextLevelCheckIns => LevelCalculator.getNextLevelCheckIns(totalCheckIns);
  int get nextRankDays => LevelCalculator.getNextRankDays(currentStreak);

  Future<void> loadUserStats() async {
    _stats = await _userDao.getUserStats();
    notifyListeners();
  }

  Future<void> onCheckIn() async {
    if (_stats == null) return;

    _stats!.totalCheckIns += 1;
    _stats!.level = LevelCalculator.calculateLevel(_stats!.totalCheckIns);

    final today = AppDateUtils.todayString();
    final yesterday = AppDateUtils.formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (_stats!.lastCheckInDate == yesterday) {
      _stats!.currentStreak += 1;
    } else if (_stats!.lastCheckInDate != today) {
      _stats!.currentStreak = 1;
    }

    if (_stats!.currentStreak > _stats!.maxStreak) {
      _stats!.maxStreak = _stats!.currentStreak;
    }

    _stats!.rank = LevelCalculator.calculateRank(_stats!.currentStreak);
    _stats!.lastCheckInDate = today;
    _stats!.updatedAt = AppDateUtils.nowDateTimeString();

    await _userDao.updateUserStats(_stats!);
    notifyListeners();
  }

  Future<void> updateStreakIfNeeded() async {
    if (_stats == null) return;

    final today = AppDateUtils.todayString();
    final yesterday = AppDateUtils.formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    // If last check-in was before yesterday, streak is broken
    if (_stats!.lastCheckInDate != null &&
        _stats!.lastCheckInDate != today &&
        _stats!.lastCheckInDate != yesterday) {
      _stats!.currentStreak = 0;
      _stats!.rank = 1;
      _stats!.updatedAt = AppDateUtils.nowDateTimeString();
      await _userDao.updateUserStats(_stats!);
      notifyListeners();
    }
  }

  Future<int> getWeekCheckInDays() async {
    final now = DateTime.now();
    final weekday = now.weekday;
    final start = now.subtract(Duration(days: weekday - 1));
    return await _checkInDao.getCheckInCountByDateRange(
      AppDateUtils.formatDate(start),
      AppDateUtils.formatDate(now),
    );
  }

  Future<int> getMonthCheckInDays() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return await _checkInDao.getCheckInCountByDateRange(
      AppDateUtils.formatDate(start),
      AppDateUtils.formatDate(now),
    );
  }
}
