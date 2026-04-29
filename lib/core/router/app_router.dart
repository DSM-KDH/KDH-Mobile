import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_bottom_nav_bar.dart';
import 'package:kdh_mobile/features/auth/presentation/pages/oauth_webview_page.dart';
import 'package:kdh_mobile/features/auth/presentation/pages/onboarding_page.dart';
import 'package:kdh_mobile/features/home/presentation/pages/home_page.dart';
import 'package:kdh_mobile/features/mypage/presentation/pages/my_page.dart';
import 'package:kdh_mobile/features/mypage/presentation/pages/user_settings_page.dart';
import 'package:kdh_mobile/features/routine/presentation/pages/ai_routine_prompt_page.dart';
import 'package:kdh_mobile/features/routine/presentation/pages/ai_routine_result_page.dart';
import 'package:kdh_mobile/features/routine/presentation/pages/fifth_step_page.dart';
import 'package:kdh_mobile/features/routine/presentation/pages/first_step_page.dart';
import 'package:kdh_mobile/features/routine/presentation/pages/fourth_step_page.dart';
import 'package:kdh_mobile/features/routine/presentation/pages/second_step_page.dart';
import 'package:kdh_mobile/features/routine/presentation/pages/third_step_page.dart';
import 'package:kdh_mobile/features/timer/presentation/pages/custom_timer_page.dart';
import 'package:kdh_mobile/features/timer/presentation/pages/custom_timer_setup_page.dart';
import 'package:kdh_mobile/features/timer/presentation/pages/interval_timer_page.dart';
import 'package:kdh_mobile/features/timer/presentation/pages/interval_timer_setup_page.dart';
import 'package:kdh_mobile/features/timer/presentation/pages/metronome_page.dart';
import 'package:kdh_mobile/features/timer/presentation/pages/metronome_setup_page.dart';
import 'package:kdh_mobile/features/timer/presentation/pages/timer_page.dart';
import 'package:kdh_mobile/features/timer/presentation/providers/custom_timer_controller.dart';
import 'package:kdh_mobile/features/timer/presentation/providers/metronome_controller.dart';

final appRouter = GoRouter(
  initialLocation: RouterPath.onboarding,
  routes: [
    GoRoute(
      path: RouterPath.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: RouterPath.oauthWebView,
      builder: (context, state) {
        final authUrl = state.extra as String;
        return OAuthWebViewPage(authUrl: authUrl);
      },
    ),
    GoRoute(
      path: RouterPath.aiRoutinePrompt,
      builder: (context, state) => const AiRoutinePromptPage(),
    ),
    GoRoute(
      path: RouterPath.aiRoutineStep1,
      builder: (context, state) => const FirstStepPage(),
    ),
    GoRoute(
      path: RouterPath.aiRoutineStep2,
      builder: (context, state) => const SecondStepPage(),
    ),
    GoRoute(
      path: RouterPath.aiRoutineStep3,
      builder: (context, state) => const ThirdStepPage(),
    ),
    GoRoute(
      path: RouterPath.aiRoutineStep4,
      builder: (context, state) => const FourthStepPage(),
    ),
    GoRoute(
      path: RouterPath.aiRoutineStep5,
      builder: (context, state) => const FifthStepPage(),
    ),
    GoRoute(
      path: RouterPath.aiRoutineResult,
      builder: (context, state) => const AiRoutineResultPage(),
    ),
    GoRoute(
      path: RouterPath.userSettings,
      builder: (context, state) => const UserSettingsPage(),
    ),
    GoRoute(
      path: RouterPath.intervalTimerSetup,
      builder: (context, state) => const IntervalTimerSetupPage(),
    ),
    GoRoute(
      path: RouterPath.intervalTimer,
      builder: (context, state) {
        final totalSeconds = state.extra as int;
        return IntervalTimerPage(totalSeconds: totalSeconds);
      },
    ),
    GoRoute(
      path: RouterPath.customTimerSetup,
      builder: (context, state) => const CustomTimerSetupPage(),
    ),
    GoRoute(
      path: RouterPath.customTimer,
      builder: (context, state) {
        final config = state.extra as CustomTimerConfig;
        return CustomTimerPage(config: config);
      },
    ),
    GoRoute(
      path: RouterPath.metronomeSetup,
      builder: (context, state) => const MetronomeSetupPage(),
    ),
    GoRoute(
      path: RouterPath.metronome,
      builder: (context, state) {
        final config = state.extra as MetronomeConfig;
        return MetronomePage(config: config);
      },
    ),
    ShellRoute(
      builder: (context, state, child) =>
          _AppShell(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(
          path: RouterPath.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: RouterPath.timer,
          builder: (context, state) => const TimerPage(),
        ),
        GoRoute(
          path: RouterPath.profile,
          builder: (context, state) => const MyPage(),
        ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.location, required this.child});

  final String location;
  final Widget child;

  int get _currentIndex {
    if (location.startsWith(RouterPath.timer)) return 1;
    if (location.startsWith(RouterPath.profile)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      body: child,
      bottomNavigationBar: KdhBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go(RouterPath.home);
            case 1:
              context.go(RouterPath.timer);
            case 2:
              context.go(RouterPath.profile);
          }
        },
      ),
    );
  }
}
