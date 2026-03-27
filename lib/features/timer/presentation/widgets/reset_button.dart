import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:material_symbols_icons/symbols.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({
    super.key,
    required this.isActive,
    this.onTap,
  });

  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isActive ? KdhColor.red100 : KdhColor.gray50;
    final Color iconColor = isActive ? KdhColor.red400 : KdhColor.gray300;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Symbols.replay_rounded,
          color: iconColor,
          size: 26,
          fill: 0,
        ),
      ),
    );
  }
}
