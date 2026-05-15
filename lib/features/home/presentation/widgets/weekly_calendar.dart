import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/date_item.dart';

class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({
    super.key,
    required this.selectedDate,
    required this.datesWithRoutines,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final Set<String> datesWithRoutines;
  final ValueChanged<DateTime> onDateSelected;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());

  bool _hasRoutine(DateTime date) => datesWithRoutines.contains(
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
  );

  List<DateTime> get _weekDates {
    final weekday = selectedDate.weekday;
    final startOfWeek = selectedDate.subtract(Duration(days: weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KdhColor.red100,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              '${selectedDate.month}월',
              style: KdhTextStyle.caption1.copyWith(color: KdhColor.red400),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDates
                .map(
                  (date) => DateItem(
                    date: date,
                    isSelected: _isSameDay(date, selectedDate),
                    isToday: _isToday(date),
                    hasRoutine: _hasRoutine(date),
                    onTap: () => onDateSelected(date),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
