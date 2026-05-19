import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:live_activities/live_activities.dart';

/// AI 루틴 생성 중 Live Activity (iOS) / 진행 알림 (Android) 관리
class RoutineLiveActivityService {
  static const _appGroupId        = 'group.com.kdh.mobile';
  static const _androidNotifId    = 9900;
  static const _androidChannelId  = 'routine_creation';
  /// 평균 생성 예상 시간(초) — 진행률 시뮬레이션 기준
  static const _estimatedTotal    = 40;

  final _liveActivities      = LiveActivities();
  final _localNotifications  = FlutterLocalNotificationsPlugin();

  String? _activityId;
  Timer?  _timer;
  int     _elapsed = 0;

  // ── 초기화 ──────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (Platform.isIOS) {
      await _liveActivities.init(appGroupId: _appGroupId);
    } else if (Platform.isAndroid) {
      await _initAndroid();
    }
  }

  Future<void> _initAndroid() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(initSettings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _androidChannelId,
            'AI 루틴 생성',
            description: 'AI 루틴 생성 진행 상황',
            importance: Importance.low,
          ),
        );
  }

  // ── 생성 시작 ────────────────────────────────────────────────────────────
  Future<void> startCreation() async {
    _elapsed = 0;
    final data = _buildData(progress: 0.0, elapsed: 0);

    if (Platform.isIOS) {
      _activityId = await _liveActivities.createActivity(data);
    } else if (Platform.isAndroid) {
      await _showAndroidNotif(progress: 0, remaining: _estimatedTotal);
    }

    // 1초마다 진행률 업데이트
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  // ── 1초 틱 ──────────────────────────────────────────────────────────────
  Future<void> _onTick() async {
    _elapsed++;
    final progress  = _simulateProgress(_elapsed);
    final remaining = _estimateRemaining(_elapsed, progress);
    final data      = _buildData(progress: progress, elapsed: _elapsed);

    if (Platform.isIOS) {
      if (_activityId != null) {
        await _liveActivities.updateActivity(_activityId!, data);
      }
    } else if (Platform.isAndroid) {
      await _showAndroidNotif(
        progress: (progress * 100).round(),
        remaining: remaining,
      );
    }
  }

  // ── 생성 성공 ────────────────────────────────────────────────────────────
  Future<void> notifySuccess() async {
    _stopTimer();
    if (Platform.isIOS) {
      await _updateAndEnd(
        status: 'success',
        title: '루틴 생성 완료!',
        message: '맞춤 루틴이 준비됐어요 🎉',
        progress: 1.0,
        remaining: 0,
      );
    } else if (Platform.isAndroid) {
      await _showAndroidNotif(progress: 100, remaining: 0, done: true);
    }
  }

  // ── 생성 실패 ────────────────────────────────────────────────────────────
  Future<void> notifyFailure() async {
    _stopTimer();
    if (Platform.isIOS) {
      await _updateAndEnd(
        status: 'failure',
        title: '생성 실패',
        message: '루틴 생성에 실패했어요. 다시 시도해주세요',
        progress: _simulateProgress(_elapsed),
        remaining: 0,
      );
    } else if (Platform.isAndroid) {
      await _localNotifications.cancel(_androidNotifId);
    }
  }

  // ── 내부 ─────────────────────────────────────────────────────────────────
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _updateAndEnd({
    required String status,
    required String title,
    required String message,
    required double progress,
    required int remaining,
  }) async {
    if (_activityId == null) return;
    await _liveActivities.updateActivity(_activityId!, {
      'status': status,
      'title': title,
      'message': message,
      'progress': progress,
      'remainingSeconds': remaining,
    });
    await Future.delayed(const Duration(seconds: 3));
    await _liveActivities.endActivity(_activityId!);
    _activityId = null;
  }

  Future<void> _showAndroidNotif({
    required int progress,
    required int remaining,
    bool done = false,
  }) async {
    final title  = done ? '루틴 생성 완료!' : 'AI 루틴 생성 중... $progress%';
    final body   = done
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
          importance: Importance.low,
          priority: Priority.low,
          ongoing: !done,
          autoCancel: done,
          showProgress: !done,
          indeterminate: false,
          maxProgress: 100,
          progress: progress,
        ),
      ),
    );
  }

  /// data Map 빌드 (iOS Live Activity / Android 공통)
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

  /// 지수 감쇄 곡선으로 진행률 시뮬레이션 (최대 90%로 제한)
  static double _simulateProgress(int elapsed) {
    const k = 0.07;
    return 0.90 * (1.0 - math.exp(-k * elapsed));
  }

  /// 경과 시간 / 진행률 기반 남은 시간 추정
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
