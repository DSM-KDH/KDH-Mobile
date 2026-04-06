import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class KdhToggleChip extends StatelessWidget {
  const KdhToggleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? KdhColor.red200 : KdhColor.background,
          borderRadius: BorderRadius.circular(50),
          border: selected
              ? null
              : Border.all(color: KdhColor.red50, width: 1.5),
        ),
        child: Text(
          label,
          style: KdhTextStyle.caption1.copyWith(
            color: selected ? KdhColor.background : KdhColor.gray800,
          ),
        ),
      ),
    );
  }
}
