import 'package:flutter/material.dart';

/// TinyThink color palette — bright, kid-friendly, never dark.
abstract final class AppColors {
  // Primary
  static const Color skyBlue = Color(0xFF4FC3F7);
  static const Color skyBlueLight = Color(0xFF81D4FA);
  static const Color skyBlueDark = Color(0xFF29B6F6);

  static const Color sunYellow = Color(0xFFFFD54F);
  static const Color sunYellowLight = Color(0xFFFFE082);
  static const Color sunYellowDark = Color(0xFFFFCA28);

  static const Color candyPink = Color(0xFFFF80AB);
  static const Color candyPinkLight = Color(0xFFFFB2DD);
  static const Color candyPinkDark = Color(0xFFFF4081);

  static const Color mintGreen = Color(0xFF69F0AE);
  static const Color mintGreenLight = Color(0xFFB9F6CA);
  static const Color mintGreenDark = Color(0xFF00E676);

  static const Color lavender = Color(0xFFB388FF);
  static const Color lavenderLight = Color(0xFFD1C4E9);
  static const Color lavenderDark = Color(0xFF7C4DFF);

  static const Color orange = Color(0xFFFFAB40);
  static const Color orangeLight = Color(0xFFFFCC80);
  static const Color orangeDark = Color(0xFFFF9100);

  static const Color softPurple = Color(0xFFCE93D8);
  static const Color softPurpleLight = Color(0xFFE1BEE7);
  static const Color softPurpleDark = Color(0xFFBA68C8);

  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFFF8F0);
  static const Color cream = Color(0xFFFFF3E0);

  // Semantic
  static const Color success = Color(0xFF66BB6A);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Text
  static const Color textPrimary = Color(0xFF37474F);
  static const Color textSecondary = Color(0xFF78909C);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Backgrounds
  static const Color skyTop = Color(0xFF87CEEB);
  static const Color skyBottom = Color(0xFFE0F7FA);
  static const Color grassGreen = Color(0xFF81C784);
  static const Color grassDark = Color(0xFF66BB6A);

  // Bubble colors
  static const List<Color> bubbleColors = [
    skyBlue,
    candyPink,
    mintGreen,
    orange,
    lavender,
    sunYellow,
  ];

  static const List<Color> rainbow = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFDDA0DD),
    Color(0xFFFF80AB),
  ];

  static const List<Color> gameCardColors = [
    skyBlue,
    candyPink,
    mintGreen,
    lavender,
    orange,
    softPurple,
  ];
}
