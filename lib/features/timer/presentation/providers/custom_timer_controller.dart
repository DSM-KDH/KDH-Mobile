import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/features/timer/presentation/services/timer_sound_service.dart';

enum CustomTimerStatus { ready, running, finished }

class CustomTimerConfig {
  final List<int> intervals;
  final int totalSeconds;

   CustomTimerConfig({
    required List<int> intervals,
    required this.totalSeconds,
  }) : intervals = List.unmodifiable(intervals) {
    if (this.intervals.isEmpty) {
      throw ArgumentError('인터벌이 비어 있으면 안됩니다.');
    }
    if (this.intervals.any((v) => v <= 0)) {
      throw ArgumentError('모든 인터벌은 0보다 커야 합니다.');
    }
    if (totalSeconds <= 0) {
      throw ArgumentError('총 시간은 0보다 커야 합니다.');
    }
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
    intervalElapsedSeconds:
        intervalElapsedSeconds ?? this.intervalElapsedSeconds,
    currentSet: currentSet ?? this.currentSet,
    intervals: intervals ?? this.intervals,
  );

  String get currentIntervalDurationLabel {
    final total = intervals[currentIntervalIndex];
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
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
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get intervalProgress {
    final total = intervals[currentIntervalIndex];
    if (total == 0) return 0.0;
    return (intervalElapsedSeconds / total).clamp(0.0, 1.0);
  }
}

class CustomTimerNotifier extends StateNotifier<CustomTimerState> {
  CustomTimerNotifier(this._config)
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
      );

  final CustomTimerConfig _config;
  Timer? _timer;

  void start() {
    if (state.status == CustomTimerStatus.running) return;
    state = state.copyWith(status: CustomTimerStatus.running);
    TimerSoundService.playIntervalStart();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void reset() {
    _timer?.cancel();
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

  void _tick() {
    final newTotalRemaining = state.totalRemainingSeconds - 1;

    if (newTotalRemaining <= 0) {
      _timer?.cancel();
      state = state.copyWith(
        totalRemainingSeconds: 0,
        intervalElapsedSeconds: 0,
        status: CustomTimerStatus.finished,
      );
      TimerSoundService.playFinish();
      return;
    }

    final newIntervalElapsed = state.intervalElapsedSeconds + 1;
    final intervalDuration = state.intervals[state.currentIntervalIndex];

    int newIntervalIndex = state.currentIntervalIndex;
    int newIntervalElapsedSecs = newIntervalElapsed;
    int newSet = state.currentSet;

    if (newIntervalElapsed >= intervalDuration) {
      newIntervalIndex =
          (state.currentIntervalIndex + 1) % state.intervals.length;
      newIntervalElapsedSecs = 0;
      if (newIntervalIndex == 0) newSet++;
      TimerSoundService.playIntervalStart();
    }

    state = state.copyWith(
      totalRemainingSeconds: newTotalRemaining,
      intervalElapsedSeconds: newIntervalElapsedSecs,
      currentIntervalIndex: newIntervalIndex,
      currentSet: newSet,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final customTimerProvider = StateNotifierProvider.autoDispose
    .family<CustomTimerNotifier, CustomTimerState, CustomTimerConfig>(
      (ref, config) => CustomTimerNotifier(config),
    );
