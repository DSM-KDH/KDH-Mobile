import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/services/fcm_service.dart';
import 'package:kdh_mobile/core/services/routine_live_activity_service.dart';
import 'package:kdh_mobile/features/routine/presentation/providers/ai_routine_wizard_provider.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_failure_view.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_loading_view.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_success_view.dart';

// generating: 서버에서 생성 진행 중 (POST 접수 ~ 완료 푸시 전)
enum _ResultState { generating, success, failure }

const _kDefaultFailureMessage = 'AI로 맞춤 루틴 생성을\n실패했습니다';

class AiRoutineResultPage extends ConsumerStatefulWidget {
  const AiRoutineResultPage({super.key});

  @override
  ConsumerState<AiRoutineResultPage> createState() =>
      _AiRoutineResultPageState();
}

class _AiRoutineResultPageState extends ConsumerState<AiRoutineResultPage> {
  _ResultState _state = _ResultState.generating;
  String _failureMessage = _kDefaultFailureMessage;

  final _liveActivity = RoutineLiveActivityService();
  StreamSubscription<RemoteMessage>? _fcmSub;

  @override
  void initState() {
    super.initState();
    _listenForCompletion();
    _startGeneration();
  }

  @override
  void dispose() {
    _fcmSub?.cancel();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    // Live Activity / Android 알림 시작
    await _liveActivity.init();
    await _liveActivity.startCreation();

    // 생성 완료 푸시를 받기 위해 FCM 토큰을 함께 전송
    final fcmToken = await FcmService.ensureToken();
    final accepted = await ref
        .read(aiRoutineWizardProvider.notifier)
        .submit(fcmToken: fcmToken);
    if (!mounted) return;

    // POST 자체가 실패하면(검증/네트워크 오류) 즉시 실패 처리
    if (!accepted) {
      await _liveActivity.notifyFailure();
      setState(() {
        _failureMessage =
            ref.read(aiRoutineWizardProvider.notifier).submitError ??
            _kDefaultFailureMessage;
        _state = _ResultState.failure;
      });
      return;
    }
    // 접수 성공 → 서버 생성 진행 중. 완료 푸시(FCM)를 기다린다.
  }

  /// 포그라운드에서 생성 완료/실패 FCM이 오면 화면을 전환한다.
  void _listenForCompletion() {
    _fcmSub = FcmService.onForegroundMessage.listen((message) async {
      if (!mounted) return;
      final status = (message.data['status'] ?? '').toString().toUpperCase();

      if (status == 'COMPLETED') {
        await _liveActivity.notifySuccess();
        if (!mounted) return;
        setState(() => _state = _ResultState.success);
      } else if (status == 'FAILED') {
        await _liveActivity.notifyFailure();
        if (!mounted) return;
        setState(() {
          _failureMessage = _kDefaultFailureMessage;
          _state = _ResultState.failure;
        });
      }
    });
  }

  void _exitToHome() {
    ref.read(aiRoutineWizardProvider.notifier).reset();
    context.go(RouterPath.home);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _ResultState.generating => AiRoutineLoadingView(
        message: 'AI로 맞춤 루틴 짜는 중...',
        onExit: _exitToHome,
      ),
      _ResultState.success => AiRoutineSuccessView(
        onGoHome: () {
          ref.read(aiRoutineWizardProvider.notifier).reset();
        },
      ),
      _ResultState.failure => AiRoutineFailureView(message: _failureMessage),
    };
  }
}
