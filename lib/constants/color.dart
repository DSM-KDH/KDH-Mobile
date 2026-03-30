import 'package:flutter/material.dart';

abstract final class KdhColor {
  /// etc
  static const Color background = Color(0xFFFFFCFC);

  /// gradients
  static const LinearGradient aiRoutineGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.0, 0.5, 1.0],
    colors: [
      Color(0xFFFFF7F6),
      Color(0xFFFFCAC9),
      Color(0xFFFFA2A2),
    ],
  );

  /// red
  static const Color red50 = Color(0xFFFFEDEC);
  static const Color red100 = Color(0xFFFFD2CF);
  static const Color red200 = Color(0xFFFF8F8F);
  static const Color red400 = Color(0xFFBE3E3E);
  static const Color red500 = Color(0xFF9C3131);
  static const Color red600 = Color(0xFF3F0F0F);

  /// gray
  static const Color gray50 = Color(0xFFF1F1F1);
  static const Color gray100 = Color(0xFFDADADA);
  static const Color gray200 = Color(0xFFB7B7B7);
  static const Color gray300 = Color(0xFF999999);
  static const Color gray400 = Color(0xFF7E7E7E);
  static const Color gray500 = Color(0xFF656565);
  static const Color gray600 = Color(0xFF4D4D4D);
  static const Color gray700 = Color(0xFF383838);
  static const Color gray800 = Color(0xFF242424);
}