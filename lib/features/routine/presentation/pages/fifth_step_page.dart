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

const _gap12 = SizedBox(height: 12);
const _gap24 = SizedBox(height: 24);

class FifthStepPage extends ConsumerStatefulWidget {
  const FifthStepPage({super.key});

  @override
  ConsumerState<FifthStepPage> createState() => _FifthStepPageState();
}

class _FifthStepPageState extends ConsumerState<FifthStepPage> {
  final Set<int> _selectedPlaces = {};
  final Set<String> _selectedEquipment = {};

  static const _places = [
    (label: '야외', svg: 'assets/icons/outdoor.svg'),
    (label: '헬스장', svg: 'assets/icons/gym.svg'),
    (label: '집', svg: 'assets/icons/home.svg'),
  ];

  static const _equipment = [
    '바벨', '덤벨', '케이블', '머신',
    '벤치', '철봉', '밴드', '랫풀다운',
    '스미스머신', '레그프레스', '펙덱플라이',
    '딥스바', '폼롤러', '사이클',
  ];

  bool get _canProceed => _selectedPlaces.isNotEmpty;

  Widget _buildEquipmentChip(String label) {
    final selected = _selectedEquipment.contains(label);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedEquipment.remove(label);
        } else {
          _selectedEquipment.add(label);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? KdhColor.red200 : KdhColor.background,
          borderRadius: BorderRadius.circular(50),
          border: selected
              ? null
              : Border.all(color: KdhColor.red50, width: 1.5),
        ),
        child: Text(
          label,
          style: KdhTextStyle.caption1.copyWith(
            color: selected ? KdhColor.background : KdhColor.gray800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: StepProgressHeader(currentStep: 5, totalSteps: 5),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('장소 & 기구', style: KdhTextStyle.heading3),
                    const SizedBox(height: 8),
                    Text(
                      '활용할 수 있는 장소와 기구를 선택해주세요',
                      style: KdhTextStyle.body6.copyWith(
                        color: KdhColor.red500,
                      ),
                    ),
                    const SizedBox(height: 34),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 24) / 3;
                        return Row(
                          children: List.generate(_places.length, (i) {
                            final place = _places[i];
                            final sel = _selectedPlaces.contains(i);
                            return Padding(
                              padding: EdgeInsets.only(
                                right: i < _places.length - 1 ? 12 : 0,
                              ),
                              child: KdhSelectCard(
                                icon: SvgPicture.asset(
                                  place.svg,
                                  width: 36,
                                  height: 36,
                                  colorFilter: sel
                                      ? const ColorFilter.mode(
                                          KdhColor.red500,
                                          BlendMode.srcIn,
                                        )
                                      : null,
                                ),
                                label: place.label,
                                selected: sel,
                                size: cardWidth,
                                onTap: () => setState(() {
                                  if (sel) {
                                    _selectedPlaces.remove(i);
                                  } else {
                                    _selectedPlaces.add(i);
                                  }
                                }),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    _gap12,
                    Text(
                      '복수 선택이 가능해요',
                      style: KdhTextStyle.caption2.copyWith(
                        color: KdhColor.gray400,
                      ),
                    ),
                    _gap24,
                    Text('사용 가능한 기구를 선택해주세요', style: KdhTextStyle.body5),
                    _gap12,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _equipment.map(_buildEquipmentChip).toList(),
                    ),
                    _gap24,
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: KdhButton(
                label: '완료',
                onPressed: _canProceed
                    ? () {
                        ref
                            .read(aiRoutineWizardProvider.notifier)
                            .setPlacesAndEquipment(
                              places: Set.from(_selectedPlaces),
                              equipment: Set.from(_selectedEquipment),
                            );
                        context.push(RouterPath.aiRoutineResult);
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
