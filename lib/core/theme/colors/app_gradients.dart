import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

abstract final class AppGradients {
  static const LinearGradient sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.skyTop, AppColors.skyBlueLight, AppColors.skyBottom],
  );

  static const LinearGradient sun = LinearGradient(
    colors: [AppColors.sunYellowLight, AppColors.sunYellow, AppColors.orange],
  );

  static const LinearGradient rainbow = LinearGradient(
    colors: AppColors.rainbow,
  );

  static const LinearGradient bubbleBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81D4FA), Color(0xFF0288D1)],
  );

  static const LinearGradient bubblePink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB2DD), Color(0xFFE91E63)],
  );

  static const LinearGradient bubbleGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB9F6CA), Color(0xFF00C853)],
  );

  static const LinearGradient bubbleOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFCC80), Color(0xFFFF6D00)],
  );

  static const LinearGradient bubblePurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE1BEE7), Color(0xFF7B1FA2)],
  );

  static const LinearGradient bubbleYellow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF59D), Color(0xFFFFA000)],
  );

  static const LinearGradient welcomeCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1)],
  );

  static const LinearGradient glassOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x20FFFFFF),
    ],
  );

  static List<LinearGradient> get bubbleGradients => [
        bubbleBlue,
        bubblePink,
        bubbleGreen,
        bubbleOrange,
        bubblePurple,
        bubbleYellow,
      ];

  static LinearGradient forIndex(int index) =>
      bubbleGradients[index % bubbleGradients.length];
}
