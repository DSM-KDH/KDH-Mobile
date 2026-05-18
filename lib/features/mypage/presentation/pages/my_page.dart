import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/extensions/build_context_feedback_extension.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:kdh_mobile/features/home/presentation/providers/routine_provider.dart';
import 'package:kdh_mobile/features/mypage/presentation/providers/user_profile_provider.dart';
import 'package:kdh_mobile/features/mypage/presentation/providers/weight_history_provider.dart';
import 'package:kdh_mobile/features/mypage/presentation/widgets/weight_chart.dart';
import 'package:kdh_mobile/features/mypage/presentation/widgets/weekly_routine_card.dart';
import 'package:material_symbols_icons/symbols.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(homeRoutineProvider.notifier);
      final routineState = ref.read(homeRoutineProvider);
      final todayKey = _dateKey(DateTime.now());

      if (routineState.routineDates.isEmpty && !routineState.isLoadingDates) {
        notifier.loadDates();
      }

      if (!routineState.completionMap.containsKey(todayKey)) {
        notifier.loadCompletionStatus(todayKey);
      }
    });
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await context.showKdhConfirmDialog(
      title: '로그아웃할까요?',
      message: '현재 기기에서 로그아웃합니다.',
      confirmLabel: '로그아웃',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await ref.read(authProvider.notifier).logout();
    if (!context.mounted) {
      return;
    }

    if (success) {
      context.go(RouterPath.onboarding);
      return;
    }

    final message = ref.read(authProvider).error ?? '로그아웃에 실패했습니다.';
    context.showKdhSnackBar(message);
  }

  Future<void> _handleWithdrawal(BuildContext context, WidgetRef ref) async {
    final confirmed = await context.showKdhConfirmDialog(
      title: '회원탈퇴할까요?',
      message: '회원 정보 및 모든 정보가 삭제됩니다.\n탈퇴 후에는 되돌릴 수 없어요.',
      confirmLabel: '네, 탈퇴할게요',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await ref.read(authProvider.notifier).withdrawal();
    if (!context.mounted) {
      return;
    }

    if (success) {
      context.go(RouterPath.onboarding);
      return;
    }

    final message = ref.read(authProvider).error ?? '회원탈퇴에 실패했습니다.';
    context.showKdhSnackBar(message);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authDisplayName = authState.displayName;
    final userEmail = authState.userEmail;
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;
    final displayName = (profile.name != null && profile.name!.isNotEmpty)
        ? profile.name!
        : authDisplayName;
    final weightHistory = ref.watch(weightHistoryProvider);
    final routineState = ref.watch(homeRoutineProvider);

    final distinctMonths = weightHistory
        .map((e) => '${e.date.year}-${e.date.month}')
        .toSet()
        .length;
    final showChart = distinctMonths >= 3;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          SingleChildScrollView(
            // 하단 고정 회원탈퇴 버튼과 겹치지 않도록 여백
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('마이페이지', style: KdhTextStyle.body3),
                    IconButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => _handleLogout(context, ref),
                      icon: authState.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Symbols.logout,
                              size: 20,
                              color: KdhColor.gray800,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: KdhColor.red200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.person,
                        color: KdhColor.gray50,
                        size: 50,
                        fill: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: KdhTextStyle.body5),
                          const SizedBox(height: 2),
                          Text(
                            (userEmail != null && userEmail.contains('@'))
                                ? userEmail
                                : profile.subtitle,
                            style: KdhTextStyle.caption2.copyWith(
                              color: KdhColor.gray400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouterPath.userSettings),
                      child: const Icon(
                        Symbols.settings,
                        color: KdhColor.gray400,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => context.push(RouterPath.aiRoutinePrompt),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: KdhColor.red50,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'AI 루틴 생성하러 가기',
                            style: KdhTextStyle.body6,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: KdhColor.gray800,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Text('몸무게 변화', style: KdhTextStyle.body5),
                const SizedBox(height: 16),
                if (showChart)
                  WeightChart(entries: weightHistory)
                else
                  SizedBox(
                    height: 80,
                    child: Center(
                      child: Text(
                        '아직 데이터가 쌓이지 않았어요',
                        style: KdhTextStyle.body6.copyWith(
                          color: KdhColor.gray400,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),

                Text('이번주 루틴 달성률', style: KdhTextStyle.body5),
                const SizedBox(height: 16),
                routineState.isLoadingDates
                    ? const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : WeeklyRoutineCard(
                        routineDates: routineState.routineDates,
                        completionMap: routineState.completionMap,
                        exerciseCountMap: routineState.exerciseCountMap,
                      ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: authState.isLoading
                    ? null
                    : () => _handleWithdrawal(context, ref),
                child: Text(
                  '회원탈퇴',
                  style: KdhTextStyle.body6.copyWith(
                    color: KdhColor.gray300,
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                    decorationColor: KdhColor.gray300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
