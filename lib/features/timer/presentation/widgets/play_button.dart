import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.iconColor,
    this.onTap,
  });

  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Symbols.play_arrow_rounded,
        color: iconColor,
        size: 28,
        fill: 1,
      ),
    );
  }
}
