import 'package:dio/dio.dart';
import 'package:kdh_mobile/core/network/api_endpoint.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/features/home/data/models/achievement_model.dart';
import 'package:kdh_mobile/features/home/data/models/workout_model.dart';
import 'package:kdh_mobile/features/home/data/repositories/routine_repository.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  const RoutineRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<String>> fetchRoutineDates() async {
    try {
      final response = await _dio.get(ApiEndpoint.routinesDates);
      return (response.data as List).cast<String>();
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }

  @override
  Future<RoutineDayResponse> fetchRoutineByDate(String date) async {
    try {
      final response = await _dio.get(
        ApiEndpoint.routines,
        queryParameters: {'date': date},
      );
      return RoutineDayResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }

  @override
  Future<void> toggleExerciseCompletion({
    required int exerciseId,
    required bool completed,
  }) async {
    try {
      await _dio.patch(
        ApiEndpoint.routineExerciseCompletion(exerciseId),
        queryParameters: {'completed': completed},
      );
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }

  @override
  Future<void> deleteExercise(int exerciseId) async {
    try {
      await _dio.delete(ApiEndpoint.routineExercise(exerciseId));
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }

  @override
  Future<LastWeekAchievement?> fetchLastWeekAchievement() async {
    try {
      final response = await _dio.get(ApiEndpoint.routinesAchievementLastWeek);
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      return LastWeekAchievement.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw extractAppException(e);
    }
  }

  @override
  Future<List<WeekAchievement>> fetchWeeklyAchievements() async {
    try {
      final response = await _dio.get(ApiEndpoint.routinesAchievementWeeks);
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(WeekAchievement.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      throw extractAppException(e);
    }
  }
}
