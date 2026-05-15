import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_entry.dart';

class EmptyRoutineView extends StatelessWidget {
  const EmptyRoutineView({super.key, this.hasAnyRoutine = false});

  final bool hasAnyRoutine;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasAnyRoutine ? '오늘은 루틴이 없는 날이에요' : '생성한 루틴이 없어요',
            style: KdhTextStyle.body3.copyWith(color: KdhColor.gray300),
          ),
          if (!hasAnyRoutine) ...[
            const SizedBox(height: 14),
            const AiRoutineEntry(),
          ],
        ],
      ),
    );
  }
}
