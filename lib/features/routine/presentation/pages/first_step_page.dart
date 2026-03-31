import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdh_mobile/core/widgets/kdh_select_card.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/body_diagram.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/step_progress_header.dart';

const _gap16 = SizedBox(height: 16);

class FirstStepPage extends StatefulWidget {
  const FirstStepPage({super.key});

  @override
  State<FirstStepPage> createState() => _FirstStepPageState();
}

class _FirstStepPageState extends State<FirstStepPage> {
  int? _selectedGoal;

  final _weightController = TextEditingController();
  late final FocusNode _weightFocusNode;
  bool _weightFocused = false;

  final Set<String> _selectedMuscles = {};

  static const _upperMuscles = ['가슴', '등', '어깨', '팔'];
  static const _coreMuscles = ['복근'];
  static const _lowerMuscles = ['허벅지', '종아리', '힙'];

  bool get _canProceed {
    switch (_selectedGoal) {
      case 0:
        final weight = double.tryParse(_weightController.text.trim());
        return weight != null && weight > 0;
      case 1:
        return true;
      case 2:
        return _selectedMuscles.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _weightFocusNode = FocusNode()
      ..addListener(
        () => setState(() => _weightFocused = _weightFocusNode.hasFocus),
      );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  void _selectGoal(int index) {
    setState(() {
      _selectedGoal = index;
      if (index != 0) _weightController.clear();
      if (index != 2) _selectedMuscles.clear();
    });
  }

  Widget _buildMuscleChip(String label) {
    final selected = _selectedMuscles.contains(label);
    return ChoiceChip(
      label: Text(
        label,
        style: KdhTextStyle.caption1.copyWith(
          color: selected ? KdhColor.background : KdhColor.gray800,
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() {
        if (selected) {
          _selectedMuscles.remove(label);
        } else {
          _selectedMuscles.add(label);
        }
      }),
      selectedColor: KdhColor.red200,
      backgroundColor: KdhColor.background,
      side: selected ? BorderSide.none : BorderSide(color: KdhColor.red500, width: 2),
      shape: const StadiumBorder(),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: KdhTextStyle.caption2.copyWith(color: KdhColor.gray400),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: StepProgressHeader(currentStep: 1, totalSteps: 5),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('운동 목적 선택', style: KdhTextStyle.heading3),
                    const SizedBox(height: 8),
                    Text(
                      '달성하고 싶은 목표를 선택해주세요',
                      style: KdhTextStyle.body6.copyWith(
                        color: KdhColor.red500,
                      ),
                    ),
                    const SizedBox(height: 34),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 24) / 3;
                        return Row(
                          children: [
                            KdhSelectCard(
                              icon: SvgPicture.asset(
                                'assets/icons/diet.svg',
                                width: 36,
                                height: 36,
                                colorFilter: _selectedGoal == 0
                                    ? const ColorFilter.mode(
                                        KdhColor.red500,
                                        BlendMode.srcIn,
                                      )
                                    : null,
                              ),
                              label: '다이어트',
                              selected: _selectedGoal == 0,
                              size: cardWidth,
                              onTap: () => _selectGoal(0),
                            ),
                            const SizedBox(width: 12),
                            KdhSelectCard(
                              icon: SvgPicture.asset(
                                'assets/icons/healthy.svg',
                                width: 36,
                                height: 36,
                                colorFilter: _selectedGoal == 1
                                    ? const ColorFilter.mode(
                                        KdhColor.red500,
                                        BlendMode.srcIn,
                                      )
                                    : null,
                              ),
                              label: '건강',
                              selected: _selectedGoal == 1,
                              size: cardWidth,
                              onTap: () => _selectGoal(1),
                            ),
                            const SizedBox(width: 12),
                            KdhSelectCard(
                              icon: SvgPicture.asset(
                                'assets/icons/muscle.svg',
                                width: 36,
                                height: 36,
                                colorFilter: _selectedGoal == 2
                                    ? const ColorFilter.mode(
                                        KdhColor.red500,
                                        BlendMode.srcIn,
                                      )
                                    : null,
                              ),
                              label: '근육 증가',
                              selected: _selectedGoal == 2,
                              size: cardWidth,
                              onTap: () => _selectGoal(2),
                            ),
                          ],
                        );
                      },
                    ),

                    if (_selectedGoal == 0) ...[
                      const SizedBox(height: 20),
                      Text('목표 몸무게', style: KdhTextStyle.body4),
                      const SizedBox(height: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 48,
                        decoration: BoxDecoration(
                          color: KdhColor.background,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: _weightFocused
                                ? KdhColor.red200
                                : KdhColor.gray200,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _weightController,
                                focusNode: _weightFocusNode,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,1}$'),
                                  ),
                                ],
                                onChanged: (_) => setState(() {}),
                                style: KdhTextStyle.body7.copyWith(
                                  color: KdhColor.gray800,
                                ),
                                decoration: InputDecoration(
                                  hintText: '소수점 첫번째 자리까지 작성해주세요',
                                  hintStyle: KdhTextStyle.body7.copyWith(
                                    color: KdhColor.gray400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'kg',
                              style: KdhTextStyle.body7.copyWith(
                                color: KdhColor.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_selectedGoal == 2) ...[
                      const SizedBox(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyDiagram(selectedMuscles: _selectedMuscles),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionLabel('상체'),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _upperMuscles
                                      .map(_buildMuscleChip)
                                      .toList(),
                                ),
                                _gap16,
                                _sectionLabel('코어'),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _coreMuscles
                                      .map(_buildMuscleChip)
                                      .toList(),
                                ),
                                _gap16,
                                _sectionLabel('하체'),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _lowerMuscles
                                      .map(_buildMuscleChip)
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: KdhButton(
                label: '다음',
                onPressed: _canProceed
                    ? () => context.push(RouterPath.aiRoutineStep2)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
