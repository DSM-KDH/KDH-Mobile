import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:kdh_mobile/features/auth/presentation/widgets/google_sign_in_button.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              SvgPicture.asset('assets/images/kdh_logo.svg', width: 200),
              const SizedBox(height: 16),
              Text(
                'AI가 만드는 나만의 루틴',
                style: KdhTextStyle.body4.copyWith(color: KdhColor.gray300),
              ),
              const Spacer(),
              GoogleSignInButton(
                onPressed: () {
                  final authUrl =
                      ref.read(authProvider.notifier).getGoogleAuthUrl();
                  context.push(RouterPath.oauthWebView, extra: authUrl);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
