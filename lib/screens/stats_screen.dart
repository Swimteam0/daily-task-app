import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../database/check_in_dao.dart';
import '../providers/user_provider.dart';
import '../utils/date_utils.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final CheckInDao _checkInDao = CheckInDao();
  Set<String> _checkInDates = {};
  Map<String, int> _weeklyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dates = await _checkInDao.getCheckInDates();
    final weeklyData = _calculateWeeklyData(dates);
    if (mounted) {
      setState(() {
        _checkInDates = dates;
        _weeklyData = weeklyData;
        _isLoading = false;
      });
    }
  }

  Map<String, int> _calculateWeeklyData(Set<String> dates) {
    final now = DateTime.now();
    final Map<String, int> data = {};
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = AppDateUtils.formatDate(date);
      final dayName = AppDateUtils.weekdayName(date.weekday);
      data[dayName] = dates.contains(dateStr) ? 1 : 0;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Weekly bar chart
                  _buildSection(
                    context,
                    title: '本周打卡',
                    child: _buildWeeklyChart(context),
                  ),
                  const SizedBox(height: 16),

                  // Calendar heatmap
                  _buildSection(
                    context,
                    title: '打卡日历',
                    child: _buildCalendarHeatmap(context),
                  ),
                  const SizedBox(height: 16),

                  // Summary stats
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return _buildSection(
                        context,
                        title: '总览',
                        child: _buildSummaryGrid(context, userProvider),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final entries = _weeklyData.entries.toList();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1,
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[index].key.substring(1),
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(entries.length, (index) {
            final value = entries[index].value.toDouble();
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: value > 0
                      ? primaryColor
                      : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCalendarHeatmap(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      children: [
        // Month header
        Text(
          '${now.year}年${now.month}月',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 12),
        // Weekday headers
        Row(
          children: ['一', '二', '三', '四', '五', '六', '日']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: (firstWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              return const SizedBox.shrink();
            }
            final day = index - (firstWeekday - 1) + 1;
            final dateStr =
                '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
            final isChecked = _checkInDates.contains(dateStr);
            final isToday = day == now.day;

            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isChecked
                    ? primaryColor.withValues(alpha: 0.8)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: primaryColor, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: AppTextStyles.caption.copyWith(
                    color: isChecked
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText),
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          icon: Icons.check_circle_outline,
          label: '累计打卡',
          value: '${userProvider.totalCheckIns}',
          color: isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
        ),
        _buildStatCard(
          context,
          icon: Icons.local_fire_department,
          label: '当前连续',
          value: '${userProvider.currentStreak}天',
          color: isDark ? AppColors.darkWarning : AppColors.lightWarning,
        ),
        _buildStatCard(
          context,
          icon: Icons.emoji_events_outlined,
          label: '最长连续',
          value: '${userProvider.maxStreak}天',
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
        _buildStatCard(
          context,
          icon: Icons.calendar_month_outlined,
          label: '打卡天数',
          value: '${_checkInDates.length}',
          color: isDark ? AppColors.darkError : AppColors.lightError,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
