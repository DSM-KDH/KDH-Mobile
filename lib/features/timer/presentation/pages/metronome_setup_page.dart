import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/step_progress_header.dart';
import 'package:kdh_mobile/features/timer/presentation/providers/metronome_controller.dart';

class MetronomeSetupPage extends StatefulWidget {
  const MetronomeSetupPage({super.key});

  @override
  State<MetronomeSetupPage> createState() => _MetronomeSetupPageState();
}

class _MetronomeSetupPageState extends State<MetronomeSetupPage> {
  static const double _itemExtent = 32.0;
  static const int _visibleItems = 7;

  final TextEditingController _bpmController = TextEditingController();
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  int _bpm = 0;
  int _selectedHour = 0;
  int _selectedMinute = 0;

  bool get _isValid =>
      _bpm >= 40 &&
      _bpm <= 218 &&
      (_selectedHour > 0 || _selectedMinute > 0);

  int get _totalSeconds => (_selectedHour * 60 + _selectedMinute) * 60;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _bpmController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _onBpmChanged(String value) {
    setState(() => _bpm = int.tryParse(value) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: StepProgressHeader(
                currentStep: 1,
                totalSteps: 1,
                title: '메트로놈',
                showStepIndicator: false,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BPM을 설정해주세요', style: KdhTextStyle.body4),
                    const SizedBox(height: 12),
                    _buildBpmField(),
                    const SizedBox(height: 28),
                    Text('타이머를 몇 시간동안 반복할까요?', style: KdhTextStyle.body4),
                    _buildPicker(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: KdhButton(
                label: '시작하기',
                onPressed: _isValid
                    ? () => context.push(
                        RouterPath.metronome,
                        extra: MetronomeConfig(
                          bpm: _bpm,
                          totalSeconds: _totalSeconds,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBpmField() {
    final hasValue = _bpm > 0;
    return TextField(
      controller: _bpmController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      onChanged: _onBpmChanged,
      style: KdhTextStyle.body4,
      decoration: InputDecoration(
        hintText: '40~218',
        hintStyle: KdhTextStyle.body7.copyWith(color: KdhColor.gray400),
        suffixText: 'BPM',
        suffixStyle: KdhTextStyle.body7.copyWith(color: KdhColor.gray400),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: hasValue ? KdhColor.red200 : KdhColor.gray200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: KdhColor.red200),
        ),
      ),
    );
  }

  Widget _buildPicker() {
    const double pickerHeight = _itemExtent * _visibleItems;
    final bgColor = KdhColor.background;

    return SizedBox(
      height: pickerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: _itemExtent,
                decoration: BoxDecoration(
                  color: KdhColor.red50,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWheelPicker(
                controller: _hourController,
                count: 6,
                selectedValue: _selectedHour,
                onChanged: (v) => setState(() => _selectedHour = v),
              ),
              Text('시간', style: KdhTextStyle.body4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('-', style: KdhTextStyle.body4),
              ),
              _buildWheelPicker(
                controller: _minuteController,
                count: 60,
                selectedValue: _selectedMinute,
                onChanged: (v) => setState(() => _selectedMinute = v),
              ),
              Text('분', style: KdhTextStyle.body4),
            ],
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: pickerHeight * 0.36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgColor, bgColor.withValues(alpha: 0.0)],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: pickerHeight * 0.36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [bgColor, bgColor.withValues(alpha: 0.0)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelPicker({
    required FixedExtentScrollController controller,
    required int count,
    required int selectedValue,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 52,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: _itemExtent,
        onSelectedItemChanged: onChanged,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.006,
        diameterRatio: 1.2,
        squeeze: 0.9,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, index) => Center(
            child: Text(
              '$index',
              style: KdhTextStyle.body2.copyWith(
                color: index == selectedValue
                    ? KdhColor.gray800
                    : KdhColor.gray400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
