import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class TimerSoundService {
  TimerSoundService._();

  static Future<void>? _initFuture;
  static AudioPlayer? _intervalStartPlayer;
  static AudioPlayer? _finishPlayer;
  static AudioPlayer? _metronomePlayer;

  static Future<void> ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  static Future<void> _initialize() async {
    _intervalStartPlayer = await _createPlayer('sounds/timer_start.mp3');
    _finishPlayer = await _createPlayer('sounds/timer_finish.mp3');
    _metronomePlayer = await _createPlayer('sounds/metronome_tick.mp3');
  }

  static Future<AudioPlayer> _createPlayer(String asset) async {
    final player = AudioPlayer();
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setSource(AssetSource(asset));
    return player;
  }

  static void _play(AudioPlayer? Function() playerLoader) {
    unawaited(() async {
      try {
        await ensureInitialized();
        final player = playerLoader();
        if (player == null) return;
        await player.stop();
        await player.resume();
      } catch (_) {
        // 타이머 음향 실패는 화면 동작까지 막지 않도록 무시합니다.
      }
    }());
  }

  static Future<void> stopAll() async {
    try {
      await ensureInitialized();
      await Future.wait([
        if (_intervalStartPlayer != null) _intervalStartPlayer!.stop(),
        if (_finishPlayer != null) _finishPlayer!.stop(),
        if (_metronomePlayer != null) _metronomePlayer!.stop(),
      ]);
    } catch (_) {
      // 정지 실패는 타이머 상태 복구를 막지 않도록 무시합니다.
    }
  }

  static AudioPlayer? _intervalStartLoader() => _intervalStartPlayer;

  static AudioPlayer? _finishLoader() => _finishPlayer;

  static AudioPlayer? _metronomeLoader() => _metronomePlayer;

  static void playIntervalStart() => _play(_intervalStartLoader);

  static void playFinish() => _play(_finishLoader);

  static void playMetronomeTick() => _play(_metronomeLoader);
}
