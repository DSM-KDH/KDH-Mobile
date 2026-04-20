import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:kdh_mobile/features/mypage/domain/entities/user_profile.dart';
import 'package:kdh_mobile/features/mypage/presentation/providers/user_profile_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class UserSettingsPage extends ConsumerStatefulWidget {
  const UserSettingsPage({super.key});

  @override
  ConsumerState<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends ConsumerState<UserSettingsPage> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightFocus = FocusNode();
  final _weightFocus = FocusNode();

  bool _heightFocused = false;
  bool _weightFocused = false;
  Gender? _selectedGender;

  bool get _canComplete =>
      _heightController.text.trim().isNotEmpty &&
      _weightController.text.trim().isNotEmpty &&
      _selectedGender != null;

  @override
  void initState() {
    super.initState();

    final profile = ref.read(userProfileProvider);
    if (profile.height != null) {
      _heightController.text = '${profile.height}';
    }
    if (profile.weight != null) {
      _weightController.text = '${profile.weight}';
    }
    _selectedGender = profile.gender;

    _heightFocus.addListener(
      () => setState(() => _heightFocused = _heightFocus.hasFocus),
    );
    _weightFocus.addListener(
      () => setState(() => _weightFocused = _weightFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  void _onComplete() {
    ref
        .read(userProfileProvider.notifier)
        .update(
          height: double.tryParse(_heightController.text.trim()),
          weight: double.tryParse(_weightController.text.trim()),
          gender: _selectedGender,
        );
    context.pop();
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool focused,
    required String hint,
    required String suffix,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 52,
      decoration: BoxDecoration(
        color: KdhColor.background,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: focused ? KdhColor.red200 : KdhColor.gray200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')),
              ],
              onChanged: (_) => setState(() {}),
              style: KdhTextStyle.body7.copyWith(color: KdhColor.gray800),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: KdhTextStyle.body7.copyWith(color: KdhColor.gray300),
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

  Widget _buildGenderButton(Gender gender, String label) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? KdhColor.red100 : KdhColor.gray50,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              label,
              style: KdhTextStyle.body6.copyWith(
                color: isSelected ? KdhColor.red400 : KdhColor.gray400,
              ),
            ),
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
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Symbols.arrow_back_ios,
                      color: KdhColor.gray800,
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('사용자 설정', style: KdhTextStyle.body5),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: KdhColor.red200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Symbols.person,
                          color: KdhColor.gray50,
                          size: 50,
                          fill: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── 키 입력 ─────────────────────────────────────────
                    Text('키', style: KdhTextStyle.body5),
                    const SizedBox(height: 10),
                    _buildNumberField(
                      controller: _heightController,
                      focusNode: _heightFocus,
                      focused: _heightFocused,
                      hint: '소수점 첫번째 자리까지 작성해주세요',
                      suffix: 'cm',
                    ),
                    const SizedBox(height: 20),

                    // ── 몸무게 입력 ──────────────────────────────────────
                    Text('몸무게', style: KdhTextStyle.body5),
                    const SizedBox(height: 10),
                    _buildNumberField(
                      controller: _weightController,
                      focusNode: _weightFocus,
                      focused: _weightFocused,
                      hint: '소수점 첫번째 자리까지 작성해주세요',
                      suffix: 'kg',
                    ),
                    const SizedBox(height: 20),

                    // ── 성별 선택 ────────────────────────────────────────
                    Text('성별', style: KdhTextStyle.body5),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildGenderButton(Gender.male, '남'),
                        const SizedBox(width: 12),
                        _buildGenderButton(Gender.female, '여'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── 완료 버튼 ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: KdhButton(
                label: '완료',
                onPressed: _canComplete ? _onComplete : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
