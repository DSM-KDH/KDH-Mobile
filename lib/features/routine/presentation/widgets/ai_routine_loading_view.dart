import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class AiRoutineLoadingView extends StatelessWidget {
  const AiRoutineLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: Center(
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
                  0,      0,      0,      1, 0,
                ]),
                child: Image.asset(
                  'assets/images/running_person.png',
                  width: 83,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'AI로 맞춤 루틴 짜는 중...',
              style: KdhTextStyle.heading3.copyWith(color: KdhColor.gray500),
            ),
          ],
        ),
      ),
    );
  }
}
