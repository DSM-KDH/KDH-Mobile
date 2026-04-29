import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:kdh_mobile/features/home/presentation/providers/routine_provider.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/empty_routine_view.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/monthly_calendar.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/routine_check_item.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/weekly_calendar.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime _selectedDate = DateTime.now();
  bool _isCalendarExpanded = false;
  DateTime _displayedMonth = DateTime.now();

  static const double _toggleHeight = 38.0;

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(homeRoutineProvider.notifier);
      notifier.loadDates();
      notifier.loadRoutinesForDate(_dateKey(DateTime.now()));
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _displayedMonth = DateTime(date.year, date.month);
    });
    ref.read(homeRoutineProvider.notifier).loadRoutinesForDate(_dateKey(date));
  }

  void _onRoutineToggle(int exerciseId, bool currentCompleted) {
    ref
        .read(homeRoutineProvider.notifier)
        .toggleCompletion(
          exerciseId: exerciseId,
          completed: !currentCompleted,
          dateKey: _dateKey(_selectedDate),
        );
  }

  void _onPrevMonth() => setState(
    () => _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month - 1,
    ),
  );

  void _onNextMonth() => setState(
    () => _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
    ),
  );

  bool get _isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = ref.watch(authProvider).displayName;
    final routineState = ref.watch(homeRoutineProvider);
    final workouts = routineState.currentWorkouts;
    final routines = workouts.map((w) => w.toRoutine()).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text('$displayName님의 오늘의 루틴은?', style: KdhTextStyle.body3),
          ),
          AbsorbPointer(
            absorbing: _isCalendarExpanded,
            child: WeeklyCalendar(
              selectedDate: _selectedDate,
              datesWithRoutines: routineState.routineDates,
              onDateSelected: _onDateSelected,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (routineState.isLoadingRoutines)
                  const Padding(
                    padding: EdgeInsets.only(top: _toggleHeight + 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (routines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: _toggleHeight),
                    child: const EmptyRoutineView(),
                  )
                else
                  ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      _toggleHeight + 16,
                      16,
                      8,
                    ),
                    itemCount: routines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => RoutineCheckItem(
                      routine: routines[i],
                      isToday: _isSelectedDateToday,
                      onToggle: () => _onRoutineToggle(
                        workouts[i].exerciseId,
                        workouts[i].completed,
                      ),
                      onActionTap: () {},
                    ),
                  ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: KdhColor.red100,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isCalendarExpanded)
                          MonthlyCalendar(
                            displayedMonth: _displayedMonth,
                            selectedDate: _selectedDate,
                            dateCompletionMap: routineState.completionMap,
                            onDateSelected: _onDateSelected,
                            onPrevMonth: _onPrevMonth,
                            onNextMonth: _onNextMonth,
                          ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _isCalendarExpanded = !_isCalendarExpanded,
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            height: _toggleHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '달력 더보기',
                                  style: KdhTextStyle.caption1.copyWith(
                                    color: KdhColor.red200,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                  turns: _isCalendarExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(
                                    Symbols.keyboard_arrow_down_rounded,
                                    color: KdhColor.red200,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
