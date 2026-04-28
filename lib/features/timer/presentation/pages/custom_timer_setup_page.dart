import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/step_progress_header.dart';
import 'package:kdh_mobile/features/timer/presentation/providers/custom_timer_controller.dart';

class CustomTimerSetupPage extends StatefulWidget {
  const CustomTimerSetupPage({super.key});

  @override
  State<CustomTimerSetupPage> createState() => _CustomTimerSetupPageState();
}

class _CustomTimerSetupPageState extends State<CustomTimerSetupPage> {
  static const double _itemExtent = 32.0;
  static const int _visibleItems = 7;

  final TextEditingController _countController = TextEditingController();
  late final FixedExtentScrollController _repeatHourController;
  late final FixedExtentScrollController _repeatMinuteController;

  int _count = 0;
  List<int> _timerSeconds = [];
  int _repeatHour = 0;
  int _repeatMinute = 0;

  bool get _isValid {
    if (_count == 0) return false;
    if (_timerSeconds.any((s) => s == 0)) return false;
    if (_repeatHour == 0 && _repeatMinute == 0) return false;
    final timerSum = _timerSeconds.fold<int>(0, (sum, s) => sum + s);
    return _repeatTotalSeconds >= timerSum;
  }

  int get _repeatTotalSeconds => (_repeatHour * 60 + _repeatMinute) * 60;

  @override
  void initState() {
    super.initState();
    _repeatHourController = FixedExtentScrollController(
      initialItem: _repeatHour,
    );
    _repeatMinuteController = FixedExtentScrollController(
      initialItem: _repeatMinute,
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    _repeatHourController.dispose();
    _repeatMinuteController.dispose();
    super.dispose();
  }

  bool _ignoreCountChange = false;

  void _onCountChanged(String value) {
    if (_ignoreCountChange) return;
    final n = int.tryParse(value) ?? 0;
    if (n > 5) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(_buildSnackBar('최대 5개까지만 입력이 가능합니다.'));
      _ignoreCountChange = true;
      _countController.text = _count > 0 ? '$_count' : '';
      _countController.selection = TextSelection.fromPosition(
        TextPosition(offset: _countController.text.length),
      );
      _ignoreCountChange = false;
      return;
    }
    setState(() {
      _count = n;
      if (_timerSeconds.length < _count) {
        _timerSeconds = [
          ..._timerSeconds,
          ...List.filled(_count - _timerSeconds.length, 0),
        ];
      } else if (_timerSeconds.length > _count) {
        _timerSeconds = _timerSeconds.sublist(0, _count);
      }
    });
  }

  SnackBar _buildSnackBar(String message) => SnackBar(
    content: Text(message, style: KdhTextStyle.body7),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(milliseconds: 1500),
    backgroundColor: KdhColor.red50,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
  );

