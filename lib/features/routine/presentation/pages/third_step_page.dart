import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/step_progress_header.dart';

const _gap8 = SizedBox(height: 8);
const _gap20 = SizedBox(height: 20);

class ThirdStepPage extends StatefulWidget {
  const ThirdStepPage({super.key});

  @override
  State<ThirdStepPage> createState() => _ThirdStepPageState();
}

class _ThirdStepPageState extends State<ThirdStepPage> {
  final _weeksController = TextEditingController();
  final _hoursController = TextEditingController();
  final _weeksFocus = FocusNode();
  final _hoursFocus = FocusNode();
  bool _weeksFocused = false;
  bool _hoursFocused = false;

  final Set<int> _selectedDays = {};
  static const _days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

  bool get _canProceed =>
      _weeksController.text.trim().isNotEmpty &&
      _hoursController.text.trim().isNotEmpty &&
      _selectedDays.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _weeksFocus.addListener(
      () => setState(() => _weeksFocused = _weeksFocus.hasFocus),
    );
    _hoursFocus.addListener(
      () => setState(() => _hoursFocused = _hoursFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _weeksController.dispose();
    _hoursController.dispose();
    _weeksFocus.dispose();
    _hoursFocus.dispose();
    super.dispose();
  }

  SnackBar _buildLimitSnackBar(String message) => SnackBar(
        content: Text(message, style: KdhTextStyle.body7),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1000),
        backgroundColor: KdhColor.red50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      );

  Widget _buildNumberField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool focused,
    required String hint,
    required String suffix,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 48,
      decoration: BoxDecoration(
        color: KdhColor.background,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: focused ? KdhColor.red200 : KdhColor.gray200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: KdhTextStyle.body7.copyWith(color: KdhColor.gray800),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: KdhTextStyle.body7.copyWith(color: KdhColor.gray400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Text(
            suffix,
            style: KdhTextStyle.body7.copyWith(color: KdhColor.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip(int index) {
    final selected = _selectedDays.contains(index);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedDays.remove(index);
        } else {
          _selectedDays.add(index);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? KdhColor.red200 : KdhColor.background,
          borderRadius: BorderRadius.circular(50),
          border: selected
              ? null
              : Border.all(color: KdhColor.red50, width: 1.5),
        ),
        child: Text(
          _days[index],
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
              child: StepProgressHeader(currentStep: 3, totalSteps: 5),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('운동 가능 시간', style: KdhTextStyle.heading3),
                    _gap8,
                    Text(
                      '운동이 가능한 시간대를 선택해주세요',
                      style: KdhTextStyle.body6.copyWith(
                        color: KdhColor.red500,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text('이 루틴을 얼마나 유지할까요?', style: KdhTextStyle.body5),
                    _gap8,
                    _buildNumberField(
                      controller: _weeksController,
                      focusNode: _weeksFocus,
                      focused: _weeksFocused,
                      hint: '최대 24주까지 가능해요',
                      suffix: '주',
                    ),
                    _gap20,
                    Text('하루에 얼마나 운동 할까요?', style: KdhTextStyle.body5),
                    _gap8,
                    _buildNumberField(
                      controller: _hoursController,
                      focusNode: _hoursFocus,
                      focused: _hoursFocused,
                      hint: '최대 5시간까지 가능해요',
                      suffix: '시간',
                    ),
                    _gap20,
                    Text('가능한 요일을 선택해주세요', style: KdhTextStyle.body5),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        _days.length,
                        (i) => _buildDayChip(i),
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
                onPressed: _canProceed
                    ? () {
                        final weeks =
                            int.tryParse(_weeksController.text.trim()) ?? 0;
                        final hours =
                            double.tryParse(_hoursController.text.trim()) ?? 0;
                        if (weeks > 24) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            _buildLimitSnackBar('루틴 유지 기간은 최대 24주까지 가능해요'),
                          );
                          return;
                        }
                        if (hours > 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            _buildLimitSnackBar('운동 시간은 최대 5시간까지 가능해요'),
                          );
                          return;
                        }
                        context.push(RouterPath.aiRoutineStep4);
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
