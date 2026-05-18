import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/home/domain/entities/day_completion_status.dart';
import 'package:kdh_mobile/features/home/presentation/providers/routine_provider.dart';

class WeeklyRoutineCard extends StatelessWidget {
  const WeeklyRoutineCard({
    super.key,
    required this.routineDates,
    required this.completionMap,
    required this.exerciseCountMap,
  });

  final Set<String> routineDates;
  final Map<String, DayCompletionStatus> completionMap;
  final Map<String, DayExerciseCount> exerciseCountMap;

  DateTime _weekStart(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  @override
  Widget build(BuildContext context) {
    if (routineDates.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            '생성된 루틴이 없어요',
            style: KdhTextStyle.body6.copyWith(color: KdhColor.gray400),
          ),
        ),
      );
    }

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final weekStart = _weekStart(todayMidnight);
    final weekEnd = weekStart.add(const Duration(days: 6));

    final thisWeekDates = routineDates.where((dateStr) {
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
    }).toList();

    int weeklyDone = 0;
    int weeklyTotal = 0;
    for (final d in thisWeekDates) {
      final count = exerciseCountMap[d];
      if (count != null) {
        weeklyDone += count.done;
        weeklyTotal += count.total;
      }
    }

    final progress = weeklyTotal > 0 ? weeklyDone / weeklyTotal : 0.0;
    final progressPct = (progress * 100).round();

    DateTime? nextDate;
    for (final dateStr in routineDates) {
      final parts = dateStr.split('-');
      if (parts.length != 3) continue;
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (date.isAfter(todayMidnight)) {
        if (nextDate == null || date.isBefore(nextDate)) {
          nextDate = date;
        }
      }
    }

    final daysUntilNext = nextDate?.difference(todayMidnight).inDays;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KdhColor.red50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(100, 100),
                          painter: _DonutChartPainter(progress: progress),
                        ),
                        Text(
                          '$progressPct%',
                          style: KdhTextStyle.caption3.copyWith(
                            color: KdhColor.red200,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LegendSquare(color: KdhColor.red100),
                            const SizedBox(width: 4),
                            Text(
                              '미달성',
                              style: KdhTextStyle.caption5.copyWith(
                                color: KdhColor.gray400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LegendSquare(color: KdhColor.red200),
                            const SizedBox(width: 4),
                            Text(
                              '달성',
                              style: KdhTextStyle.caption5.copyWith(
                                color: KdhColor.gray400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KdhColor.red200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '다음주\n루틴까지',
                  style: KdhTextStyle.caption1.copyWith(
                    color: KdhColor.background,
                    height: 1.4,
                  ),
                ),
                Center(
                  child: daysUntilNext != null
                      ? Text(
                          '$daysUntilNext일',
                          style: KdhTextStyle.heading2.copyWith(
                            color: KdhColor.background,
                          ),
                        )
                      : Text(
                          '없음',
                          style: KdhTextStyle.body3.copyWith(
                            color: KdhColor.background,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendSquare extends StatelessWidget {
  const _LegendSquare({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double progress;

  const _DonutChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    const strokeWidth = 20.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = KdhColor.red100
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        -2 * math.pi * progress,
        false,
        Paint()
          ..color = KdhColor.red200
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) => old.progress != progress;
}
