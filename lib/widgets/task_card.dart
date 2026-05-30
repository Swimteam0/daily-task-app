import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isCheckedIn;
  final VoidCallback onCheckIn;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isCheckedIn,
    required this.onCheckIn,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final primaryText = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCheckedIn
            ? (isDark ? const Color(0xFF1B2E1B) : const Color(0xFFF0FFF0))
            : cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCheckedIn
              ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess).withValues(alpha: 0.3)
              : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: AppTextStyles.h3.copyWith(
                                color: isCheckedIn
                                    ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                                    : primaryText,
                                decoration: isCheckedIn ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (task.taskType == 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '重复',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: AppTextStyles.caption.copyWith(color: secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (task.remindEnabled && task.remindTime != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: secondaryText),
                            const SizedBox(width: 4),
                            Text(
                              '提醒: ${task.remindTime}',
                              style: AppTextStyles.caption.copyWith(color: secondaryText),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: isCheckedIn ? null : onCheckIn,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCheckedIn
                          ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCheckedIn
                            ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                            : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCheckedIn
                          ? const Icon(Icons.check, color: Colors.white, size: 28)
                          : Icon(
                              Icons.check,
                              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                              size: 28,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
