import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/user_provider.dart';
import '../widgets/level_badge.dart';
import '../widgets/rank_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _weekDays = 0;
  int _monthDays = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadUserStats();
    await userProvider.updateStreakIfNeeded();
    final weekDays = await userProvider.getWeekCheckInDays();
    final monthDays = await userProvider.getMonthCheckInDays();
    if (mounted) {
      setState(() {
        _weekDays = weekDays;
        _monthDays = monthDays;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return RefreshIndicator(
            onRefresh: _loadStats,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          .withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Level section
                _buildSection(
                  context,
                  child: LevelBadge(
                    icon: userProvider.levelIcon,
                    name: userProvider.levelName,
                    level: userProvider.level,
                    progress: userProvider.levelProgress,
                    currentCheckIns: userProvider.totalCheckIns,
                    nextCheckIns: userProvider.nextLevelCheckIns,
                  ),
                ),
                const SizedBox(height: 16),

                // Rank section
                _buildSection(
                  context,
                  child: RankBadge(
                    icon: userProvider.rankIcon,
                    name: userProvider.rankName,
                    currentStreak: userProvider.currentStreak,
                    progress: userProvider.rankProgress,
                    nextDays: userProvider.nextRankDays,
                  ),
                ),
                const SizedBox(height: 16),

                // Stats section
                _buildSection(
                  context,
                  child: Column(
                    children: [
                      Text('打卡统计', style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      _buildStatRow(context, '本周', '$_weekDays / 7 天'),
                      const Divider(),
                      _buildStatRow(context, '本月', '$_monthDays / ${_getDaysInMonth()} 天'),
                      const Divider(),
                      _buildStatRow(context, '累计打卡', '${userProvider.totalCheckIns} 次'),
                      const Divider(),
                      _buildStatRow(context, '最长连续', '${userProvider.maxStreak} 天'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: child,
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.h3),
        ],
      ),
    );
  }

  int _getDaysInMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }
}
