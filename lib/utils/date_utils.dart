import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  static String todayString() {
    return formatDate(DateTime.now());
  }

  static String nowTimeString() {
    return formatTime(DateTime.now());
  }

  static String nowDateTimeString() {
    return formatDateTime(DateTime.now());
  }

  static String weekdayName(int weekday) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[weekday - 1];
  }

  static String monthDayString(DateTime date) {
    return DateFormat('M月d日').format(date);
  }

  static String fullDateString(DateTime date) {
    return DateFormat('yyyy年M月d日').format(date);
  }

  static bool isToday(String dateString) {
    return dateString == todayString();
  }

  static bool isYesterday(String dateString) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateString == formatDate(yesterday);
  }

  static int daysBetween(String date1, String date2) {
    final d1 = DateTime.parse(date1);
    final d2 = DateTime.parse(date2);
    return d2.difference(d1).inDays;
  }

  static String getWeekRange() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final start = now.subtract(Duration(days: weekday - 1));
    final end = start.add(const Duration(days: 6));
    return '${monthDayString(start)} - ${monthDayString(end)}';
  }

  static int getDaysInMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  static bool shouldShowTask(String? repeatDays, int taskType) {
    if (taskType == 2) return true; // 单日任务总是显示
    if (repeatDays == null || repeatDays.isEmpty) return true; // 每天
    final today = DateTime.now().weekday;
    final days = repeatDays.split(',').map(int.parse).toList();
    return days.contains(today);
  }
}
