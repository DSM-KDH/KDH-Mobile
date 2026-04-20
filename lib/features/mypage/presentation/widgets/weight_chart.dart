import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/mypage/domain/entities/weight_entry.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.entries});

  final List<WeightEntry> entries;

  List<({DateTime month, double weight})> get _monthlyAverages {
    final Map<String, List<double>> grouped = {};
    for (final e in entries) {
      final key = '${e.date.year}-${e.date.month}';
      grouped.putIfAbsent(key, () => []).add(e.weight);
    }

    final result = grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return (month: month, weight: avg);
    }).toList();

    result.sort((a, b) => a.month.compareTo(b.month));

    if (result.length > 6) return result.sublist(result.length - 6);
    return result;
  }

  ({double yMin, double yMax, double interval}) _yRange(
    List<({DateTime month, double weight})> data,
  ) {
    final weights = data.map((e) => e.weight).toList();
    final rawMin = weights.reduce(min);
    final rawMax = weights.reduce(max);

    final yMin = (((rawMin - 5) / 10).floor() * 10).toDouble();
    final yMax = (((rawMax + 5) / 10).ceil() * 10).toDouble();

    final interval = ((yMax - yMin) / 4).ceilToDouble();

    return (yMin: yMin, yMax: yMax, interval: interval);
  }

  @override
  Widget build(BuildContext context) {
    final data = _monthlyAverages;
    final range = _yRange(data);

    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].weight),
    );

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: range.interval,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: KdhColor.gray100,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: range.interval,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: KdhTextStyle.caption5.copyWith(
                    color: KdhColor.gray400,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${data[index].month.month}월',
                    style: KdhTextStyle.caption5.copyWith(
                      color: KdhColor.gray400,
                    ),
                  );
                },
              ),
            ),
          ),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: range.yMin,
          maxY: range.yMax,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: KdhColor.red200,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    KdhColor.red200.withValues(alpha: 0.25),
                    KdhColor.red50.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
