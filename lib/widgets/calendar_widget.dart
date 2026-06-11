import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

class CalendarWidget extends StatefulWidget {
  final String selectedDate;
  final Function(String) onDateSelected;
  final Set<String> checkinDates;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.checkinDates,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.parse(widget.selectedDate);
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDate = DateTime.parse(widget.selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWeekDays(),
          const SizedBox(height: 8),
          _buildDays(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
          },
        ),
        Text(
          '${_currentMonth.year}年${_currentMonth.month}月',
          style: AppTextStyles.h3,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: days.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDays() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday; // 1=周一, 7=周日

    final days = <Widget>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 填充月初空白
    for (int i = 1; i < firstWeekday; i++) {
      days.add(const SizedBox());
    }

    // 填充日期
    for (int i = 1; i <= lastDay.day; i++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, i);
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final isSelected = dateStr == widget.selectedDate;
      final isToday = date == today;
      final isFuture = date.isAfter(today);
      final isCheckin = widget.checkinDates.contains(dateStr);

      days.add(
        GestureDetector(
          onTap: isFuture ? null : () => widget.onDateSelected(dateStr),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isCheckin
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$i',
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : isFuture
                          ? Theme.of(context).disabledColor
                          : isCheckin
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                  fontWeight: isToday || isSelected ? FontWeight.bold : null,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }
}
