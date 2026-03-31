import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:material_symbols_icons/symbols.dart';

class AiRoutineFailureView extends StatelessWidget {
  const AiRoutineFailureView({super.key, required this.message});

  final String message;

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
                        Symbols.arrow_back,
                        size: 16,
                        color: KdhColor.gray500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '뒤로 돌아가기',
                        style: KdhTextStyle.body3.copyWith(
                          color: KdhColor.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: KdhTextStyle.heading3.copyWith(color: KdhColor.gray500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
