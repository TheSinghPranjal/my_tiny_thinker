import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'TinyThink'**
  String get appTitle;

  /// No description provided for @helloExplorer.
  ///
  /// In en, this message translates to:
  /// **'Hello Explorer!'**
  String get helloExplorer;

  /// No description provided for @readyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play today?'**
  String get readyToPlay;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @parents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get parents;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @loadingCountingBubbles.
  ///
  /// In en, this message translates to:
  /// **'Counting bubbles...'**
  String get loadingCountingBubbles;

  /// No description provided for @loadingFindingRainbows.
  ///
  /// In en, this message translates to:
  /// **'Finding rainbows...'**
  String get loadingFindingRainbows;

  /// No description provided for @loadingWarmingBrain.
  ///
  /// In en, this message translates to:
  /// **'Warming up your brain...'**
  String get loadingWarmingBrain;

  /// No description provided for @loadingGettingReady.
  ///
  /// In en, this message translates to:
  /// **'Getting games ready...'**
  String get loadingGettingReady;

  /// No description provided for @moreGamesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More games coming soon!'**
  String get moreGamesComingSoon;

  /// No description provided for @parentZone.
  ///
  /// In en, this message translates to:
  /// **'Parent Zone'**
  String get parentZone;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Sound On'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Sound Off'**
  String get soundOff;

  /// No description provided for @musicOn.
  ///
  /// In en, this message translates to:
  /// **'Music On'**
  String get musicOn;

  /// No description provided for @musicOff.
  ///
  /// In en, this message translates to:
  /// **'Music Off'**
  String get musicOff;

  /// No description provided for @hapticsOn.
  ///
  /// In en, this message translates to:
  /// **'Haptics On'**
  String get hapticsOn;

  /// No description provided for @hapticsOff.
  ///
  /// In en, this message translates to:
  /// **'Haptics Off'**
  String get hapticsOff;

  /// No description provided for @dailyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily Reward'**
  String get dailyReward;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @nextDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Next Difficulty'**
  String get nextDifficulty;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @mistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get mistakes;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @longestCombo.
  ///
  /// In en, this message translates to:
  /// **'Longest Combo'**
  String get longestCombo;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// No description provided for @findNumber.
  ///
  /// In en, this message translates to:
  /// **'Find: {number}'**
  String findNumber(String number);

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @bubbleNumberPop.
  ///
  /// In en, this message translates to:
  /// **'Bubble Number Pop'**
  String get bubbleNumberPop;

  /// No description provided for @ascendingBubbleNumberPop.
  ///
  /// In en, this message translates to:
  /// **'Ascending Bubble Number Pop'**
  String get ascendingBubbleNumberPop;

  /// No description provided for @descendingNumberPop.
  ///
  /// In en, this message translates to:
  /// **'Descending Number Pop'**
  String get descendingNumberPop;

  /// No description provided for @numberWordPop.
  ///
  /// In en, this message translates to:
  /// **'Number Word Pop'**
  String get numberWordPop;

  /// No description provided for @memoryGame.
  ///
  /// In en, this message translates to:
  /// **'Memory Game'**
  String get memoryGame;

  /// No description provided for @oddOneOut.
  ///
  /// In en, this message translates to:
  /// **'Odd One Out'**
  String get oddOneOut;

  /// No description provided for @patternMatch.
  ///
  /// In en, this message translates to:
  /// **'Pattern Match'**
  String get patternMatch;

  /// No description provided for @colorMemory.
  ///
  /// In en, this message translates to:
  /// **'Color Memory'**
  String get colorMemory;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @relaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get relaxed;

  /// No description provided for @timed.
  ///
  /// In en, this message translates to:
  /// **'Timed'**
  String get timed;

  /// No description provided for @endless.
  ///
  /// In en, this message translates to:
  /// **'Endless'**
  String get endless;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oops;

  /// No description provided for @amazing.
  ///
  /// In en, this message translates to:
  /// **'Amazing!'**
  String get amazing;

  /// No description provided for @fantastic.
  ///
  /// In en, this message translates to:
  /// **'Fantastic!'**
  String get fantastic;

  /// No description provided for @superCombo.
  ///
  /// In en, this message translates to:
  /// **'Super!'**
  String get superCombo;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// No description provided for @victory.
  ///
  /// In en, this message translates to:
  /// **'Victory!'**
  String get victory;

  /// No description provided for @enterParentZone.
  ///
  /// In en, this message translates to:
  /// **'Enter Parent Zone'**
  String get enterParentZone;

  /// No description provided for @parentLockHint.
  ///
  /// In en, this message translates to:
  /// **'What is {a} × {b}?'**
  String parentLockHint(int a, int b);

  /// No description provided for @wrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'That\'s not quite right. Try again!'**
  String get wrongAnswer;

  /// No description provided for @emptyRewards.
  ///
  /// In en, this message translates to:
  /// **'Complete games to earn rewards!'**
  String get emptyRewards;

  /// No description provided for @emptyAchievements.
  ///
  /// In en, this message translates to:
  /// **'Keep playing to unlock achievements!'**
  String get emptyAchievements;

  /// No description provided for @errorFriendly.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong, but we\'ll fix it!'**
  String get errorFriendly;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
