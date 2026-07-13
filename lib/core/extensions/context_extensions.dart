import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  bool get isTablet => screenWidth >= Breakpoints.tablet;
  bool get isPhone => screenWidth < Breakpoints.tablet;

  void unfocus() => FocusScope.of(this).unfocus();
}

extension NumExtensions on num {
  double get w => toDouble();
  Duration get ms => Duration(milliseconds: round());
}

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
