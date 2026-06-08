import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/home/data/models/achievement_model.dart';

class WeeklyRoutineCard extends StatelessWidget {
  const WeeklyRoutineCard({
    super.key,
    required this.data,
    this.routineDates = const {},
  });

  final AchievementData data;

  final Set<String> routineDates;

  int? _daysUntilNextRoutine() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? next;
    for (final key in routineDates) {
      final parts = key.split('-');
      if (parts.length != 3) continue;
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (date.isAfter(today) && (next == null || date.isBefore(next))) {
        next = date;
      }
    }
    return next?.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
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

    final current = data.currentWeek;
    final rate = current?.achievementRate ?? data.lastWeek?.achievementRate ?? 0;
    final progress = (rate / 100).clamp(0.0, 1.0);
    final progressPct = rate.round();
    final daysUntilNext = _daysUntilNextRoutine();
    final lastWeekRate = data.lastWeek?.achievementRate;

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
                        if (lastWeekRate != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '지난주 ${lastWeekRate.round()}%',
                            style: KdhTextStyle.caption5.copyWith(
                              color: KdhColor.gray300,
                            ),
                          ),
                        ],
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
                  '다음\n루틴까지',
                  style: KdhTextStyle.caption1.copyWith(
                    color: KdhColor.background,
                    height: 1.4,
                  ),
                ),
                Center(
                  child: (daysUntilNext != null && daysUntilNext > 0)
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
