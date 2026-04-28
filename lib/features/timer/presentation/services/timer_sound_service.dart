import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class TimerSoundService {
  TimerSoundService._();

  static AudioPlayer? _beep;
  static AudioPlayer? _finish;
  static AudioPlayer? _metronome;

  static AudioPlayer _getBeep() => _beep ??= AudioPlayer();

  static AudioPlayer _getFinish() => _finish ??= AudioPlayer();

  static AudioPlayer _getMetronome() => _metronome ??= AudioPlayer();

  static void playIntervalStart() {
    unawaited(
      _getBeep().play(AssetSource('sounds/timer_start.mp3')).catchError((_) {}),
    );
  }

  static void playFinish() {
    unawaited(
      _getFinish()
          .play(AssetSource('sounds/timer_finish.mp3'))
          .catchError((_) {}),
    );
  }

  static void playMetronomeTick() {
    unawaited(
      _getMetronome()
          .play(AssetSource('sounds/metronome_tick.mp3'))
          .catchError((_) {}),
    );
  }
}
