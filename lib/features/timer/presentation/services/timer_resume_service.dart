import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:kdh_mobile/core/services/background_timer_service.dart';

class ActiveTimerInfo {
  const ActiveTimerInfo({
    required this.type,
    required this.totalSeconds,
    required this.intervals,
    required this.bpm,
  });

  final String type;
  final int totalSeconds;
  final List<int> intervals;
  final int bpm;
}

class TimerResumeService {
  TimerResumeService._();

  static Future<ActiveTimerInfo?> queryActiveTimer() async {
    final svc = FlutterBackgroundService();

    bool running;
    try {
      running = await svc.isRunning();
    } catch (_) {
      return null;
    }
    if (!running) return null;

    final completer = Completer<ActiveTimerInfo?>();
    late final StreamSubscription sub;
    sub = svc.on(kEvtActiveTimer).listen((data) {
      if (completer.isCompleted) return;
      if (data == null || data['running'] != true) {
        completer.complete(null);
      } else {
        completer.complete(
          ActiveTimerInfo(
            type: data['type'] as String? ?? kTypeInterval,
            totalSeconds: (data['totalSeconds'] as num?)?.toInt() ?? 0,
            intervals:
                (data['intervals'] as List?)?.map((e) => (e as num).toInt()).toList() ??
                const [],
            bpm: (data['bpm'] as num?)?.toInt() ?? 0,
          ),
        );
      }
    });

    svc.invoke(kCmdGetActiveTimer, {});

    final result = await completer.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => null,
    );
    await sub.cancel();
    return result;
  }
}
