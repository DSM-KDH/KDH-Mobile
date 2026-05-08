import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _androidChannel = AndroidNotificationDetails(
  'kdh_timer',
  '타이머',
  channelDescription: '운동 타이머 인터벌 전환 알림',
  importance: Importance.high,
  priority: Priority.high,
  playSound: true,
);

const _iosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentSound: true,
);

const _notifDetails = NotificationDetails(
  android: _androidChannel,
  iOS: _iosDetails,
);

class TimerNotificationService {
  TimerNotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true, badge: false);
  }

  static Future<void> schedule({
    required DateTime virtualStart,
    required List<int> intervalBoundaries,
    required int totalSeconds,
  }) async {
    await cancelAll();

    final now = DateTime.now();
    int id = 1;

    for (final boundary in intervalBoundaries) {
      final fireAt = virtualStart.add(Duration(seconds: boundary));
      if (fireAt.isAfter(now)) {
        await _zonedSchedule(id++, fireAt, '구간 전환', '다음 구간이 시작됩니다!');
      }
    }

    final finishAt = virtualStart.add(Duration(seconds: totalSeconds));
    if (finishAt.isAfter(now)) {
      await _zonedSchedule(0, finishAt, '타이머 완료', '운동 완료! 수고하셨습니다 💪');
    }
  }

  static Future<void> _zonedSchedule(
    int id,
    DateTime time,
    String title,
    String body,
  ) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
