import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class TimerSoundService {
  TimerSoundService._();

  static Future<void>? _initFuture;
  static AudioPool? _intervalStartPool;
  static AudioPool? _finishPool;
  static AudioPool? _metronomePool;

  static Future<void> ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  static Future<void> _initialize() async {
    _intervalStartPool = await AudioPool.create(
      source: AssetSource('sounds/timer_start.mp3'),
      maxPlayers: 2,
      minPlayers: 1,
      playerMode: PlayerMode.lowLatency,
    );
    _finishPool = await AudioPool.create(
      source: AssetSource('sounds/timer_finish.mp3'),
      maxPlayers: 2,
      minPlayers: 1,
      playerMode: PlayerMode.lowLatency,
    );
    _metronomePool = await AudioPool.create(
      source: AssetSource('sounds/metronome_tick.mp3'),
      maxPlayers: 4,
      minPlayers: 2,
      playerMode: PlayerMode.lowLatency,
    );
  }

  static void _play(AudioPool? Function() poolLoader) {
    unawaited(() async {
      try {
        await ensureInitialized();
        final pool = poolLoader();
        if (pool != null) {
          await pool.start();
        }
      } catch (_) {
        // 타이머 음향 실패는 화면 동작까지 막지 않도록 무시합니다.
      }
    }());
  }

  static AudioPool? _intervalStartLoader() => _intervalStartPool;

  static AudioPool? _finishLoader() => _finishPool;

  static AudioPool? _metronomeLoader() => _metronomePool;

  static void playIntervalStart() => _play(_intervalStartLoader);

  static void playFinish() => _play(_finishLoader);

  static void playMetronomeTick() => _play(_metronomeLoader);
}
