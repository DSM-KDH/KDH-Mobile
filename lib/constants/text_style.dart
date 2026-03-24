import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';

class KdhTextStyle {
  /// heading
  static TextStyle heading1 = defaultTextStyle.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w700,
  );
  static TextStyle heading2 = defaultTextStyle.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700
  );
  static TextStyle heading3 = defaultTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /// body
  static TextStyle body1 = defaultTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static TextStyle body2 = defaultTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
  static TextStyle body3 = defaultTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static TextStyle body4 = defaultTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  static TextStyle body5 = defaultTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static TextStyle body6 = defaultTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500
  );
  static TextStyle body7 = defaultTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static TextStyle body8 = defaultTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w300,
  );

  /// caption
  static TextStyle caption1 = defaultTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static TextStyle caption2 = defaultTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static TextStyle caption3 = defaultTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static TextStyle caption4 = defaultTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static TextStyle caption5 = defaultTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// etc
  static TextStyle display = defaultTextStyle.copyWith(
    fontSize: 64,
    fontWeight: FontWeight.w300,
  );
}

const TextStyle defaultTextStyle = TextStyle(
  color: KdhColor.gray800,
  fontFamily: 'Pretendard',
);