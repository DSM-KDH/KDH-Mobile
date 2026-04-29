import 'package:kdh_mobile/features/home/data/models/workout_model.dart';

abstract interface class RoutineRepository {
  Future<List<String>> fetchRoutineDates();

  Future<RoutineDayResponse> fetchRoutineByDate(String date);

  Future<void> toggleExerciseCompletion({
    required int exerciseId,
    required bool completed,
  });
}
