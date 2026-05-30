import 'dart:async';
import 'package:flutter/foundation.dart';

class FocusProvider extends ChangeNotifier {
  bool _isFocusing = false;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  int _interruptionCount = 0;
  Timer? _timer;

  bool get isFocusing => _isFocusing;
  Duration get elapsed => _elapsed;
  int get interruptionCount => _interruptionCount;

  String get formattedTime {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get elapsedDescription {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    if (hours > 0) {
      return '已专注 ${hours}小时${minutes}分';
    }
    return '已专注 ${minutes}分钟';
  }

  void startFocus() {
    _isFocusing = true;
    _startTime = DateTime.now();
    _elapsed = Duration.zero;
    _interruptionCount = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        _elapsed = DateTime.now().difference(_startTime!);
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void stopFocus() {
    _isFocusing = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void recordInterruption() {
    _interruptionCount++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
