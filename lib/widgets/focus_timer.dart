import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

class FocusTimer extends StatelessWidget {
  final String time;
  final bool isActive;

  const FocusTimer({
    super.key,
    required this.time,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? primaryColor.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        border: Border.all(
          color: isActive ? primaryColor : Theme.of(context).dividerColor,
          width: 4,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: AppTextStyles.h1.copyWith(
                fontSize: 40,
                color: isActive ? primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isActive ? '专注中' : '计时器',
              style: AppTextStyles.caption.copyWith(
                color: isActive ? primaryColor : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
