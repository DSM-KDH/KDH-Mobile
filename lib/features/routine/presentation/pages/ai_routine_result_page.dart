import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/services/fcm_service.dart';
import 'package:kdh_mobile/core/services/routine_live_activity_service.dart';
import 'package:kdh_mobile/features/routine/presentation/providers/ai_routine_wizard_provider.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_failure_view.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_loading_view.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_success_view.dart';

enum _ResultState { loading, success, failure }

const _kDefaultFailureMessage = 'AI로 맞춤 루틴 생성을\n실패했습니다';

class AiRoutineResultPage extends ConsumerStatefulWidget {
  const AiRoutineResultPage({super.key});

  @override
  ConsumerState<AiRoutineResultPage> createState() =>
      _AiRoutineResultPageState();
}

class _AiRoutineResultPageState extends ConsumerState<AiRoutineResultPage> {
  _ResultState _state = _ResultState.loading;
  String _failureMessage = _kDefaultFailureMessage;

  final _liveActivity = RoutineLiveActivityService();

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    // Live Activity / Android 알림 시작
    await _liveActivity.init();
    await _liveActivity.startCreation();

    // 생성 완료 푸시 알림을 받기 위해 FCM 토큰을 함께 전송
    final fcmToken = await FcmService.ensureToken();
    final success = await ref
        .read(aiRoutineWizardProvider.notifier)
        .submit(fcmToken: fcmToken);
    if (!mounted) return;

    if (success) {
      await _liveActivity.notifySuccess();
      setState(() => _state = _ResultState.success);
      return;
    }

    await _liveActivity.notifyFailure();
    setState(() {
      _failureMessage =
          ref.read(aiRoutineWizardProvider.notifier).submitError ??
          _kDefaultFailureMessage;
      _state = _ResultState.failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _ResultState.loading => const AiRoutineLoadingView(),
      _ResultState.success => AiRoutineSuccessView(
        onGoHome: () {
          ref.read(aiRoutineWizardProvider.notifier).reset();
        },
      ),
      _ResultState.failure => AiRoutineFailureView(message: _failureMessage),
    };
  }
}
