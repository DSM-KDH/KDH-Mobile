import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class TimerSoundService {
  TimerSoundService._();

  static void _play(String asset) {
    final player = AudioPlayer();
    unawaited(
      player
          .play(AssetSource(asset))
          .then((_) => player.dispose())
          .catchError((_) => player.dispose()),
    );
  }

  static void playIntervalStart() => _play('sounds/timer_start.mp3');

  static void playFinish() => _play('sounds/timer_finish.mp3');

  static void playMetronomeTick() => _play('sounds/metronome_tick.mp3');
}
