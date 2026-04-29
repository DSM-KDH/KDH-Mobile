import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/home/domain/entities/routine.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/empty_routine_view.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/monthly_calendar.dart'
    show MonthlyCalendar, DayCompletionStatus;
import 'package:kdh_mobile/features/home/presentation/widgets/routine_check_item.dart';
import 'package:kdh_mobile/features/home/presentation/widgets/weekly_calendar.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userName = '하원'});

  final String userName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  bool _isCalendarExpanded = false;
  DateTime _displayedMonth = DateTime.now();
  static const double _toggleHeight = 38.0;

  late final Map<String, List<Routine>> _routineData = {
    _key(DateTime.now()): [
      const Routine(
        id: '1',
        title: '인터벌 러닝',
        subtitle: '2시간 · 원하는 형식으로',
        status: RoutineStatus.done,
        imagePath: 'assets/images/sample.png',
      ),
      const Routine(
        id: '2',
        title: '덤벨컬',
        subtitle: '2kg · 12회 · 4세트',
        status: RoutineStatus.done,
      ),
      const Routine(
        id: '3',
        title: '스쿼트',
        subtitle: '10회 · 10세트',
        status: RoutineStatus.done,
      ),
      const Routine(
        id: '4',
        title: '플랭크',
        subtitle: '5분하고 1분 쉬기',
        status: RoutineStatus.todo,
      ),
    ],
    _key(DateTime.now().subtract(const Duration(days: 2))): [
      const Routine(
        id: '5',
        title: '요가',
        subtitle: '30분 · 유연성 루틴',
        status: RoutineStatus.done,
      ),
      const Routine(
        id: '6',
        title: '런닝',
        subtitle: '5km · 30분',
        status: RoutineStatus.skipped,
      ),
    ],
    _key(DateTime.now().add(const Duration(days: 2))): [
      const Routine(
        id: '7',
        title: '수영',
        subtitle: '1시간 · 자유형',
        status: RoutineStatus.todo,
      ),
    ],
  };

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Routine> get _currentRoutines => _routineData[_key(_selectedDate)] ?? [];

  Set<String> get _datesWithRoutines => _routineData.keys.toSet();

  Map<String, DayCompletionStatus> get _dateCompletionMap {
    final map = <String, DayCompletionStatus>{};
    for (final entry in _routineData.entries) {
      final routines = entry.value;
      if (routines.isEmpty) continue;
      final doneCount =
          routines.where((r) => r.status == RoutineStatus.done).length;
      if (doneCount == routines.length) {
        map[entry.key] = DayCompletionStatus.allDone;
      } else if (doneCount == 0) {
        map[entry.key] = DayCompletionStatus.noneDone;
      } else {
        map[entry.key] = DayCompletionStatus.partial;
      }
    }
    return map;
  }

  bool get _isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _onDateSelected(DateTime date) => setState(() {
    _selectedDate = date;
    _displayedMonth = DateTime(date.year, date.month);
  });

  void _onRoutineToggle(String routineId) {
    final key = _key(_selectedDate);
    final routines = _routineData[key];
    if (routines == null) return;
    setState(() {
      _routineData[key] = routines.map((r) {
        if (r.id != routineId) return r;
        return r.copyWith(
          status: r.status == RoutineStatus.done
              ? RoutineStatus.todo
              : r.status == RoutineStatus.todo
              ? RoutineStatus.done
              : RoutineStatus.skipped,
        );
      }).toList();
    });
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

  @override
  Widget build(BuildContext context) {
    final routines = _currentRoutines;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              '${widget.userName}님의 오늘의 루틴은?',
              style: KdhTextStyle.body3,
            ),
          ),
          AbsorbPointer(
            absorbing: _isCalendarExpanded,
            child: WeeklyCalendar(
              selectedDate: _selectedDate,
              datesWithRoutines: _datesWithRoutines,
              onDateSelected: _onDateSelected,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                routines.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: _toggleHeight),
                        child: const EmptyRoutineView(),
                      )
                    : ListView.separated(
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
                          onToggle: () => _onRoutineToggle(routines[i].id),
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
                            dateCompletionMap: _dateCompletionMap,
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
