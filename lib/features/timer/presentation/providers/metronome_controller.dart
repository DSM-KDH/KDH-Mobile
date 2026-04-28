import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/features/timer/presentation/services/timer_sound_service.dart';

enum MetronomeStatus { ready, running, finished }

class MetronomeConfig {
  final int bpm;
  final int totalSeconds;

   MetronomeConfig({required this.bpm, required this.totalSeconds}) {
    if (bpm <= 0) throw ArgumentError('BPM은 0보다 커야 합니다.');
    if (totalSeconds <= 0) throw ArgumentError('최종 시간은 0보다 커야 합니다.');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetronomeConfig &&
          bpm == other.bpm &&
          totalSeconds == other.totalSeconds;

  @override
  int get hashCode => Object.hash(bpm, totalSeconds);
}

class MetronomeState {
  final MetronomeStatus status;
  final int totalSeconds;
  final int elapsedSeconds;
  final int bpm;

  const MetronomeState({
    required this.status,
    required this.totalSeconds,
    required this.elapsedSeconds,
    required this.bpm,
  });

  MetronomeState copyWith({
    MetronomeStatus? status,
    int? totalSeconds,
    int? elapsedSeconds,
    int? bpm,
  }) => MetronomeState(
    status: status ?? this.status,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    bpm: bpm ?? this.bpm,
  );

  double get progress {
    if (totalSeconds == 0) return 0.0;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  String get totalDurationLabel {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get elapsedLabel {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class MetronomeNotifier extends StateNotifier<MetronomeState> {
  MetronomeNotifier(this._config)
    : super(
        MetronomeState(
          status: MetronomeStatus.ready,
          totalSeconds: _config.totalSeconds,
          elapsedSeconds: 0,
          bpm: _config.bpm,
        ),
      );

  final MetronomeConfig _config;
  Timer? _timer;
  Timer? _beatTimer;

  void start() {
    if (state.status == MetronomeStatus.running) return;
    state = state.copyWith(status: MetronomeStatus.running);
    TimerSoundService.playIntervalStart();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    final beatMs = (60000 / _config.bpm).round();
    _beatTimer = Timer.periodic(
      Duration(milliseconds: beatMs),
      (_) => TimerSoundService.playMetronomeTick(),
    );
  }

  void reset() {
    _timer?.cancel();
    _beatTimer?.cancel();
    state = MetronomeState(
      status: MetronomeStatus.ready,
      totalSeconds: _config.totalSeconds,
      elapsedSeconds: 0,
      bpm: _config.bpm,
    );
  }

  void _tick() {
    final newElapsed = state.elapsedSeconds + 1;
    if (newElapsed >= state.totalSeconds) {
      _timer?.cancel();
      _beatTimer?.cancel();
      state = state.copyWith(
        elapsedSeconds: state.totalSeconds,
        status: MetronomeStatus.finished,
      );
      TimerSoundService.playFinish();
      return;
    }
    state = state.copyWith(elapsedSeconds: newElapsed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _beatTimer?.cancel();
    super.dispose();
  }
}

final metronomeProvider = StateNotifierProvider.autoDispose
    .family<MetronomeNotifier, MetronomeState, MetronomeConfig>(
      (ref, config) => MetronomeNotifier(config),
    );
