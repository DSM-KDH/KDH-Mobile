import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:kdh_mobile/features/routine/presentation/providers/ai_routine_wizard_provider.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/step_progress_header.dart';

const _gap34 = SizedBox(height: 34);

class SecondStepPage extends ConsumerStatefulWidget {
  const SecondStepPage({super.key});

  @override
  ConsumerState<SecondStepPage> createState() => _SecondStepPageState();
}

class _SecondStepPageState extends ConsumerState<SecondStepPage> {
  int? _selected;

  static const _items = [
    '하 - 러닝 페이스 6:00 이상',
    '중 - 러닝 페이스 4:30 ~ 6:00',
    '상 - 러닝 페이스 4:30 이하',
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
              child: StepProgressHeader(currentStep: 2, totalSteps: 5),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('수행 능력 선택', style: KdhTextStyle.heading3),
                    const SizedBox(height: 8),
                    Text(
                      '현재 자신의 운동 수행 능력을 선택해주세요',
                      style: KdhTextStyle.body6.copyWith(
                        color: KdhColor.red500,
                      ),
                    ),
                    _gap34,
                    ...List.generate(_items.length, (i) {
                      final selected = _selected == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: selected
                                  ? KdhColor.red200
                                  : KdhColor.background,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: selected
                                    ? KdhColor.red200
                                    : KdhColor.red50,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _items[i],
                              style: KdhTextStyle.body6.copyWith(
                                color: selected
                                    ? KdhColor.background
                                    : KdhColor.gray800,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    _gap34,
                    Text(
                      '러닝 페이스란?\n1km를 달리는데 걸리는 시간(분/km)',
                      style: KdhTextStyle.caption1.copyWith(
                        color: KdhColor.gray500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: KdhButton(
                label: '다음',
                onPressed: _selected != null
                    ? () {
                        ref
                            .read(aiRoutineWizardProvider.notifier)
                            .setPerformanceLevel(_selected!);
                        context.push(RouterPath.aiRoutineStep3);
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
