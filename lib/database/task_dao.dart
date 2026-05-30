import '../models/task.dart';
import 'database_helper.dart';

class TaskDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Task?> getTaskById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ? AND is_active = 1',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByType(int taskType) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'is_active = 1 AND task_type = ?',
      whereArgs: [taskType],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }
}
