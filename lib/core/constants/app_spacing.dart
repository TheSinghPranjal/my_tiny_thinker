abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusRound = 999;

  static const double touchTargetMin = 48;
  static const double touchTargetLarge = 56;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  static const double bottomNavHeight = 72;
  static const double gameCardHeight = 180;
  static const double mascotSize = 80;
}

abstract final class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration verySlow = Duration(milliseconds: 1000);
  static const Duration loadingMin = Duration(milliseconds: 2000);
  static const Duration inactivityHint = Duration(seconds: 8);
}

abstract final class AppConstants {
  static const String appName = 'TinyThink';
  static const String appVersion = '1.0.0';
  static const int maxLevel = 100;
  static const int xpPerLevel = 100;
  static const int dailyStreakBonus = 10;
  static const int coinsPerGameBase = 5;
  static const int starsPerPerfectGame = 3;
  static const int parentLockLongPressMs = 3000;
}

abstract final class Breakpoints {
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
