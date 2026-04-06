enum RoutineStatus { todo, done, skipped }

class Routine {
  const Routine({
    required this.id,
    required this.title,
    required this.subtitle,
    this.status = RoutineStatus.todo,
    this.needsTimer = true,
    this.imagePath,
  });

  final String id;
  final String title;
  final String subtitle;
  final RoutineStatus status;
  final bool needsTimer;
  final String? imagePath;

  Routine copyWith({RoutineStatus? status}) => Routine(
    id: id,
    title: title,
    subtitle: subtitle,
    status: status ?? this.status,
    needsTimer: needsTimer,
    imagePath: imagePath,
  );
}
