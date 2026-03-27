import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class KdhToggleChipGroup extends StatelessWidget {
  const KdhToggleChipGroup({
    super.key,
    required this.items,
    required this.selectedIndexes,
    required this.onChanged,
    this.multi = true,
    this.chipSize = 40,
    this.textStyle,
  });

  final List<String> items;
  final Set<int> selectedIndexes;
  final ValueChanged<Set<int>> onChanged;
  final bool multi;
  final double chipSize;
  final TextStyle? textStyle;

  void _toggle(int index) {
    final next = Set<int>.from(selectedIndexes);
    if (multi) {
      next.contains(index) ? next.remove(index) : next.add(index);
    } else {
      next
        ..clear()
        ..add(index);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(items.length, (i) {
        final selected = selectedIndexes.contains(i);
        return _ToggleChip(
          label: items[i],
          selected: selected,
          size: chipSize,
          textStyle: textStyle,
          onTap: () => _toggle(i),
        );
      }),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.size,
    this.textStyle,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? KdhColor.background : KdhColor.gray800;
    final baseStyle = (textStyle ?? KdhTextStyle.caption1).copyWith(color: textColor);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected ? KdhColor.red200 : KdhColor.background,
          shape: BoxShape.circle,
          border: selected ? null : Border.all(color: KdhColor.red50, width: 1.5),
        ),
        child: Center(
          child: Text(label, style: baseStyle),
        ),
      ),
    );
  }
}
