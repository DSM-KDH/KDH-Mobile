import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String kCmdStart = 'startTimer';
const String kCmdReset = 'resetTimer';
const String kCmdGetState = 'getState';
const String kCmdGetActiveTimer = 'getActiveTimer';

const String kEvtTick = 'timerTick';
const String kEvtFinished = 'timerFinished';
const String kEvtBeat = 'beat';
const String kEvtActiveTimer = 'activeTimer';

const String kTypeInterval = 'interval';
const String kTypeCustom = 'custom';
const String kTypeMetronome = 'metronome';

const String _fgChannelId = 'kdh_timer_fg';
const int _fgNotifId = 9901;

Future<void> initBackgroundTimerService() async {
  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _fgChannelId,
          '타이머 실행 중',
          description: '운동 타이머가 백그라운드에서 실행 중입니다.',
          importance: Importance.low,
          playSound: false,
        ),
      );

  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: _fgChannelId,
      initialNotificationTitle: 'KDH 타이머',
      initialNotificationContent: '준비 중...',
      foregroundServiceNotificationId: _fgNotifId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: _onStart,
      onBackground: _onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) {
  Timer? mainTimer;
  Timer? beatTimer;
  DateTime? virtualStart;
  String timerType = '';
  int totalSeconds = 0;
  List<int> intervals = [];
  int bpm = 0;

  void updateNotif(String content) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(title: 'KDH 타이머', content: content);
    }
  }

  String fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, int> intervalPos(int elapsed) {
    int consumed = 0;
    int setNum = 1;
    int idx = 0;
    while (true) {
      final dur = intervals[idx];
      if (consumed + dur > elapsed) {
        return {
          'intervalIndex': idx,
          'intervalElapsed': elapsed - consumed,
          'currentSet': setNum,
        };
      }
      consumed += dur;
      final next = (idx + 1) % intervals.length;
      if (next == 0) setNum++;
      idx = next;
    }
  }

  void tick() {
    if (virtualStart == null) return;
    final elapsed = DateTime.now().difference(virtualStart!).inSeconds;
    final remaining = totalSeconds - elapsed;

    if (remaining <= 0) {
      mainTimer?.cancel();
      beatTimer?.cancel();
      service.invoke(kEvtFinished, {'type': timerType});
      updateNotif('완료! 수고하셨습니다 💪');
      Future.delayed(const Duration(seconds: 3), service.stopSelf);
      return;
    }

    final data = <String, dynamic>{
      'type': timerType,
      'remaining': remaining,
      'elapsed': elapsed,
      'totalSeconds': totalSeconds,
    };

    if (timerType != kTypeMetronome && intervals.isNotEmpty) {
      data.addAll(intervalPos(elapsed));
    }

    service.invoke(kEvtTick, data);
    updateNotif('남은 시간  ${fmt(remaining)}');
  }

  service.invoke('ready', {});

  service.on(kCmdStart).listen((data) {
    if (data == null) return;
    mainTimer?.cancel();
    beatTimer?.cancel();

    timerType = data['type'] as String;
    totalSeconds = (data['totalSeconds'] as num).toInt();
    intervals = (data['intervals'] as List?)?.cast<int>() ?? [];
    bpm = (data['bpm'] as num?)?.toInt() ?? 0;
    virtualStart = DateTime.now();

    mainTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());

    if (timerType == kTypeMetronome && bpm > 0) {
      final beatMs = (60000 / bpm).round();
      beatTimer = Timer.periodic(
        Duration(milliseconds: beatMs),
        (_) => service.invoke(kEvtBeat, {}),
      );
    }

    updateNotif('남은 시간  ${fmt(totalSeconds)}');
  });

  service.on(kCmdGetState).listen((_) => tick());

  service.on(kCmdGetActiveTimer).listen((_) {
    if (virtualStart == null) {
      service.invoke(kEvtActiveTimer, {'running': false});
      return;
    }
    service.invoke(kEvtActiveTimer, {
      'running': true,
      'type': timerType,
      'totalSeconds': totalSeconds,
      'intervals': intervals,
      'bpm': bpm,
    });
  });

  service.on(kCmdReset).listen((_) {
    mainTimer?.cancel();
    beatTimer?.cancel();
    virtualStart = null;
    service.stopSelf();
  });
}
