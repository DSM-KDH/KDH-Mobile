import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/step_progress_header.dart';

class IntervalTimerSetupPage extends StatefulWidget {
  const IntervalTimerSetupPage({super.key});

  @override
  State<IntervalTimerSetupPage> createState() => _IntervalTimerSetupPageState();
}

class _IntervalTimerSetupPageState extends State<IntervalTimerSetupPage> {
  static const double _itemExtent = 32.0;
  static const int _visibleItems = 7;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  int _selectedHour = 0;
  int _selectedMinute = 3;

  bool get _isValid => _selectedHour * 60 + _selectedMinute >= 3;

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
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
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
                title: '인터벌 타이머',
                showStepIndicator: false,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '타이머를 몇 시간동안 반복할까요?',
                        style: KdhTextStyle.body2,
                      ),
                    ),
                    _buildPicker(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: KdhButton(
                        label: '시작하기',
                        onPressed: _isValid
                            ? () => context.push(
                                RouterPath.intervalTimer,
                                extra: _totalSeconds,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
