import 'package:dio/dio.dart';
import 'package:kdh_mobile/core/network/api_endpoint.dart';
import 'package:kdh_mobile/core/network/dio_client.dart';
import 'package:kdh_mobile/features/routine/data/models/ai_routine_wizard_data.dart';
import 'package:kdh_mobile/features/routine/data/repositories/ai_routine_repository.dart';

class AiRoutineRepositoryImpl implements AiRoutineRepository {
  const AiRoutineRepositoryImpl(this._dio);

  final Dio _dio;

  static const _goalTypes = ['DIET', 'HEALTH_CARE', 'MUSCLE_GAIN'];
  static const _fitnessLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];
  static const _dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _exerciseTypes = ['CARDIO', 'STRENGTH', 'BODYWEIGHT'];
  static const _locations = ['OUTDOOR', 'GYM', 'HOME'];
  static const _equipmentMap = {
    '바벨': 'BARBELL',
    '덤벨': 'DUMBBELL',
    '케이블': 'CABLE_MACHINE',
    '머신': 'MACHINE',
    '벤치': 'BENCH',
    '철봉': 'PULL_UP_BAR',
    '밴드': 'BAND',
    '랫풀다운': 'LAT_PULL_DOWN',
    '스미스머신': 'SMITH_MACHINE',
    '레그프레스': 'LEG_PRESS',
    '펙덱플라이': 'PEC_DECK',
    '딥스바': 'DIP_BAR',
    '폼롤러': 'FOAM_ROLLER',
    '사이클': 'BIKE',
  };

  static const _muscleMap = {
    '가슴': 'CHEST',
    '등': 'BACK',
    '어깨': 'SHOULDER',
    '팔': 'ARM',
    '복근': 'ABS',
    '허벅지': 'THIGH',
    '종아리': 'CALF',
    '힙': 'GLUTE',
  };

  @override
  Future<void> createRoutine(
    AiRoutineWizardData data, {
    String? fcmToken,
  }) async {
    try {
      final goal = data.goal!;
      final body = <String, dynamic>{
        'goal': {
          'goalType': _goalTypes[goal],
          'targetWeight': goal == 0 ? data.targetWeight : null,
          'targetBodyParts': goal == 2
              ? data.selectedMuscles.map((k) => _muscleMap[k] ?? k).toList()
              : [],
        },
        'fitnessLevel': _fitnessLevels[data.performanceLevel!],
        'schedule': {
          'totalWeeks': data.weeks,
          'hoursPerDay': data.hours?.toInt() ?? 1,
          'activeDays': (data.selectedDays.toList()..sort())
              .map((i) => _dayNames[i])
              .toList(),
        },
        'preferredExerciseTypes': (data.exerciseTypes.toList()..sort())
            .map((i) => _exerciseTypes[i])
            .toList(),
        'environment': {
          'locations': (data.places.toList()..sort())
              .map((i) => _locations[i])
              .toList(),
          'equipments': data.equipment
              .map((k) => _equipmentMap[k] ?? k)
              .toList(),
        },
      };

      final trimmedFcmToken = fcmToken?.trim();
      if (trimmedFcmToken != null && trimmedFcmToken.isNotEmpty) {
        body['fcmToken'] = trimmedFcmToken;
      }

      await _dio.post(ApiEndpoint.routines, data: body);
    } on DioException catch (e) {
      throw extractAppException(e);
    }
  }
}
