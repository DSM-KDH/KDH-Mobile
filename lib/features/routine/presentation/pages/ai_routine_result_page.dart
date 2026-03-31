import 'package:flutter/material.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_failure_view.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_loading_view.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_success_view.dart';

enum _ResultState { loading, success, failure }

class AiRoutineResultPage extends StatefulWidget {
  const AiRoutineResultPage({super.key});

  @override
  State<AiRoutineResultPage> createState() => _AiRoutineResultPageState();
}

class _AiRoutineResultPageState extends State<AiRoutineResultPage> {
  _ResultState _state = _ResultState.loading;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _state = _ResultState.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _ResultState.loading => const AiRoutineLoadingView(),
      _ResultState.success => const AiRoutineSuccessView(),
      _ResultState.failure => const AiRoutineFailureView(),
    };
  }
}
