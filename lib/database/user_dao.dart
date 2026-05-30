import 'package:sqflite/sqflite.dart';
import '../models/user_stats.dart';
import 'database_helper.dart';

class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<UserStats> getUserStats() async {
    final db = await _dbHelper.database;
    final maps = await db.query('user_stats', where: 'id = 1');
    return UserStats.fromMap(maps.first);
  }

  Future<void> updateUserStats(UserStats stats) async {
    final db = await _dbHelper.database;
    await db.update(
      'user_stats',
      stats.toMap(),
      where: 'id = 1',
    );
  }

  Future<void> incrementCheckIn() async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE user_stats SET total_check_ins = total_check_ins + 1, updated_at = ? WHERE id = 1',
      [DateTime.now().toIso8601String()],
    );
  }

  Future<void> updateStreak(int streak, String lastDate) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE user_stats SET current_streak = ?, max_streak = MAX(max_streak, ?), last_check_in_date = ?, updated_at = ? WHERE id = 1',
      [streak, streak, lastDate, DateTime.now().toIso8601String()],
    );
  }

  Future<void> updateLevelAndRank(int level, int rank) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE user_stats SET level = ?, rank = ?, updated_at = ? WHERE id = 1',
      [level, rank, DateTime.now().toIso8601String()],
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
