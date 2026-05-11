import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/features/routine/data/models/ai_routine_wizard_data.dart';
import 'package:kdh_mobile/features/routine/data/repositories/ai_routine_repository.dart';
import 'package:kdh_mobile/features/routine/data/repositories/ai_routine_repository_impl.dart';

final _aiRoutineRepoProvider = Provider<AiRoutineRepository>(
  (ref) => AiRoutineRepositoryImpl(ref.watch(dioProvider)),
);

enum AiRoutineSubmitStatus { idle, loading, success, failure }

class AiRoutineWizardNotifier extends StateNotifier<AiRoutineWizardData> {
  AiRoutineWizardNotifier(this._repository)
    : super(const AiRoutineWizardData());

  final AiRoutineRepository _repository;
  Future<bool>? _pendingSubmit;

  AiRoutineSubmitStatus submitStatus = AiRoutineSubmitStatus.idle;
  String? submitError;

  void setGoal({
    required int goal,
    double? targetWeight,
    Set<String> selectedMuscles = const {},
  }) {
    state = AiRoutineWizardData(
      goal: goal,
      targetWeight: targetWeight,
      selectedMuscles: selectedMuscles,
    );
  }

  void setPerformanceLevel(int level) {
    state = state.copyWith(performanceLevel: level);
  }

  void setSchedule({
    required int weeks,
    required double hours,
    required Set<int> selectedDays,
  }) {
    state = state.copyWith(
      weeks: weeks,
      hours: hours,
      selectedDays: selectedDays,
    );
  }

  void setExerciseTypes(Set<int> types) {
    state = state.copyWith(exerciseTypes: types);
  }

  void setPlacesAndEquipment({
    required Set<int> places,
    required Set<String> equipment,
  }) {
    state = state.copyWith(places: places, equipment: equipment);
  }

  Future<bool> submit({String? fcmToken}) async {
    final pendingSubmit = _pendingSubmit;
    if (pendingSubmit != null) {
      return pendingSubmit;
    }

    final future = _submitInternal(fcmToken: fcmToken);
    _pendingSubmit = future;
    future.whenComplete(() {
      if (identical(_pendingSubmit, future)) {
        _pendingSubmit = null;
      }
    });
    return future;
  }

  Future<bool> _submitInternal({String? fcmToken}) async {
    submitStatus = AiRoutineSubmitStatus.loading;
    submitError = null;

    try {
      await _repository.createRoutine(state, fcmToken: fcmToken);
      submitStatus = AiRoutineSubmitStatus.success;
      return true;
    } catch (e) {
      submitStatus = AiRoutineSubmitStatus.failure;
      submitError = e.toString();
      return false;
    }
  }

  void reset() {
    state = const AiRoutineWizardData();
    submitStatus = AiRoutineSubmitStatus.idle;
    submitError = null;
    _pendingSubmit = null;
  }
}

final aiRoutineWizardProvider =
    StateNotifierProvider<AiRoutineWizardNotifier, AiRoutineWizardData>(
      (ref) => AiRoutineWizardNotifier(ref.watch(_aiRoutineRepoProvider)),
    );
