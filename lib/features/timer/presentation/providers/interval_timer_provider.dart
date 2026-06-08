import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/services/background_timer_service.dart';
import 'package:kdh_mobile/core/services/timer_notification_service.dart';
import 'package:kdh_mobile/features/timer/presentation/services/active_timer_registry.dart';
import 'package:kdh_mobile/features/timer/presentation/services/timer_sound_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

const List<int> kIntervalDurations = [180, 60, 120];

enum TimerStatus { ready, running, finished }

class IntervalTimerState {
  final TimerStatus status;
  final int totalRemainingSeconds;
  final int totalSeconds;
  final int currentIntervalIndex;
  final int intervalElapsedSeconds;
  final int currentSet;

  const IntervalTimerState({
    required this.status,
    required this.totalRemainingSeconds,
    required this.totalSeconds,
    required this.currentIntervalIndex,
    required this.intervalElapsedSeconds,
    required this.currentSet,
  });

  IntervalTimerState copyWith({
    TimerStatus? status,
    int? totalRemainingSeconds,
    int? totalSeconds,
    int? currentIntervalIndex,
    int? intervalElapsedSeconds,
    int? currentSet,
  }) => IntervalTimerState(
    status: status ?? this.status,
    totalRemainingSeconds: totalRemainingSeconds ?? this.totalRemainingSeconds,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    currentIntervalIndex: currentIntervalIndex ?? this.currentIntervalIndex,
    intervalElapsedSeconds:
        intervalElapsedSeconds ?? this.intervalElapsedSeconds,
    currentSet: currentSet ?? this.currentSet,
  );

  String get currentIntervalDurationLabel {
    final mins = kIntervalDurations[currentIntervalIndex] ~/ 60;
    return '$mins:00';
  }

  String get intervalElapsedLabel {
    final m = intervalElapsedSeconds ~/ 60;
    final s = intervalElapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get totalElapsedLabel {
    final elapsed = totalSeconds - totalRemainingSeconds;
    final h = elapsed ~/ 3600;
    final m = (elapsed % 3600) ~/ 60;
    final s = elapsed % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get intervalProgress {
    final total = kIntervalDurations[currentIntervalIndex];
    if (total == 0) return 0.0;
    return (intervalElapsedSeconds / total).clamp(0.0, 1.0);
  }
}

class IntervalTimerNotifier extends StateNotifier<IntervalTimerState> {
  IntervalTimerNotifier(this._ref, int totalSeconds)
    : super(
        IntervalTimerState(
          status: TimerStatus.ready,
          totalRemainingSeconds: totalSeconds,
          totalSeconds: totalSeconds,
          currentIntervalIndex: 0,
          intervalElapsedSeconds: 0,
          currentSet: 1,
        ),
      ) {
    _subscribeToService();
  }

  final Ref _ref;
  KeepAliveLink? _keepAlive;
  StreamSubscription? _tickSub;
  StreamSubscription? _finishedSub;

  Future<void> _subscribeToService() async {
    final svc = FlutterBackgroundService();

    _tickSub = svc.on(kEvtTick).listen((data) {
      if (data == null || data['type'] != kTypeInterval) return;
      _applyTick(data);
    });

    _finishedSub = svc.on(kEvtFinished).listen((data) {
      if (data == null || data['type'] != kTypeInterval) return;
      _handleFinished();
    });

    if (await svc.isRunning()) {
      svc.invoke(kCmdGetState, {});
    }
  }

  void _applyTick(Map<String, dynamic> data) {
    if (state.status != TimerStatus.running) {
      _keepAlive ??= _ref.keepAlive();
      state = state.copyWith(status: TimerStatus.running);
    }

    final prevIdx = state.currentIntervalIndex;
    final newIdx = (data['intervalIndex'] as num?)?.toInt() ?? prevIdx;

    state = state.copyWith(
      totalRemainingSeconds: (data['remaining'] as num).toInt(),
      currentIntervalIndex: newIdx,
      intervalElapsedSeconds:
          (data['intervalElapsed'] as num?)?.toInt() ?? state.intervalElapsedSeconds,
      currentSet: (data['currentSet'] as num?)?.toInt() ?? state.currentSet,
    );

    if (newIdx != prevIdx) TimerSoundService.playIntervalStart();
  }

  void _handleFinished() {
    if (state.status != TimerStatus.running) return;
    _keepAlive?.close();
    _keepAlive = null;
    WakelockPlus.disable();
    TimerNotificationService.cancelAll();
    ActiveTimerRegistry.clear();
    state = state.copyWith(
      totalRemainingSeconds: 0,
      status: TimerStatus.finished,
    );
    TimerSoundService.playFinish();
  }

  Future<void> start() async {
    if (state.status == TimerStatus.running) return;

    ActiveTimerRegistry.setActive(
      ActiveTimerRegistry.intervalKey(state.totalSeconds),
    );
    _keepAlive ??= _ref.keepAlive();
    state = state.copyWith(status: TimerStatus.running);
    TimerSoundService.playIntervalStart();
    WakelockPlus.enable();

    final svc = FlutterBackgroundService();
    final alreadyRunning = await svc.isRunning();
    await svc.startService();
    if (!alreadyRunning) {
      await svc.on('ready').first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => {},
      );
    }
    svc.invoke(kCmdStart, {
      'type': kTypeInterval,
      'totalSeconds': state.totalSeconds,
      'intervals': kIntervalDurations,
    });

    _scheduleNotifications(DateTime.now());
  }

  void reset() {
    FlutterBackgroundService().invoke(kCmdReset, {});
    _keepAlive?.close();
    _keepAlive = null;
    WakelockPlus.disable();
    TimerNotificationService.cancelAll();
    ActiveTimerRegistry.clear();
    state = IntervalTimerState(
      status: TimerStatus.ready,
      totalRemainingSeconds: state.totalSeconds,
      totalSeconds: state.totalSeconds,
      currentIntervalIndex: 0,
      intervalElapsedSeconds: 0,
      currentSet: 1,
    );
  }

  void _scheduleNotifications(DateTime virtualStart) {
    final boundaries = <int>[];
    int elapsed = 0;
    int idx = 0;
    while (true) {
      elapsed += kIntervalDurations[idx];
      if (elapsed >= state.totalSeconds) break;
      boundaries.add(elapsed);
      idx = (idx + 1) % kIntervalDurations.length;
    }
    TimerNotificationService.schedule(
      virtualStart: virtualStart,
      intervalBoundaries: boundaries,
      totalSeconds: state.totalSeconds,
    );
  }

  @override
  void dispose() {
    _tickSub?.cancel();
    _finishedSub?.cancel();
    if (state.status != TimerStatus.running) {
      FlutterBackgroundService().invoke(kCmdReset, {});
    }
    WakelockPlus.disable();
    super.dispose();
  }
}

final intervalTimerProvider = StateNotifierProvider.autoDispose
    .family<IntervalTimerNotifier, IntervalTimerState, int>(
      (ref, totalSeconds) => IntervalTimerNotifier(ref, totalSeconds),
    );
