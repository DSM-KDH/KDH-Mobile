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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
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
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Icon(
          icon,
          color: isSelected ? KdhColor.background : KdhColor.red50,
          size: 24,
          fill: 0,
        ),
      ),
    );
  }
}
