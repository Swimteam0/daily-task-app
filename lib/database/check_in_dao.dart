import 'package:sqflite/sqflite.dart';
import '../models/check_in.dart';
import 'database_helper.dart';

class CheckInDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertCheckIn(CheckIn checkIn) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'check_ins',
      checkIn.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<bool> hasCheckedIn(int taskId, String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'check_ins',
      where: 'task_id = ? AND check_in_date = ?',
      whereArgs: [taskId, date],
    );
    return maps.isNotEmpty;
  }

  Future<List<CheckIn>> getCheckInsByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'check_ins',
      where: 'check_in_date = ?',
      whereArgs: [date],
    );
    return maps.map((map) => CheckIn.fromMap(map)).toList();
  }

  Future<List<CheckIn>> getCheckInsByTask(int taskId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'check_ins',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'check_in_date DESC',
    );
    return maps.map((map) => CheckIn.fromMap(map)).toList();
  }

  Future<int> getTotalCheckInCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM check_ins');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCheckInCountByDateRange(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT check_in_date) as cnt FROM check_ins WHERE check_in_date >= ? AND check_in_date <= ?',
      [startDate, endDate],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Set<String>> getCheckInDates() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT check_in_date FROM check_ins ORDER BY check_in_date DESC',
    );
    return maps.map((map) => map['check_in_date'] as String).toSet();
  }
}
