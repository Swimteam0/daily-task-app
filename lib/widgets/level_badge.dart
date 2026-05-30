import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

class LevelBadge extends StatelessWidget {
  final String icon;
  final String name;
  final int level;
  final double progress;
  final int currentCheckIns;
  final int nextCheckIns;
  final bool compact;

  const LevelBadge({
    super.key,
    required this.icon,
    required this.name,
    required this.level,
    required this.progress,
    required this.currentCheckIns,
    required this.nextCheckIns,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name Lv.$level',
                style: AppTextStyles.h3.copyWith(color: primaryColor),
              ),
              Text(
                '累计打卡: ${currentCheckIns}次',
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          '$name Lv.$level',
          style: AppTextStyles.h2.copyWith(color: primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          '累计打卡: ${currentCheckIns}次',
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currentCheckIns / $nextCheckIns 次升级',
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
