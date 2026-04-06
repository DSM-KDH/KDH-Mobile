import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:kdh_mobile/core/widgets/kdh_select_card.dart';
import 'package:kdh_mobile/features/routine/presentation/providers/ai_routine_wizard_provider.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/step_progress_header.dart';

class FourthStepPage extends ConsumerStatefulWidget {
  const FourthStepPage({super.key});

  @override
  ConsumerState<FourthStepPage> createState() => _FourthStepPageState();
}

class _FourthStepPageState extends ConsumerState<FourthStepPage> {
  final Set<int> _selected = {};

  static const _items = [
    (label: '유산소', svg: 'assets/icons/cardio.svg'),
    (label: '근력', svg: 'assets/icons/muscle.svg'),
    (label: '맨몸', svg: 'assets/icons/body.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: StepProgressHeader(currentStep: 4, totalSteps: 5),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('운동 유형 선택', style: KdhTextStyle.heading3),
                    const SizedBox(height: 8),
                    Text(
                      '선호하는 운동 유형을 선택해주세요',
                      style: KdhTextStyle.body6.copyWith(
                        color: KdhColor.red500,
                      ),
                    ),
                    const SizedBox(height: 34),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 24) / 3;

                        return Row(
                          children: List.generate(_items.length, (i) {
                            final item = _items[i];
                            final isSelected = _selected.contains(i);

                            return Padding(
                              padding: EdgeInsets.only(
                                right: i < _items.length - 1 ? 12 : 0,
                              ),
                              child: KdhSelectCard(
                                icon: SvgPicture.asset(
                                  item.svg,
                                  width: 36,
                                  height: 36,
                                  colorFilter: isSelected
                                      ? const ColorFilter.mode(
                                          KdhColor.red500,
                                          BlendMode.srcIn,
                                        )
                                      : null,
                                ),
                                selected: isSelected,
                                label: item.label,
                                size: cardWidth,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selected.remove(i);
                                    } else {
                                      _selected.add(i);
                                    }
                                  });
                                },
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '복수 선택이 가능해요',
                      style: KdhTextStyle.caption2.copyWith(
                        color: KdhColor.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: KdhButton(
                label: '다음',
                onPressed: _selected.isNotEmpty
                    ? () {
                        ref
                            .read(aiRoutineWizardProvider.notifier)
                            .setExerciseTypes(Set.from(_selected));
                        context.push(RouterPath.aiRoutineStep5);
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
