import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:material_symbols_icons/symbols.dart';

class MonthlyCalendar extends StatelessWidget {
  const MonthlyCalendar({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.datesWithRoutines,
    required this.onDateSelected,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<String> datesWithRoutines;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  static const _weekDayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());

  bool _hasRoutine(DateTime date) =>
      datesWithRoutines.contains('${date.year}-${date.month}-${date.day}');

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDay = DateTime(displayedMonth.year, displayedMonth.month + 1, 0);

    final startOffset = firstDay.weekday % 7;
    final totalCells = startOffset + lastDay.day;
    final rowCount = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onPrevMonth,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Symbols.chevron_left,
                    color: KdhColor.gray600,
                    size: 20,
                  ),
                ),
              ),
              Text(
                '${displayedMonth.year}년 ${displayedMonth.month}월',
                style: KdhTextStyle.body6.copyWith(color: KdhColor.gray700),
              ),
              GestureDetector(
                onTap: onNextMonth,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Symbols.chevron_right,
                    color: KdhColor.gray600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: _weekDayLabels
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: KdhTextStyle.caption4.copyWith(
                          color: KdhColor.gray400,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          for (int row = 0; row < rowCount; row++)
            Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNumber = cellIndex - startOffset + 1;

                if (dayNumber < 1 || dayNumber > lastDay.day) {
                  return const Expanded(child: SizedBox(height: 40));
                }

                final date = DateTime(
                  displayedMonth.year,
                  displayedMonth.month,
                  dayNumber,
                );
                final today = _isToday(date);
                final selected = _isSameDay(date, selectedDate);
                final hasR = _hasRoutine(date);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: SizedBox(
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: today
                                  ? KdhColor.red200
                                  : KdhColor.background,
                              shape: BoxShape.circle,
                              border: selected && !today
                                  ? Border.all(
                                      color: KdhColor.red200,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$dayNumber',
                                style: KdhTextStyle.caption4.copyWith(
                                  color: today
                                      ? KdhColor.background
                                      : selected
                                      ? KdhColor.red400
                                      : KdhColor.gray800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: hasR
                                  ? KdhColor.red200
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
