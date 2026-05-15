import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/features/mypage/presentation/providers/user_profile_provider.dart';

const _gap16 = SizedBox(height: 16);

class AiRoutinePromptPage extends ConsumerWidget {
  const AiRoutinePromptPage({super.key});

  void _onGenerateTap(BuildContext context, bool hasUserInfo) {
    if (!hasUserInfo) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withAlpha(80),
        builder: (_) => const _NoUserInfoDialog(),
      );
      return;
    }
    context.push(RouterPath.aiRoutineStep1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUserInfo = ref.watch(userProfileProvider).profile.hasRequiredInfo;

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                  child: Text(
                    'AI로 맞춤 루틴을\n생성하세요!',
                    style: KdhTextStyle.heading2.copyWith(
                      color: KdhColor.background,
                      height: 1.3,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/images/running.svg',
                          fit: BoxFit.fitWidth,
                        ),
                      ),

                      Positioned(
                        top: 20,
                        right: 50,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final scale =
                                MediaQuery.of(context).size.width / 390;
                            return Transform.rotate(
                              angle: 26 * pi / 180,
                              child: Transform.scale(
                                scaleX: -1,
                                child: Image.asset(
                                  'assets/images/running_person.png',
                                  width: 131 * scale,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Positioned(
                        bottom: -25,
                        left: -15,
                        child: Image.asset(
                          'assets/images/excercise_person.png',
                          width: 300,
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
                        _GenerateButton(
                          onPressed: () => _onGenerateTap(context, hasUserInfo),
                        ),
                        _gap16,
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '아니요 그냥 살래요',
                              style: KdhTextStyle.caption4.copyWith(
                                color: KdhColor.gray400,
                              ),
                            ),
                          ),
                        ),
                        _gap16,
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

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: KdhColor.red50,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: KdhColor.red100, width: 3),
          boxShadow: [
            BoxShadow(
              color: KdhColor.gray800.withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text('AI 루틴 생성하러 가기', style: KdhTextStyle.body3),
      ),
    );
  }
}

class _NoUserInfoDialog extends StatelessWidget {
  const _NoUserInfoDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: KdhColor.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '사용자 정보를 입력해주세요!',
              style: KdhTextStyle.body3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '사용자 정보를 입력한 후에\nAI 루틴 생성 기능을 이용할 수 있어요!',
              style: KdhTextStyle.caption2.copyWith(color: KdhColor.gray400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.go(RouterPath.profile);
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: KdhColor.red100,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text('사용자 정보 입력하러 가기', style: KdhTextStyle.caption3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
