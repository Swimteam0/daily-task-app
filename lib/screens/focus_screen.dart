import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_text_styles.dart';
import '../providers/focus_provider.dart';
import '../widgets/focus_timer.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专注模式'),
      ),
      body: Consumer<FocusProvider>(
        builder: (context, focusProvider, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Focus icon
                  Text(
                    focusProvider.isFocusing ? '🎯' : '⏸️',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    focusProvider.isFocusing ? '专注中' : '准备开始',
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 48),

                  // Timer
                  FocusTimer(
                    time: focusProvider.formattedTime,
                    isActive: focusProvider.isFocusing,
                  ),
                  const SizedBox(height: 32),

                  // Elapsed description
                  if (focusProvider.isFocusing)
                    Text(
                      focusProvider.elapsedDescription,
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  if (focusProvider.isFocusing &&
                      focusProvider.interruptionCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '被打断 ${focusProvider.interruptionCount} 次',
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 48),

                  // Action button
                  if (focusProvider.isFocusing)
                    Column(
                      children: [
                        FilledButton.icon(
                          onPressed: () => _stopFocus(context, focusProvider),
                          icon: const Icon(Icons.stop),
                          label: const Text('结束专注'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            minimumSize: const Size(200, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            focusProvider.recordInterruption();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已记录打断'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text('记录被打断'),
                        ),
                      ],
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => _startFocus(context, focusProvider),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('开始专注'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _startFocus(BuildContext context, FocusProvider provider) {
    provider.startFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('专注模式已开启'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _stopFocus(BuildContext context, FocusProvider provider) {
    final elapsed = provider.elapsed;
    final interruptions = provider.interruptionCount;
    provider.stopFocus();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('专注结束'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              '专注时长: ${elapsed.inMinutes} 分钟',
              style: AppTextStyles.h2,
            ),
            if (interruptions > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '被打断: $interruptions 次',
                  style: AppTextStyles.body.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
