import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/features/routine/data/models/ai_routine_wizard_data.dart';

final aiRoutineWizardProvider =
    NotifierProvider<AiRoutineWizardNotifier, AiRoutineWizardData>(
  AiRoutineWizardNotifier.new,
);

class AiRoutineWizardNotifier extends Notifier<AiRoutineWizardData> {
  @override
  AiRoutineWizardData build() => const AiRoutineWizardData();

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

  void reset() => state = const AiRoutineWizardData();
}
