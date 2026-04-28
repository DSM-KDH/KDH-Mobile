import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/features/timer/presentation/widgets/timer_button.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Column(
          children: [
            TimerButton(
              title: '인터벌 타이머',
              subtitle: '3분-1분-2분 간격으로 효과음이 발출됩니다.\n인터벌 타이머 템플릿으로 운동해보세요!',
              backgroundColor: KdhColor.red50,
              titleColor: KdhColor.gray800,
              subtitleColor: KdhColor.gray400,
              playerIconColor: KdhColor.red200,
              onTap: () => context.push(RouterPath.intervalTimerSetup),
            ),
            const SizedBox(height: 16),
            TimerButton(
              title: '사용자 설정 타이머',
              subtitle: '원하시는 타이머가 없다면?\n직접 타이머를 설정하여 운동을 즐겨보세요!',
              backgroundColor: KdhColor.red100,
              titleColor: KdhColor.gray800,
              subtitleColor: KdhColor.gray400,
              playerIconColor: KdhColor.background,
              onTap: () => context.push(RouterPath.customTimerSetup),
            ),
            const SizedBox(height: 16),
            TimerButton(
              title: '메트로놈',
              subtitle: '이두컬, 윗몸일으키기, 팔굽혀펴기 등\n박자가 필요하다면 사용해보세요!',
              backgroundColor: KdhColor.red200,
              titleColor: KdhColor.background,
              subtitleColor: KdhColor.background,
              playerIconColor: KdhColor.red50,
              onTap: () => context.push(RouterPath.metronomeSetup),
            ),
          ],
        ),
      ),
    );
  }
}
