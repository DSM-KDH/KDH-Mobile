import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class KdhButton extends StatelessWidget {
  const KdhButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.outlined = false,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool outlined;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return KdhColor.gray100;
            return outlined ? KdhColor.background : KdhColor.red200;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return KdhColor.background;
            return outlined ? KdhColor.gray800 : KdhColor.background;
          }),
          overlayColor: WidgetStateProperty.all(KdhColor.gray800.withValues(alpha: 0.06)),
          side: WidgetStateProperty.all(
            outlined
                ? const BorderSide(color: KdhColor.gray200)
                : BorderSide.none,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textColor = outlined ? KdhColor.gray800 : KdhColor.background;

    final textWidget = Text(
      label,
      style: KdhTextStyle.body6.copyWith(color: textColor),
    );

    if (trailing != null) {
      return Row(
        children: [
          Expanded(child: textWidget),
          trailing!,
        ],
      );
    }

    if (leading != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          leading!,
          const SizedBox(width: 10),
          textWidget,
        ],
      );
    }

    return Center(child: textWidget);
  }
}
