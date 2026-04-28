import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/routine/presentation/widgets/step_progress_header.dart';
import 'package:kdh_mobile/features/timer/presentation/providers/interval_timer_provider.dart';
import 'package:kdh_mobile/features/timer/presentation/widgets/reset_button.dart';

class IntervalTimerPage extends ConsumerWidget {
  final int totalSeconds;

  const IntervalTimerPage({super.key, required this.totalSeconds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(intervalTimerProvider(totalSeconds));
    final notifier = ref.read(intervalTimerProvider(totalSeconds).notifier);
    final isReady = state.status == TimerStatus.ready;

    return Scaffold(
      backgroundColor: KdhColor.background,
      body: ColoredBox(
        color: isReady
            ? const Color(0xFF888686).withValues(alpha: 0.15)
            : Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isReady ? notifier.start : null,
          child: SafeArea(
            child: Column(
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimerCircle(context, state),
                      const SizedBox(height: 40),
                      ResetButton(
                        isActive: state.status != TimerStatus.ready,
                        onTap: notifier.reset,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCircle(BuildContext context, IntervalTimerState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.78;
    final isReady = state.status == TimerStatus.ready;

    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(circleSize, circleSize),
            painter: _ArcProgressPainter(
              progress: state.intervalProgress,
              status: state.status,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.currentIntervalDurationLabel,
                style: KdhTextStyle.caption1.copyWith(
                  color: isReady ? KdhColor.gray400 : KdhColor.gray800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                state.intervalElapsedLabel,
                style: KdhTextStyle.display.copyWith(
                  color: isReady ? KdhColor.gray400 : KdhColor.gray800,
                ),
              ),
              if (!isReady) ...[
                const SizedBox(height: 6),
                Text(
                  '${state.totalElapsedLabel} · ${state.currentSet}회',
                  style: KdhTextStyle.caption1.copyWith(
                    color: KdhColor.gray400,
                  ),
                ),
              ],
            ],
          ),
          if (isReady)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                color: KdhColor.red50,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '준비가 되었다면\n화면을 클릭하세요!',
                style: KdhTextStyle.body2.copyWith(color: KdhColor.gray800),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _ArcProgressPainter extends CustomPainter {
  final double progress;
  final TimerStatus status;

  const _ArcProgressPainter({required this.progress, required this.status});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (status == TimerStatus.ready) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = KdhColor.red100.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      return;
    }

    if (status == TimerStatus.finished) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = KdhColor.red400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = KdhColor.red50
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    if (progress > 0.01) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = KdhColor.red400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.status != status;
}
