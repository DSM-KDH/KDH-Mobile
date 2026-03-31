import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:material_symbols_icons/symbols.dart';

class AiRoutineFailureView extends StatelessWidget {
  const AiRoutineFailureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: KdhColor.gray50,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Symbols.arrow_back_ios,
                        size: 16,
                        color: KdhColor.gray600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '뒤로 돌아가기',
                        style: KdhTextStyle.body6.copyWith(
                          color: KdhColor.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'AI로 맞춤 루틴 생성을\n실패했습니다',
                textAlign: TextAlign.center,
                style: KdhTextStyle.body3.copyWith(color: KdhColor.gray800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
