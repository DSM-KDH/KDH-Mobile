import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/error/app_exception.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:kdh_mobile/features/home/data/models/achievement_model.dart';
import 'package:kdh_mobile/features/home/data/models/workout_model.dart';
import 'package:kdh_mobile/features/home/data/repositories/routine_repository.dart';
import 'package:kdh_mobile/features/home/data/repositories/routine_repository_impl.dart';
import 'package:kdh_mobile/features/home/domain/entities/day_completion_status.dart';

final _routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => RoutineRepositoryImpl(ref.watch(dioProvider)),
);

final achievementProvider = FutureProvider.autoDispose<AchievementData>((
  ref,
) async {
  final repo = ref.watch(_routineRepositoryProvider);
  final results = await Future.wait([
    repo.fetchLastWeekAchievement(),
    repo.fetchWeeklyAchievements(),
  ]);
  return AchievementData(
    lastWeek: results[0] as LastWeekAchievement?,
    weeks: results[1] as List<WeekAchievement>,
  );
});

class DayExerciseCount {
  const DayExerciseCount({required this.done, required this.total});

  final int done;
  final int total;
}

class HomeRoutineState {
  const HomeRoutineState({
    this.routineDates = const {},
    this.completionMap = const {},
    this.exerciseCountMap = const {},
    this.currentWorkouts = const [],
    this.isLoadingDates = false,
    this.isLoadingRoutines = false,
    this.error,
  });

  final Set<String> routineDates;
  final Map<String, DayCompletionStatus> completionMap;
  final Map<String, DayExerciseCount> exerciseCountMap;
  final List<WorkoutModel> currentWorkouts;
  final bool isLoadingDates;
  final bool isLoadingRoutines;
  final String? error;

  HomeRoutineState copyWith({
    Set<String>? routineDates,
    Map<String, DayCompletionStatus>? completionMap,
    Map<String, DayExerciseCount>? exerciseCountMap,
    List<WorkoutModel>? currentWorkouts,
    bool? isLoadingDates,
    bool? isLoadingRoutines,
    String? error,
  }) => HomeRoutineState(
    routineDates: routineDates ?? this.routineDates,
    completionMap: completionMap ?? this.completionMap,
    exerciseCountMap: exerciseCountMap ?? this.exerciseCountMap,
    currentWorkouts: currentWorkouts ?? this.currentWorkouts,
    isLoadingDates: isLoadingDates ?? this.isLoadingDates,
    isLoadingRoutines: isLoadingRoutines ?? this.isLoadingRoutines,
    error: error,
  );
}

class HomeRoutineNotifier extends StateNotifier<HomeRoutineState> {
  HomeRoutineNotifier(this._ref, this._repository)
    : super(const HomeRoutineState()) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (!next.isAuthenticated) {
        state = const HomeRoutineState();
      }
    });
  }

  final Ref _ref;
  final RoutineRepository _repository;

  Future<void> loadDates() async {
    state = state.copyWith(isLoadingDates: true, error: null);
    try {
      final dates = await _repository.fetchRoutineDates();
      state = state.copyWith(
        routineDates: dates.toSet(),
        isLoadingDates: false,
        error: null,
      );
      _preloadCompletionStatuses(dates);
    } catch (e) {
      state = state.copyWith(isLoadingDates: false, error: e.toString());
    }
  }

  void _preloadCompletionStatuses(List<String> dates) {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    for (final dateKey in dates) {
      final parts = dateKey.split('-');
      if (parts.length != 3) continue;
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (!date.isAfter(todayMidnight)) {
        loadCompletionStatus(dateKey);
      }
    }
  }

  Future<void> loadCompletionStatus(String dateKey) async {
    try {
      final response = await _repository.fetchRoutineByDate(dateKey);
      final workouts = response.workouts;
      final status = _computeStatus(workouts);
      final count = _computeCount(workouts);

      state = state.copyWith(
        completionMap: {
          ...state.completionMap,
          if (status != null) dateKey: status,
        },
        exerciseCountMap: {
          ...state.exerciseCountMap,
          if (count != null) dateKey: count,
        },
      );
    } catch (_) {}
  }

  Future<void> loadRoutinesForDate(String dateKey) async {
    state = state.copyWith(isLoadingRoutines: true, error: null);
    try {
      final response = await _repository.fetchRoutineByDate(dateKey);
      final workouts = response.workouts;
      final status = _computeStatus(workouts);
      final count = _computeCount(workouts);

      state = state.copyWith(
        currentWorkouts: workouts,
        completionMap: {
          ...state.completionMap,
          if (status != null) dateKey: status,
        },
        exerciseCountMap: {
          ...state.exerciseCountMap,
          if (count != null) dateKey: count,
        },
        isLoadingRoutines: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingRoutines: false, error: e.toString());
    }
  }

  Future<void> toggleCompletion({
    required int exerciseId,
    required bool completed,
    required String dateKey,
  }) async {
    final updated = state.currentWorkouts
        .map(
          (w) =>
              w.exerciseId == exerciseId ? w.copyWith(completed: completed) : w,
        )
        .toList();

    final status = _computeStatus(updated);
    final count = _computeCount(updated);
    state = state.copyWith(
      currentWorkouts: updated,
      completionMap: {
        ...state.completionMap,
        if (status != null) dateKey: status,
      },
      exerciseCountMap: {
        ...state.exerciseCountMap,
        if (count != null) dateKey: count,
      },
    );

    try {
      await _repository.toggleExerciseCompletion(
        exerciseId: exerciseId,
        completed: completed,
      );
    } catch (e) {
      await loadRoutinesForDate(dateKey);
    }
  }

  Future<String?> deleteExercise(int exerciseId) async {
    try {
      await _repository.deleteExercise(exerciseId);
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return '오늘 또는 예정된 운동만 삭제할 수 있어요';
    }
  }

  void removeWorkoutLocally(int exerciseId) {
    final updated = state.currentWorkouts
        .where((w) => w.exerciseId != exerciseId)
        .toList();
    state = state.copyWith(currentWorkouts: updated);
  }

  DayCompletionStatus? _computeStatus(List<WorkoutModel> workouts) {
    if (workouts.isEmpty) return null;
    final doneCount = workouts.where((w) => w.completed).length;
    if (doneCount == workouts.length) return DayCompletionStatus.allDone;
    if (doneCount == 0) return DayCompletionStatus.noneDone;
    return DayCompletionStatus.partial;
  }

  DayExerciseCount? _computeCount(List<WorkoutModel> workouts) {
    if (workouts.isEmpty) return null;
    return DayExerciseCount(
      done: workouts.where((w) => w.completed).length,
      total: workouts.length,
    );
  }
}

final homeRoutineProvider =
    StateNotifierProvider<HomeRoutineNotifier, HomeRoutineState>(
      (ref) => HomeRoutineNotifier(ref, ref.watch(_routineRepositoryProvider)),
    );
