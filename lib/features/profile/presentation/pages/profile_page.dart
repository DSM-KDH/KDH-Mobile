import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';
import 'package:kdh_mobile/core/widgets/kdh_day_selector.dart';
import 'package:kdh_mobile/core/widgets/kdh_search_field.dart';
import 'package:kdh_mobile/core/widgets/kdh_select_card.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 범용 토글 칩 예시
  Set<int> _selectedChips = {0, 2};

  // 선택 카드 예시 - 선택된 항목 인덱스
  final Set<int> _selectedCategories = {0, 2};

  final _categories = const [
    (icon: Symbols.monitor_heart_rounded, label: '유산소'),
    (icon: Symbols.fitness_center_rounded, label: '근력'),
    (icon: Symbols.accessibility_new_rounded, label: '맨몸'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        children: [
          // ── 검색 필드 ─────────────────────────────────────────────────────
          _SectionLabel('검색 필드'),
          const SizedBox(height: 12),
          const KdhSearchField(hint: '운동을 검색해보세요'),
          const SizedBox(height: 32),
          // ── 범용 토글 칩 (KdhToggleChipGroup) ────────────────────────────
          _SectionLabel('토글 칩'),
          const SizedBox(height: 12),
          KdhToggleChipGroup(
            items: const ['1세트', '2세트', '3세트', '4세트', '5세트'],
            selectedIndexes: _selectedChips,
            chipSize: 48,
            onChanged: (indexes) => setState(() => _selectedChips = indexes),
          ),
          const SizedBox(height: 32),

          // ── 선택 카드 ─────────────────────────────────────────────────────
          _SectionLabel('선택 카드'),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_categories.length, (i) {
              final cat = _categories[i];
              final selected = _selectedCategories.contains(i);
              return Padding(
                padding: EdgeInsets.only(right: i < _categories.length - 1 ? 10 : 0),
                child: KdhSelectCard(
                  selected: selected,
                  label: cat.label,
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedCategories.remove(i);
                    } else {
                      _selectedCategories.add(i);
                    }
                  }),
                  icon: KdhSelectCardIcon(
                    icon: cat.icon,
                    selected: selected,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // ── 기본 버튼 ─────────────────────────────────────────────────────
          _SectionLabel('기본 버튼'),
          const SizedBox(height: 12),
          KdhButton(label: '시작하기', onPressed: () {}),
          const SizedBox(height: 10),
          KdhButton(label: '비활성화', onPressed: null),
          const SizedBox(height: 10),
          KdhButton(label: '아웃라인 버튼', outlined: true, onPressed: () {}),
          const SizedBox(height: 10),
          KdhButton(
            label: '아이콘 버튼',
            onPressed: () {},
            leading: const Icon(
              Symbols.add_rounded,
              size: 18,
              color: KdhColor.background,
              fill: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: KdhTextStyle.caption1.copyWith(color: KdhColor.gray300),
    );
  }
}
