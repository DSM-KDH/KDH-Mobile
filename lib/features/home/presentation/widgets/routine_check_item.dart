import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/home/domain/entities/routine.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/routine_check_circle.dart';

class RoutineCheckItem extends StatelessWidget {
  const RoutineCheckItem({
    super.key,
    required this.routine,
    required this.isToday,
    required this.onToggle,
    required this.onActionTap,
  });

  final Routine routine;
  final bool isToday;
  final VoidCallback onToggle;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KdhColor.red50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          RoutineCheckCircle(
            isDone: routine.status == RoutineStatus.done,
            isToday: isToday,
            onToggle: onToggle,
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
                  style: KdhTextStyle.caption1.copyWith(color: KdhColor.gray400),
                ),
              ],
            ),
          ),
          if (routine.needsTimer) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
