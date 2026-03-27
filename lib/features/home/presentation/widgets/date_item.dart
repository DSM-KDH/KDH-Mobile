import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class DateItem extends StatelessWidget {
  const DateItem({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    this.hasRoutine = false,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool hasRoutine;
  final VoidCallback onTap;

  static const _dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Border? border;

    if (isToday) {
      bgColor = KdhColor.red200;
      textColor = KdhColor.background;
      border = null;
    } else if (isSelected) {
      bgColor = KdhColor.red50;
      textColor = KdhColor.gray800;
      border = Border.all(color: KdhColor.red200, width: 1.5);
    } else {
      bgColor = KdhColor.background;
      textColor = KdhColor.gray800;
      border = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(50),
          border: border,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${date.day}',
              style: KdhTextStyle.body6.copyWith(color: textColor),
            ),
            const SizedBox(height: 2),
            Text(
              _dayLabels[date.weekday - 1],
              style: KdhTextStyle.caption5.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: hasRoutine
                    ? (isToday ? KdhColor.background : KdhColor.red200)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
