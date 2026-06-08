class GoalValidationResult {
  const GoalValidationResult.valid()
    : isValid = true,
      message = null;
  const GoalValidationResult.invalid(this.message) : isValid = false;

  final bool isValid;
  final String? message;
}

class RoutineGoalValidator {
  RoutineGoalValidator._();

  static const double _maxWeeklyLossKg = 1.0;

  static const double _minHealthyBmi = 18.5;

  static GoalValidationResult validateTargetWeight({
    required double target,
    double? currentWeight,
    double? heightCm,
  }) {
    if (target <= 0) {
      return const GoalValidationResult.invalid('목표 몸무게를 올바르게 입력해주세요');
    }
    if (currentWeight != null && target >= currentWeight) {
      return GoalValidationResult.invalid(
        '목표 몸무게는 현재 몸무게(${_fmt(currentWeight)}kg)보다 작아야 해요',
      );
    }
    final floor = _healthyFloor(heightCm);
    if (floor != null && target < floor) {
      return GoalValidationResult.invalid(
        '건강을 위해 ${_fmt(floor)}kg 이상으로 설정해주세요',
      );
    }
    return const GoalValidationResult.valid();
  }

  static GoalValidationResult validateLossRate({
    double? currentWeight,
    double? targetWeight,
    required int? weeks,
  }) {
    if (currentWeight == null ||
        targetWeight == null ||
        weeks == null ||
        weeks <= 0) {
      return const GoalValidationResult.valid();
    }
    final totalLoss = currentWeight - targetWeight;
    if (totalLoss <= 0) return const GoalValidationResult.valid();

    final perWeek = totalLoss / weeks;
    if (perWeek > _maxWeeklyLossKg) {
      final minWeeks = (totalLoss / _maxWeeklyLossKg).ceil();
      return GoalValidationResult.invalid(
        '목표 기간에 비해 몸무게를 급격하게 감소하는 것은 위험합니다.\n'
        '최소 $minWeeks주 이상으로 설정하거나 목표 몸무게를 조정해주세요',
      );
    }
    return const GoalValidationResult.valid();
  }

  static double? _healthyFloor(double? heightCm) {
    if (heightCm == null || heightCm <= 0) return null;
    final m = heightCm / 100;
    return _minHealthyBmi * m * m;
  }

  static String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
