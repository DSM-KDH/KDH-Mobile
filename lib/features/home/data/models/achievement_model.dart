class LastWeekAchievement {
  const LastWeekAchievement({
    required this.startDate,
    required this.endDate,
    required this.totalExerciseCount,
    required this.completedExerciseCount,
    required this.achievementRate,
  });

  final String startDate;
  final String endDate;
  final int totalExerciseCount;
  final int completedExerciseCount;
  final double achievementRate;

  factory LastWeekAchievement.fromJson(Map<String, dynamic> json) =>
      LastWeekAchievement(
        startDate: json['startDate'] as String? ?? '',
        endDate: json['endDate'] as String? ?? '',
        totalExerciseCount: (json['totalExerciseCount'] as num?)?.toInt() ?? 0,
        completedExerciseCount:
            (json['completedExerciseCount'] as num?)?.toInt() ?? 0,
        achievementRate:
            (json['achievementRate'] as num?)?.toDouble() ?? 0.0,
      );
}

class WeekAchievement {
  const WeekAchievement({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.totalExerciseCount,
    required this.completedExerciseCount,
    required this.achievementRate,
    required this.daysUntilNextRoutine,
  });

  final int weekNumber;
  final String startDate;
  final String endDate;
  final int totalExerciseCount;
  final int completedExerciseCount;
  final double achievementRate;
  final int daysUntilNextRoutine;

  factory WeekAchievement.fromJson(Map<String, dynamic> json) =>
      WeekAchievement(
        weekNumber: (json['weekNumber'] as num?)?.toInt() ?? 0,
        startDate: json['startDate'] as String? ?? '',
        endDate: json['endDate'] as String? ?? '',
        totalExerciseCount: (json['totalExerciseCount'] as num?)?.toInt() ?? 0,
        completedExerciseCount:
            (json['completedExerciseCount'] as num?)?.toInt() ?? 0,
        achievementRate:
            (json['achievementRate'] as num?)?.toDouble() ?? 0.0,
        daysUntilNextRoutine:
            (json['daysUntilNextRoutine'] as num?)?.toInt() ?? 0,
      );

  bool contains(DateTime date) {
    final start = DateTime.tryParse(startDate);
    final end = DateTime.tryParse(endDate);
    if (start == null || end == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }
}

class AchievementData {
  const AchievementData({this.lastWeek, this.weeks = const []});

  final LastWeekAchievement? lastWeek;
  final List<WeekAchievement> weeks;

  bool get isEmpty => lastWeek == null && weeks.isEmpty;

  WeekAchievement? get currentWeek {
    if (weeks.isEmpty) return null;
    final now = DateTime.now();
    for (final w in weeks) {
      if (w.contains(now)) return w;
    }
    return weeks.last;
  }
}
