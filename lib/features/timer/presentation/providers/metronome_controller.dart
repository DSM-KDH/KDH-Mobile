import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/services/background_timer_service.dart';
import 'package:kdh_mobile/core/services/timer_notification_service.dart';
import 'package:kdh_mobile/features/timer/presentation/services/active_timer_registry.dart';
import 'package:kdh_mobile/features/timer/presentation/services/timer_sound_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
      other is MetronomeConfig && bpm == other.bpm && totalSeconds == other.totalSeconds;

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
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get elapsedLabel {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class MetronomeNotifier extends StateNotifier<MetronomeState> {
  MetronomeNotifier(this._ref, this._config)
    : super(
        MetronomeState(
          status: MetronomeStatus.ready,
          totalSeconds: _config.totalSeconds,
          elapsedSeconds: 0,
          bpm: _config.bpm,
        ),
      ) {
    _subscribeToService();
  }

  final Ref _ref;
  final MetronomeConfig _config;
  KeepAliveLink? _keepAlive;
  StreamSubscription? _tickSub;
  StreamSubscription? _finishedSub;
  StreamSubscription? _beatSub;

  Future<void> _subscribeToService() async {
    final svc = FlutterBackgroundService();

    _tickSub = svc.on(kEvtTick).listen((data) {
      if (data == null || data['type'] != kTypeMetronome) return;
      _applyTick(data);
    });

    _finishedSub = svc.on(kEvtFinished).listen((data) {
      if (data == null || data['type'] != kTypeMetronome) return;
      _handleFinished();
    });

    _beatSub = svc.on(kEvtBeat).listen((_) {
      TimerSoundService.playMetronomeTick();
    });

    if (await svc.isRunning()) svc.invoke(kCmdGetState, {});
  }

  void _applyTick(Map<String, dynamic> data) {
    if (state.status != MetronomeStatus.running) {
      _keepAlive ??= _ref.keepAlive();
      state = state.copyWith(status: MetronomeStatus.running);
    }
    state = state.copyWith(
      elapsedSeconds: (data['elapsed'] as num).toInt(),
    );
  }

  void _handleFinished() {
    if (state.status != MetronomeStatus.running) return;
    _keepAlive?.close();
    _keepAlive = null;
    WakelockPlus.disable();
    TimerNotificationService.cancelAll();
    ActiveTimerRegistry.clear();
    state = state.copyWith(
      elapsedSeconds: state.totalSeconds,
      status: MetronomeStatus.finished,
    );
    TimerSoundService.playFinish();
  }

  Future<void> start() async {
    if (state.status == MetronomeStatus.running) return;

    ActiveTimerRegistry.setActive(
      ActiveTimerRegistry.metronomeKey(_config.totalSeconds, _config.bpm),
    );
    _keepAlive ??= _ref.keepAlive();
    state = state.copyWith(status: MetronomeStatus.running);
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
      'type': kTypeMetronome,
      'totalSeconds': _config.totalSeconds,
      'bpm': _config.bpm,
    });

    // 메트로놈은 완료 알림만
    TimerNotificationService.schedule(
      virtualStart: DateTime.now(),
      intervalBoundaries: const [],
      totalSeconds: _config.totalSeconds,
    );
  }

  void reset() {
    FlutterBackgroundService().invoke(kCmdReset, {});
    _keepAlive?.close();
    _keepAlive = null;
    WakelockPlus.disable();
    TimerNotificationService.cancelAll();
    ActiveTimerRegistry.clear();
    state = MetronomeState(
      status: MetronomeStatus.ready,
      totalSeconds: _config.totalSeconds,
      elapsedSeconds: 0,
      bpm: _config.bpm,
    );
  }

  @override
  void dispose() {
    _tickSub?.cancel();
    _finishedSub?.cancel();
    _beatSub?.cancel();
    if (state.status != MetronomeStatus.running) {
      FlutterBackgroundService().invoke(kCmdReset, {});
    }
    WakelockPlus.disable();
    super.dispose();
  }
}

final metronomeProvider = StateNotifierProvider.autoDispose
    .family<MetronomeNotifier, MetronomeState, MetronomeConfig>(
      (ref, config) => MetronomeNotifier(ref, config),
    );
