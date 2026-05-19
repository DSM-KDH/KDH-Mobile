import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:material_symbols_icons/symbols.dart';

class KdhBottomNavBar extends StatelessWidget {
  const KdhBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (icon: Symbols.home_rounded, label: '홈'),
    (icon: Symbols.timer_rounded, label: '타이머'),
    (icon: Symbols.person_rounded, label: '프로필'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPad  = bottomInset < 40 ? 40.0 : bottomInset;

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(24, 0, 24, bottomPad),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: KdhColor.red200,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            _tabs.length,
            (i) => _TabIcon(
              icon: _tabs[i].icon,
              label: _tabs[i].label,
              isSelected: i == currentIndex,
              onTap: () => onTap(i),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        icon: Icon(
          icon,
          color: isSelected ? KdhColor.background : KdhColor.red50,
          size: 24,
          fill: 0,
        ),
      ),
    );
  }
}
