import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/services/background_timer_service.dart';
import 'package:kdh_mobile/core/services/timer_notification_service.dart';
import 'package:kdh_mobile/features/timer/presentation/services/active_timer_registry.dart';
import 'package:kdh_mobile/features/timer/presentation/services/timer_sound_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum CustomTimerStatus { ready, running, finished }

class CustomTimerConfig {
  final List<int> intervals;
  final int totalSeconds;

  CustomTimerConfig({
    required List<int> intervals,
    required this.totalSeconds,
  }) : intervals = List.unmodifiable(intervals) {
    if (this.intervals.isEmpty) throw ArgumentError('인터벌이 비어 있으면 안됩니다.');
    if (this.intervals.any((v) => v <= 0)) throw ArgumentError('모든 인터벌은 0보다 커야 합니다.');
    if (totalSeconds <= 0) throw ArgumentError('총 시간은 0보다 커야 합니다.');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomTimerConfig) return false;
    if (totalSeconds != other.totalSeconds) return false;
    if (intervals.length != other.intervals.length) return false;
    for (int i = 0; i < intervals.length; i++) {
      if (intervals[i] != other.intervals[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(totalSeconds, Object.hashAll(intervals));
}

class CustomTimerState {
  final CustomTimerStatus status;
  final int totalRemainingSeconds;
  final int totalSeconds;
  final int currentIntervalIndex;
  final int intervalElapsedSeconds;
  final int currentSet;
  final List<int> intervals;

  const CustomTimerState({
    required this.status,
    required this.totalRemainingSeconds,
    required this.totalSeconds,
    required this.currentIntervalIndex,
    required this.intervalElapsedSeconds,
    required this.currentSet,
    required this.intervals,
  });

  CustomTimerState copyWith({
    CustomTimerStatus? status,
    int? totalRemainingSeconds,
    int? totalSeconds,
    int? currentIntervalIndex,
    int? intervalElapsedSeconds,
    int? currentSet,
    List<int>? intervals,
  }) => CustomTimerState(
    status: status ?? this.status,
    totalRemainingSeconds: totalRemainingSeconds ?? this.totalRemainingSeconds,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    currentIntervalIndex: currentIntervalIndex ?? this.currentIntervalIndex,
    intervalElapsedSeconds: intervalElapsedSeconds ?? this.intervalElapsedSeconds,
    currentSet: currentSet ?? this.currentSet,
    intervals: intervals ?? this.intervals,
  );

  String get currentIntervalDurationLabel {
    final total = intervals[currentIntervalIndex];
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '$m:${s.toString().padLeft(2, '0')}';
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
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get intervalProgress {
    final total = intervals[currentIntervalIndex];
    if (total == 0) return 0.0;
    return (intervalElapsedSeconds / total).clamp(0.0, 1.0);
  }
}

class CustomTimerNotifier extends StateNotifier<CustomTimerState> {
  CustomTimerNotifier(this._ref, this._config)
    : super(
        CustomTimerState(
          status: CustomTimerStatus.ready,
          totalRemainingSeconds: _config.totalSeconds,
          totalSeconds: _config.totalSeconds,
          currentIntervalIndex: 0,
          intervalElapsedSeconds: 0,
          currentSet: 1,
          intervals: _config.intervals,
        ),
      ) {
    _subscribeToService();
  }

  final Ref _ref;
  final CustomTimerConfig _config;
  KeepAliveLink? _keepAlive;
  StreamSubscription? _tickSub;
  StreamSubscription? _finishedSub;
  bool _acceptServiceEvents = false;

  Future<void> _subscribeToService() async {
    final svc = FlutterBackgroundService();

    _tickSub = svc.on(kEvtTick).listen((data) {
      if (!_acceptServiceEvents || data == null || data['type'] != kTypeCustom) {
        return;
      }
      _applyTick(data);
    });

    _finishedSub = svc.on(kEvtFinished).listen((data) {
      if (!_acceptServiceEvents || data == null || data['type'] != kTypeCustom) {
        return;
      }
      _handleFinished();
    });

    if (await svc.isRunning()) {
      _acceptServiceEvents = true;
      svc.invoke(kCmdGetState, {});
    }
  }

  void _applyTick(Map<String, dynamic> data) {
    if (state.status != CustomTimerStatus.running) {
      _keepAlive ??= _ref.keepAlive();
      state = state.copyWith(status: CustomTimerStatus.running);
    }

    final prevIdx = state.currentIntervalIndex;
    final prevSet = state.currentSet;
    final newIdx = (data['intervalIndex'] as num?)?.toInt() ?? prevIdx;
    final newSet = (data['currentSet'] as num?)?.toInt() ?? prevSet;

    state = state.copyWith(
      totalRemainingSeconds: (data['remaining'] as num).toInt(),
      currentIntervalIndex: newIdx,
      intervalElapsedSeconds:
          (data['intervalElapsed'] as num?)?.toInt() ?? state.intervalElapsedSeconds,
      currentSet: newSet,
    );

    if (newIdx != prevIdx || newSet != prevSet) {
      TimerSoundService.playIntervalStart();
    }
  }

  void _handleFinished() {
    if (state.status != CustomTimerStatus.running) return;
    _acceptServiceEvents = false;
    _keepAlive?.close();
    _keepAlive = null;
    WakelockPlus.disable();
    TimerNotificationService.cancelAll();
    ActiveTimerRegistry.clear();
    state = state.copyWith(
      totalRemainingSeconds: 0,
      status: CustomTimerStatus.finished,
    );
    TimerSoundService.playFinish();
  }

  Future<void> start() async {
    if (state.status == CustomTimerStatus.running) return;

    ActiveTimerRegistry.setActive(
      ActiveTimerRegistry.customKey(_config.totalSeconds, _config.intervals),
    );
    _keepAlive ??= _ref.keepAlive();
    _acceptServiceEvents = true;
    state = state.copyWith(status: CustomTimerStatus.running);
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
      'type': kTypeCustom,
      'totalSeconds': state.totalSeconds,
      'intervals': _config.intervals,
    });

    _scheduleNotifications(DateTime.now());
  }

  void reset() {
    _acceptServiceEvents = false;
    FlutterBackgroundService().invoke(kCmdReset, {});
    unawaited(TimerSoundService.stopAll());
    _keepAlive?.close();
    _keepAlive = null;
    WakelockPlus.disable();
    TimerNotificationService.cancelAll();
    ActiveTimerRegistry.clear();
    state = CustomTimerState(
      status: CustomTimerStatus.ready,
      totalRemainingSeconds: _config.totalSeconds,
      totalSeconds: _config.totalSeconds,
      currentIntervalIndex: 0,
      intervalElapsedSeconds: 0,
      currentSet: 1,
      intervals: _config.intervals,
    );
  }

  void _scheduleNotifications(DateTime virtualStart) {
    final intervals = _config.intervals;
    final boundaries = <int>[];
    int elapsed = 0;
    int idx = 0;
    while (true) {
      elapsed += intervals[idx];
      if (elapsed >= state.totalSeconds) break;
      boundaries.add(elapsed);
      idx = (idx + 1) % intervals.length;
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
    if (state.status != CustomTimerStatus.running) {
      FlutterBackgroundService().invoke(kCmdReset, {});
    }
    WakelockPlus.disable();
    super.dispose();
  }
}

final customTimerProvider = StateNotifierProvider.autoDispose
    .family<CustomTimerNotifier, CustomTimerState, CustomTimerConfig>(
      (ref, config) => CustomTimerNotifier(ref, config),
    );
