import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/ai_routine_entry.dart';

enum EmptyRoutineReason {
  never,
  noRoutineThatDay,
  afterPeriod,
}

class EmptyRoutineView extends StatelessWidget {
  const EmptyRoutineView({
    super.key,
    this.reason = EmptyRoutineReason.never,
  });

  final EmptyRoutineReason reason;

  String get _message {
    switch (reason) {
      case EmptyRoutineReason.never:
        return '생성한 루틴이 없어요';
      case EmptyRoutineReason.noRoutineThatDay:
        return '오늘은 루틴이 없는 날이에요';
      case EmptyRoutineReason.afterPeriod:
        return '루틴이 생성되지 않았어요';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _message,
            style: KdhTextStyle.body3.copyWith(color: KdhColor.gray300),
          ),
          if (reason == EmptyRoutineReason.never) ...[
            const SizedBox(height: 14),
            const AiRoutineEntry(),
          ],
        ],
      ),
    );
  }
}
