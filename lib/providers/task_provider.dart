import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/check_in.dart';
import '../database/task_dao.dart';
import '../database/check_in_dao.dart';
import '../utils/date_utils.dart';

class TaskProvider extends ChangeNotifier {
  final TaskDao _taskDao = TaskDao();
  final CheckInDao _checkInDao = CheckInDao();

  List<Task> _tasks = [];
  Set<String> _todayCheckedInTaskIds = {};
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  Set<String> get todayCheckedInTaskIds => _todayCheckedInTaskIds;
  bool get isLoading => _isLoading;

  List<Task> get todayTasks {
    return _tasks.where((task) {
      if (task.taskType == 2) {
        // 单日任务：检查 taskDate 是否是今天
        if (task.taskDate != null) {
          return task.taskDate == AppDateUtils.todayString();
        }
        // 兼容旧数据：检查 createdAt
        return task.createdAt.startsWith(AppDateUtils.todayString());
      }
      return AppDateUtils.shouldShowTask(task.repeatDays, task.taskType);
    }).toList();
  }

  /// 获取指定日期的任务
  List<Task> getTasksByDate(String date) {
    return _tasks.where((task) {
      if (task.taskType == 2) {
        if (task.taskDate != null) {
          return task.taskDate == date;
        }
        return task.createdAt.startsWith(date);
      }
      // 每日任务在任何日期都显示
      return AppDateUtils.shouldShowTask(task.repeatDays, task.taskType);
    }).toList();
  }

  List<Task> get pendingTasks {
    return todayTasks
        .where((t) => !_todayCheckedInTaskIds.contains(t.id.toString()))
        .toList();
  }

  List<Task> get completedTasks {
    return todayTasks
        .where((t) => _todayCheckedInTaskIds.contains(t.id.toString()))
        .toList();
  }

  int get pendingCount => pendingTasks.length;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskDao.getAllTasks();
    final todayCheckIns = await _checkInDao.getCheckInsByDate(AppDateUtils.todayString());
    _todayCheckedInTaskIds = todayCheckIns.map((c) => c.taskId.toString()).toSet();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTask(Task task) async {
    try {
      final id = await _taskDao.insertTask(task);
      _tasks.insert(0, task.copyWith(id: id));
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      await _taskDao.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _taskDao.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<CheckIn?> checkIn(int taskId) async {
    try {
      final now = DateTime.now();
      final checkIn = CheckIn(
        taskId: taskId,
        checkInDate: AppDateUtils.formatDate(now),
        checkInTime: AppDateUtils.formatTime(now),
        createdAt: AppDateUtils.formatDateTime(now),
      );
      final id = await _checkInDao.insertCheckIn(checkIn);
      if (id > 0) {
        _todayCheckedInTaskIds.add(taskId.toString());
        notifyListeners();
        return checkIn;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 补签功能：为指定日期打卡
  Future<CheckIn?> makeupCheckIn(int taskId, String date) async {
    try {
      // 检查是否已经打卡
      final existingCheckIns = await _checkInDao.getCheckInsByDate(date);
      if (existingCheckIns.any((c) => c.taskId == taskId)) {
        return null; // 已经打卡
      }

      final now = DateTime.now();
      final checkIn = CheckIn(
        taskId: taskId,
        checkInDate: date,
        checkInTime: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
        createdAt: AppDateUtils.formatDateTime(now),
      );
      final id = await _checkInDao.insertCheckIn(checkIn);
      if (id > 0) {
        // 如果补签的是今天，更新今日打卡状态
        if (date == AppDateUtils.todayString()) {
          _todayCheckedInTaskIds.add(taskId.toString());
        }
        notifyListeners();
        return checkIn;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 检查指定日期是否已打卡
  Future<bool> isTaskCheckedInOnDate(int taskId, String date) async {
    final checkIns = await _checkInDao.getCheckInsByDate(date);
    return checkIns.any((c) => c.taskId == taskId);
  }

  bool isTaskCheckedIn(int taskId) {
    return _todayCheckedInTaskIds.contains(taskId.toString());
  }
}
