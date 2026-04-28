import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/features/timer/presentation/services/timer_sound_service.dart';

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
  IntervalTimerNotifier(int totalSeconds)
    : super(
        IntervalTimerState(
          status: TimerStatus.ready,
          totalRemainingSeconds: totalSeconds,
          totalSeconds: totalSeconds,
          currentIntervalIndex: 0,
          intervalElapsedSeconds: 0,
          currentSet: 1,
        ),
      );

  Timer? _timer;

  void start() {
    if (state.status == TimerStatus.running) return;
    state = state.copyWith(status: TimerStatus.running);
    TimerSoundService.playIntervalStart();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void reset() {
    _timer?.cancel();
    state = IntervalTimerState(
      status: TimerStatus.ready,
      totalRemainingSeconds: state.totalSeconds,
      totalSeconds: state.totalSeconds,
      currentIntervalIndex: 0,
      intervalElapsedSeconds: 0,
      currentSet: 1,
    );
  }

  void _tick() {
    final newTotalRemaining = state.totalRemainingSeconds - 1;

    if (newTotalRemaining <= 0) {
      _timer?.cancel();
      state = state.copyWith(
        totalRemainingSeconds: 0,
        intervalElapsedSeconds: 0,
        status: TimerStatus.finished,
      );
      TimerSoundService.playFinish();
      return;
    }

    final newIntervalElapsed = state.intervalElapsedSeconds + 1;
    final intervalDuration = kIntervalDurations[state.currentIntervalIndex];

    int newIntervalIndex = state.currentIntervalIndex;
    int newIntervalElapsedSecs = newIntervalElapsed;
    int newSet = state.currentSet;

    if (newIntervalElapsed >= intervalDuration) {
      newIntervalIndex = (state.currentIntervalIndex + 1) % 3;
      newIntervalElapsedSecs = 0;
      if (newIntervalIndex == 0) {
        newSet++;
      }
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

final intervalTimerProvider = StateNotifierProvider.autoDispose
    .family<IntervalTimerNotifier, IntervalTimerState, int>(
      (ref, totalSeconds) => IntervalTimerNotifier(totalSeconds),
    );
