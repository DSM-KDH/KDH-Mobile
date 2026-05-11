import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:material_symbols_icons/symbols.dart';

class AiRoutineSuccessView extends StatelessWidget {
  const AiRoutineSuccessView({super.key, this.onGoHome});

  final VoidCallback? onGoHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: KdhColor.aiRoutineGradient,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 100, 24, 0),
                  child: Text(
                    'AI로 맞춤 루틴을\n생성했어요!',
                    textAlign: TextAlign.center,
                    style: KdhTextStyle.heading1.copyWith(
                      color: KdhColor.background,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -30,
                        left: 20,
                        child: Image.asset(
                          'assets/images/firecrack2.png',
                          width: 160,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: -10,
                        child: Transform.scale(
                          scale: 1.4,
                          child: Image.asset(
                            'assets/images/firecrack1.png',
                            width: 250,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -200,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            'assets/images/excercise_person.png',
                            width: 180,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            onGoHome?.call();
                            context.go(RouterPath.home);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              color: KdhColor.red200,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Text(
                                    '루틴 확인하러 가기',
                                    style: KdhTextStyle.heading3.copyWith(
                                      color: KdhColor.background,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Symbols.arrow_forward_rounded,
                                    color: KdhColor.background,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
