import 'package:flutter/material.dart';

/// Brand palette. Change colours here only; widgets read them through the theme.
abstract final class AppColors {
  static const Color primary = Color(0xFF245C42);
  static const Color secondary = Color(0xFFA8B99A);
  static const Color background = Color(0xFFF8F8F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFEDE8D8);
  static const Color text = Color(0xFF252A26);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF5F665F);
  static const Color border = Color(0xFFDCDDD3);
  static const Color error = Color(0xFFB3261E);

  // Status colours (badges, banners)
  static const Color info = Color(0xFF2F6FA3);
  static const Color warning = Color(0xFFB7791F);
  static const Color success = Color(0xFF2E7D4F);
  static const Color neutral = Color(0xFF6B6F6A);
}
