import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:material_symbols_icons/symbols.dart';

class StepProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final String? title;
  final bool showStepIndicator;

  const StepProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.title,
    this.showStepIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onBack ?? () => context.pop(),
                      child: const Icon(
                        Symbols.arrow_back_ios,
                        color: KdhColor.gray800,
                        size: 20,
                      ),
                    ),
                    Text(
                      title ?? '$currentStep Step',
                      style: KdhTextStyle.body2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showStepIndicator) ...[
          const SizedBox(height: 20),
          Row(
            children: List.generate(totalSteps * 2 - 1, (index) {
              if (index.isOdd) {
                final lineActive = (index ~/ 2) < currentStep - 1;
                return Expanded(
                  child: Container(
                    height: 4,
                    color: lineActive ? KdhColor.red200 : KdhColor.red50,
                  ),
                );
              }
              final stepNum = index ~/ 2 + 1;
              final isActive = stepNum <= currentStep;
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? KdhColor.red200 : KdhColor.red50,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$stepNum',
                  style: KdhTextStyle.body2.copyWith(
                    color: isActive ? KdhColor.background : KdhColor.gray800,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
