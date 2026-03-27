import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/home/domain/entities/routine.dart';
import 'package:material_symbols_icons/symbols.dart';

class RoutineCheckItem extends StatelessWidget {
  const RoutineCheckItem({
    super.key,
    required this.routine,
    required this.isToday,
    required this.onActionTap,
  });

  final Routine routine;
  final bool isToday;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final isDone = routine.status == RoutineStatus.done;

    final Color checkBgColor;
    final Color checkIconColor;

    if (isDone && isToday) {
      checkBgColor = KdhColor.red200;
      checkIconColor = KdhColor.background;
    } else if (!isDone && isToday) {
      checkBgColor = KdhColor.background;
      checkIconColor = KdhColor.red100;
    } else if (isDone && !isToday) {
      checkBgColor = KdhColor.gray200;
      checkIconColor = KdhColor.background;
    } else {
      checkBgColor = KdhColor.background;
      checkIconColor = KdhColor.gray100;
    }

    return Container(
      decoration: BoxDecoration(
        color: KdhColor.red50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: checkBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Symbols.check_rounded,
              color: checkIconColor,
              size: 18,
              fill: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.title,
                  style: KdhTextStyle.body6.copyWith(color: KdhColor.gray800),
                ),
                const SizedBox(height: 2),
                Text(
                  routine.subtitle,
                  style: KdhTextStyle.caption1.copyWith(
                    color: KdhColor.gray400,
                  ),
                ),
              ],
            ),
          ),
          if (routine.needsTimer) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: KdhColor.red100,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '수행하기',
                  style: KdhTextStyle.caption1.copyWith(color: KdhColor.red400),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
