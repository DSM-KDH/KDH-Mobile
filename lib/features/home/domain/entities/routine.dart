enum RoutineStatus { todo, done, skipped }

class Routine {
  final String id;
  final String title;
  final String subtitle;
  final RoutineStatus status;
  final bool needsTimer;

  const Routine({
    required this.id,
    required this.title,
    required this.subtitle,
    this.status = RoutineStatus.todo,
    this.needsTimer = true,
  });

  Routine copyWith({RoutineStatus? status}) => Routine(
        id: id,
        title: title,
        subtitle: subtitle,
        status: status ?? this.status,
        needsTimer: needsTimer,
      );
}
