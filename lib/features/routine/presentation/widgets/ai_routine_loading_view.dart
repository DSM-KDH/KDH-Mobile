import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class AiRoutineLoadingView extends StatelessWidget {
  const AiRoutineLoadingView({super.key, this.onExit, this.message});

  final VoidCallback? onExit;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(-1, 1, 1),
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Image.asset(
                          'assets/images/running_person.png',
                          width: 83,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message ?? 'AI로 맞춤 루틴 짜는 중...',
                      textAlign: TextAlign.center,
                      style: KdhTextStyle.heading3.copyWith(
                        color: KdhColor.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onExit != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '루틴 생성 중에 이 화면을 나가도 생성은 진행됩니다',
                  textAlign: TextAlign.center,
                  style: KdhTextStyle.caption2.copyWith(
                    color: KdhColor.gray400,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: GestureDetector(
                  onTap: onExit,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: KdhColor.red50,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '화면 나가기',
                      style: KdhTextStyle.body4.copyWith(
                        color: KdhColor.red400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