  void _showDurationSheet(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KdhColor.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TimerDurationSheet(
        title: '${index + 1}번 타이머의 시간을 설정해주세요',
        initialSeconds: _timerSeconds[index],
        onConfirm: (seconds) => setState(() => _timerSeconds[index] = seconds),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final parts = <String>[];
    if (h > 0) parts.add('$h 시간');
    if (m > 0) parts.add('$m 분');
    if (s > 0) parts.add('$s 초');
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final hasCount = _count > 0;

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
                title: '사용자 설정 타이머',
                showStepIndicator: false,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('몇 개의 타이머로 나눌까요?', style: KdhTextStyle.body4),
                    const SizedBox(height: 12),
                    _buildCountField(),
                    if (hasCount) ...[
                      const SizedBox(height: 28),
                      Text('각 타이머 별 시간을 설정해주세요', style: KdhTextStyle.body4),
                      const SizedBox(height: 16),
                      ...List.generate(_count, (i) => _buildTimerRow(i)),
                      const SizedBox(height: 28),
                      Text('타이머를 몇 시간동안 반복할까요?', style: KdhTextStyle.body4),
                      _buildRepeatPicker(),
                      KdhButton(
                        label: '시작하기',
                        onPressed: _isValid
                            ? () => context.push(
                                RouterPath.customTimer,
                                extra: CustomTimerConfig(
                                  intervals: List.unmodifiable(_timerSeconds),
                                  totalSeconds: _repeatTotalSeconds,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountField() {
    final hasValue = _count > 0;
    return TextField(
      controller: _countController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
      ],
      onChanged: _onCountChanged,
      style: KdhTextStyle.body4,
      decoration: InputDecoration(
        hintText: '최대 5개까지 나눌 수 있습니다',
        hintStyle: KdhTextStyle.body7.copyWith(color: KdhColor.gray400),
        suffixText: '개',
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

  Widget _buildTimerRow(int index) {
    final seconds = _timerSeconds[index];
    final isSet = seconds > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('${index + 1}번', style: KdhTextStyle.body4),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showDurationSheet(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: KdhColor.gray50,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isSet ? KdhColor.red200 : Colors.transparent,
                ),
              ),
              child: Text(
                isSet ? _formatDuration(seconds) : '-- 시간  -- 분  -- 초',
                style: KdhTextStyle.body4.copyWith(
                  color: isSet ? KdhColor.gray800 : KdhColor.gray400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatPicker() {
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
                controller: _repeatHourController,
                count: 6,
                selectedValue: _repeatHour,
                onChanged: (v) => setState(() => _repeatHour = v),
              ),
              Text('시간', style: KdhTextStyle.body4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('-', style: KdhTextStyle.body4),
              ),
              _buildWheelPicker(
                controller: _repeatMinuteController,
                count: 60,
                selectedValue: _repeatMinute,
                onChanged: (v) => setState(() => _repeatMinute = v),
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

class _TimerDurationSheet extends StatefulWidget {
  final String title;
  final int initialSeconds;
  final ValueChanged<int> onConfirm;

  const _TimerDurationSheet({
    required this.title,
    required this.initialSeconds,
    required this.onConfirm,
  });

  @override
  State<_TimerDurationSheet> createState() => _TimerDurationSheetState();
}

class _TimerDurationSheetState extends State<_TimerDurationSheet> {
  static const double _itemExtent = 32.0;
  static const int _visibleItems = 7;

  late final FixedExtentScrollController _hController;
  late final FixedExtentScrollController _mController;
  late final FixedExtentScrollController _sController;

  late int _h;
  late int _m;
  late int _s;

  @override
  void initState() {
    super.initState();
    _h = widget.initialSeconds ~/ 3600;
    _m = (widget.initialSeconds % 3600) ~/ 60;
    _s = widget.initialSeconds % 60;
    _hController = FixedExtentScrollController(initialItem: _h);
    _mController = FixedExtentScrollController(initialItem: _m);
    _sController = FixedExtentScrollController(initialItem: _s);
  }

  @override
  void dispose() {
    _hController.dispose();
    _mController.dispose();
    _sController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double pickerHeight = _itemExtent * _visibleItems;
    final bgColor = KdhColor.background;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: KdhTextStyle.body2),
          SizedBox(
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
                    _buildWheel(
                      controller: _hController,
                      count: 6,
                      selected: _h,
                      onChanged: (v) => setState(() => _h = v),
                    ),
                    Text('시간', style: KdhTextStyle.body2),
                    const SizedBox(width: 16),
                    _buildWheel(
                      controller: _mController,
                      count: 60,
                      selected: _m,
                      onChanged: (v) => setState(() => _m = v),
                    ),
                    Text('분', style: KdhTextStyle.body2),
                    const SizedBox(width: 16),
                    _buildWheel(
                      controller: _sController,
                      count: 60,
                      selected: _s,
                      onChanged: (v) => setState(() => _s = v),
                    ),
                    Text('초', style: KdhTextStyle.body2),
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
          ),
          KdhButton(
            label: '확인',
            onPressed: () {
              widget.onConfirm(_h * 3600 + _m * 60 + _s);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int count,
    required int selected,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 44,
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
                color: index == selected ? KdhColor.gray800 : KdhColor.gray400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
