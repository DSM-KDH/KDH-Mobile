import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/features/timer/presentation/widgets/play_button.dart';

class TimerButton extends StatelessWidget {
  const TimerButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.playerIconColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color playerIconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(60),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: KdhTextStyle.body1.copyWith(color: titleColor),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: KdhTextStyle.caption1.copyWith(color: subtitleColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          PlayButton(
            iconColor: playerIconColor,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
