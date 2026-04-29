import 'package:kdh_mobile/features/routine/data/models/ai_routine_wizard_data.dart';

abstract interface class AiRoutineRepository {
  Future<void> createRoutine(AiRoutineWizardData data, {String? fcmToken});
}
