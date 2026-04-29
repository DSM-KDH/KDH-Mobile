import 'package:kdh_mobile/features/home/domain/entities/routine.dart';

class WorkoutModel {
  const WorkoutModel({
    required this.exerciseId,
    required this.sectionName,
    required this.exerciseName,
    required this.repsTime,
    required this.completed,
    required this.canComplete,
  });

  final int exerciseId;
  final String sectionName;
  final String exerciseName;
  final String repsTime;
  final bool completed;
  final bool canComplete;

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
    exerciseId: json['exerciseId'] as int,
    sectionName: json['sectionName'] as String,
    exerciseName: json['exerciseName'] as String,
    repsTime: json['repsTime'] as String,
    completed: json['completed'] as bool,
    canComplete: json['canComplete'] as bool,
  );

  WorkoutModel copyWith({bool? completed}) => WorkoutModel(
    exerciseId: exerciseId,
    sectionName: sectionName,
    exerciseName: exerciseName,
    repsTime: repsTime,
    completed: completed ?? this.completed,
    canComplete: canComplete,
  );

  Routine toRoutine() => Routine(
    id: exerciseId.toString(),
    title: exerciseName,
    subtitle: '$sectionName · $repsTime',
    status: completed ? RoutineStatus.done : RoutineStatus.todo,
    needsTimer: false,
  );
}

class RoutineDayResponse {
  const RoutineDayResponse({required this.date, required this.workouts});

  final String date;
  final List<WorkoutModel> workouts;

  factory RoutineDayResponse.fromJson(Map<String, dynamic> json) =>
      RoutineDayResponse(
        date: json['date'] as String,
        workouts: (json['workouts'] as List)
            .map((e) => WorkoutModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
