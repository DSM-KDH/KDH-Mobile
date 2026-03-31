class AiRoutineWizardHolder {
  AiRoutineWizardHolder._();

  static AiRoutineWizardData _current = const AiRoutineWizardData();

  static AiRoutineWizardData get current => _current;

  static void save(AiRoutineWizardData data) => _current = data;

  static void reset() => _current = const AiRoutineWizardData();
}

class AiRoutineWizardData {
  const AiRoutineWizardData({
    this.goal,
    this.targetWeight,
    this.selectedMuscles = const {},
    this.performanceLevel,
    this.weeks,
    this.hours,
    this.selectedDays = const {},
    this.exerciseTypes = const {},
    this.places = const {},
    this.equipment = const {},
  });

  final int? goal;
  final double? targetWeight;
  final Set<String> selectedMuscles;
  final int? performanceLevel;
  final int? weeks;
  final double? hours;
  final Set<int> selectedDays;
  final Set<int> exerciseTypes;
  final Set<int> places;
  final Set<String> equipment;

  AiRoutineWizardData copyWith({
    int? goal,
    double? targetWeight,
    Set<String>? selectedMuscles,
    int? performanceLevel,
    int? weeks,
    double? hours,
    Set<int>? selectedDays,
    Set<int>? exerciseTypes,
    Set<int>? places,
    Set<String>? equipment,
  }) => AiRoutineWizardData(
    goal: goal ?? this.goal,
    targetWeight: targetWeight ?? this.targetWeight,
    selectedMuscles: selectedMuscles ?? this.selectedMuscles,
    performanceLevel: performanceLevel ?? this.performanceLevel,
    weeks: weeks ?? this.weeks,
    hours: hours ?? this.hours,
    selectedDays: selectedDays ?? this.selectedDays,
    exerciseTypes: exerciseTypes ?? this.exerciseTypes,
    places: places ?? this.places,
    equipment: equipment ?? this.equipment,
  );
}
