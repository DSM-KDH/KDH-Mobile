import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:material_symbols_icons/symbols.dart';

class AiRoutineEntry extends StatelessWidget {
  const AiRoutineEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouterPath.aiRoutinePrompt),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AI로 루틴 생성하러 가기',
            style: KdhTextStyle.body3.copyWith(color: KdhColor.red400),
          ),
          const SizedBox(width: 6),
          const Icon(
            Symbols.arrow_forward_rounded,
            color: KdhColor.red400,
            size: 20,
          ),
        ],
      ),
    );
  }
}
