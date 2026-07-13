import 'package:flutter/animation.dart';

abstract final class AppCurves {
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve pop = Curves.easeOutBack;
  static const Curve slide = Curves.easeOutQuart;
  static const Curve gentle = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
}

abstract final class AppAnimations {
  static const Duration bounce = Duration(milliseconds: 600);
  static const Duration shake = Duration(milliseconds: 500);
  static const Duration pulse = Duration(milliseconds: 1200);
  static const Duration twinkle = Duration(milliseconds: 2000);
  static const Duration float = Duration(milliseconds: 4000);
  static const Duration pop = Duration(milliseconds: 300);
  static const Duration confetti = Duration(milliseconds: 3000);
}
