import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class KdhSelectCard extends StatelessWidget {
  const KdhSelectCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
    this.size = 100,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? KdhColor.red50 : KdhColor.background;
    final borderColor = selected ? KdhColor.red200 : KdhColor.red50;
    final textColor = selected ? KdhColor.red500 : KdhColor.gray800;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: borderColor, width: 2),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              label,
              style: KdhTextStyle.caption4.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class KdhSelectCardIcon extends StatelessWidget {
  const KdhSelectCardIcon({
    super.key,
    required this.icon,
    required this.selected,
    this.size = 32,
  });

  final IconData icon;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: selected ? KdhColor.red500 : KdhColor.gray800,
    );
  }
}
