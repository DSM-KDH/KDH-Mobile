import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/features/home/data/models/workout_model.dart';
import 'package:kdh_mobile/features/home/data/repositories/routine_repository.dart';
import 'package:kdh_mobile/features/home/data/repositories/routine_repository_impl.dart';
import 'package:kdh_mobile/features/home/domain/entities/day_completion_status.dart';

final _routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => RoutineRepositoryImpl(ref.watch(dioProvider)),
);

class HomeRoutineState {
  const HomeRoutineState({
    this.routineDates = const {},
    this.completionMap = const {},
    this.currentWorkouts = const [],
    this.isLoadingDates = false,
    this.isLoadingRoutines = false,
    this.error,
  });

  final Set<String> routineDates;
  final Map<String, DayCompletionStatus> completionMap;
  final List<WorkoutModel> currentWorkouts;
  final bool isLoadingDates;
  final bool isLoadingRoutines;
  final String? error;

  HomeRoutineState copyWith({
    Set<String>? routineDates,
    Map<String, DayCompletionStatus>? completionMap,
    List<WorkoutModel>? currentWorkouts,
    bool? isLoadingDates,
    bool? isLoadingRoutines,
    String? error,
  }) => HomeRoutineState(
    routineDates: routineDates ?? this.routineDates,
    completionMap: completionMap ?? this.completionMap,
    currentWorkouts: currentWorkouts ?? this.currentWorkouts,
    isLoadingDates: isLoadingDates ?? this.isLoadingDates,
    isLoadingRoutines: isLoadingRoutines ?? this.isLoadingRoutines,
    error: error,
  );
}

class HomeRoutineNotifier extends StateNotifier<HomeRoutineState> {
  HomeRoutineNotifier(this._repository) : super(const HomeRoutineState());

  final RoutineRepository _repository;

  Future<void> loadDates() async {
    state = state.copyWith(isLoadingDates: true);
    try {
      final dates = await _repository.fetchRoutineDates();
      state = state.copyWith(
        routineDates: dates.toSet(),
        isLoadingDates: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingDates: false, error: e.toString());
    }
  }

  Future<void> loadRoutinesForDate(String dateKey) async {
    state = state.copyWith(isLoadingRoutines: true);
    try {
      final response = await _repository.fetchRoutineByDate(dateKey);
      final status = _computeStatus(response.workouts);
      state = state.copyWith(
        currentWorkouts: response.workouts,
        completionMap: {
          ...state.completionMap,
          if (status != null) dateKey: status,
        },
        isLoadingRoutines: false,
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
    state = state.copyWith(
      currentWorkouts: updated,
      completionMap: {
        ...state.completionMap,
        if (status != null) dateKey: status,
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

  DayCompletionStatus? _computeStatus(List<WorkoutModel> workouts) {
    if (workouts.isEmpty) return null;
    final doneCount = workouts.where((w) => w.completed).length;
    if (doneCount == workouts.length) return DayCompletionStatus.allDone;
    if (doneCount == 0) return DayCompletionStatus.noneDone;
    return DayCompletionStatus.partial;
  }
}

final homeRoutineProvider =
    StateNotifierProvider<HomeRoutineNotifier, HomeRoutineState>(
      (ref) => HomeRoutineNotifier(ref.watch(_routineRepositoryProvider)),
    );
