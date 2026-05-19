import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RoutineLiveActivityService {
  static const _channel          = MethodChannel('com.kdh.mobile/live_activity');
  static const _androidNotifId   = 9900;
  static const _androidChannelId = 'routine_creation';
  static const _estimatedTotal   = 40;

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Timer? _timer;
  int    _elapsed = 0;

  Future<void> init() async {
    if (Platform.isAndroid) {
      await _initAndroid();
    }
  }

  Future<void> _initAndroid() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(initSettings);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        'AI 루틴 생성',
        description: 'AI 루틴 생성 진행 상황',
        importance: Importance.high,
      ),
    );
  }

  Future<void> startCreation() async {
    _elapsed = 0;
    final data = _buildData(progress: 0.0, elapsed: 0);

    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod('startActivity', data);
      } catch (_) {}
    } else if (Platform.isAndroid) {
      await _showAndroidNotif(progress: 0, remaining: _estimatedTotal);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  Future<void> _onTick() async {
    _elapsed++;
    final progress  = _simulateProgress(_elapsed);
    final remaining = _estimateRemaining(_elapsed, progress);
    final data      = _buildData(progress: progress, elapsed: _elapsed);

    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod('updateActivity', data);
      } catch (_) {}
    } else if (Platform.isAndroid) {
      await _showAndroidNotif(
        progress: (progress * 100).round(),
        remaining: remaining,
      );
    }
  }

  Future<void> notifySuccess() async {
    _stopTimer();
    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod('updateActivity', {
          'status': 'success',
          'title': '루틴 생성 완료!',
          'message': '맞춤 루틴이 준비됐어요 🎉',
          'progress': 1.0,
          'remainingSeconds': 0,
        });
        await Future.delayed(const Duration(seconds: 3));
        await _channel.invokeMethod('endActivity');
      } catch (_) {}
    } else if (Platform.isAndroid) {
      await _showAndroidNotif(progress: 100, remaining: 0, done: true);
    }
  }


  Future<void> notifyFailure() async {
    _stopTimer();
    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod('updateActivity', {
          'status': 'failure',
          'title': '생성 실패',
          'message': '루틴 생성에 실패했어요. 다시 시도해주세요',
          'progress': _simulateProgress(_elapsed),
          'remainingSeconds': 0,
        });
        await Future.delayed(const Duration(seconds: 3));
        await _channel.invokeMethod('endActivity');
      } catch (_) {}
    } else if (Platform.isAndroid) {
      await _localNotifications.cancel(_androidNotifId);
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _showAndroidNotif({
    required int progress,
    required int remaining,
    bool done = false,
  }) async {
    final title = done ? '루틴 생성 완료!' : 'AI 루틴 생성 중... $progress%';
    final body  = done
        ? '맞춤 루틴이 준비됐어요. 앱을 열어 확인하세요'
        : (remaining > 0 ? '약 ${_formatRemaining(remaining)} 남았어요' : '거의 완료됐어요');

    await _localNotifications.show(
      _androidNotifId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          'AI 루틴 생성',
          channelDescription: 'AI 루틴 생성 진행 상황',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: !done,
          autoCancel: done,
          showProgress: !done,
          indeterminate: false,
          maxProgress: 100,
          progress: progress,
          onlyAlertOnce: true,
        ),
      ),
    );
  }

  Map<String, dynamic> _buildData({
    required double progress,
    required int elapsed,
  }) {
    final remaining = _estimateRemaining(elapsed, progress);
    return {
      'status': 'loading',
      'title': 'AI 루틴 생성 중',
      'message': remaining > 0
          ? '약 ${_formatRemaining(remaining)} 남았어요'
          : '거의 완료됐어요',
      'progress': progress,
      'remainingSeconds': remaining,
    };
  }

  static double _simulateProgress(int elapsed) {
    const k = 0.07;
    return 0.90 * (1.0 - math.exp(-k * elapsed));
  }

  static int _estimateRemaining(int elapsed, double progress) {
    if (progress <= 0.01) return _estimatedTotal;
    final estimated = (elapsed / progress * 1.05).round();
    return (estimated - elapsed).clamp(0, 120);
  }

  static String _formatRemaining(int seconds) {
    if (seconds < 60) return '$seconds초';
    final m = seconds ~/ 60, s = seconds % 60;
    return s == 0 ? '$m분' : '$m분 $s초';
  }
}
