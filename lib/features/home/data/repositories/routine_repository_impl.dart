import 'package:dio/dio.dart';
import 'package:kdh_mobile/core/network/api_endpoint.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
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
}
