import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdh_mobile/core/widgets/kdh_button.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return KdhButton(
      label: 'Google계정으로 계속하기',
      onPressed: onPressed,
      outlined: true,
      leading: SvgPicture.asset(
        'assets/images/google_logo.svg',
        width: 20,
        height: 20,
      ),
    );
  }
}
