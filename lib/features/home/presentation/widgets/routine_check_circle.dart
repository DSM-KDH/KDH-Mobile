import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:material_symbols_icons/symbols.dart';

class RoutineCheckCircle extends StatelessWidget {
  const RoutineCheckCircle({
    super.key,
    required this.isDone,
    required this.isToday,
    required this.onToggle,
  });

  final bool isDone;
  final bool isToday;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color iconColor;

    if (isDone && isToday) {
      bgColor = KdhColor.red200;
      iconColor = KdhColor.background;
    } else if (!isDone && isToday) {
      bgColor = KdhColor.background;
      iconColor = KdhColor.red100;
    } else if (isDone && !isToday) {
      bgColor = KdhColor.gray200;
      iconColor = KdhColor.background;
    } else {
      bgColor = KdhColor.background;
      iconColor = KdhColor.gray100;
    }

    return GestureDetector(
      onTap: isToday ? onToggle : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Symbols.check_rounded,
          color: iconColor,
          size: 18,
          fill: 1,
        ),
      ),
    );
  }
}
