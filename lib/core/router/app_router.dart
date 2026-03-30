import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/core/widgets/kdh_bottom_nav_bar.dart';
import 'package:kdh_mobile/features/auth/presentation/pages/onboarding_page.dart';
import 'package:kdh_mobile/features/routine/presentation/pages/ai_routine_prompt_page.dart';
import 'package:kdh_mobile/features/home/presentation/pages/home_page.dart';
import 'package:kdh_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:kdh_mobile/features/timer/presentation/pages/timer_page.dart';

final appRouter = GoRouter(
  initialLocation: RouterPath.onboarding,
  routes: [
    GoRoute(
      path: RouterPath.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: RouterPath.aiRoutinePrompt,
      builder: (context, state) => const AiRoutinePromptPage(),
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
          builder: (context, state) => const ProfilePage(),
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
