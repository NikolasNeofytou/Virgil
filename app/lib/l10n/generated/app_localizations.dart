import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_el.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('el'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In el, this message translates to:
  /// **'Virgil'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In el, this message translates to:
  /// **'ένας οδηγός για το τραπέζι'**
  String get appTagline;

  /// No description provided for @tabPlay.
  ///
  /// In el, this message translates to:
  /// **'Παίξε'**
  String get tabPlay;

  /// No description provided for @tabFriends.
  ///
  /// In el, this message translates to:
  /// **'Φίλοι'**
  String get tabFriends;

  /// No description provided for @tabLeaderboard.
  ///
  /// In el, this message translates to:
  /// **'Κατάταξη'**
  String get tabLeaderboard;

  /// No description provided for @tabProfile.
  ///
  /// In el, this message translates to:
  /// **'Προφίλ'**
  String get tabProfile;

  /// No description provided for @signInTitle.
  ///
  /// In el, this message translates to:
  /// **'Καλώς ήρθες'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In el, this message translates to:
  /// **'συνδέσου για να μπεις στο τραπέζι'**
  String get signInSubtitle;

  /// No description provided for @usernamePickerSection.
  ///
  /// In el, this message translates to:
  /// **'§ 01 · ΟΝΟΜΑ · NAME'**
  String get usernamePickerSection;

  /// No description provided for @usernamePickerTitle.
  ///
  /// In el, this message translates to:
  /// **'Διάλεξε όνομα'**
  String get usernamePickerTitle;

  /// No description provided for @usernamePickerSubtitle.
  ///
  /// In el, this message translates to:
  /// **'το όνομά σου στο τραπέζι'**
  String get usernamePickerSubtitle;

  /// No description provided for @usernamePickerHint.
  ///
  /// In el, this message translates to:
  /// **'3–24 χαρακτήρες · γράμματα, αριθμοί, _'**
  String get usernamePickerHint;

  /// No description provided for @usernamePickerSubmit.
  ///
  /// In el, this message translates to:
  /// **'Συνέχεια'**
  String get usernamePickerSubmit;

  /// No description provided for @usernamePickerErrorInvalid.
  ///
  /// In el, this message translates to:
  /// **'3–24 χαρακτήρες · γράμματα, αριθμοί, _'**
  String get usernamePickerErrorInvalid;

  /// No description provided for @usernamePickerErrorTaken.
  ///
  /// In el, this message translates to:
  /// **'αυτό το όνομα υπάρχει ήδη'**
  String get usernamePickerErrorTaken;

  /// No description provided for @usernamePickerErrorSession.
  ///
  /// In el, this message translates to:
  /// **'η σύνδεση έληξε · συνδέσου ξανά'**
  String get usernamePickerErrorSession;

  /// No description provided for @usernamePickerErrorGeneric.
  ///
  /// In el, this message translates to:
  /// **'σφάλμα · δοκίμασε ξανά'**
  String get usernamePickerErrorGeneric;

  /// No description provided for @gameOverWinnerLabel.
  ///
  /// In el, this message translates to:
  /// **'ΝΙΚΗΤΗΣ · WINNER'**
  String get gameOverWinnerLabel;

  /// No description provided for @gameOverFinalLabel.
  ///
  /// In el, this message translates to:
  /// **'ΚΑΤΑΤΑΞΗ · FINAL'**
  String get gameOverFinalLabel;

  /// No description provided for @gameOverNarrationLabel.
  ///
  /// In el, this message translates to:
  /// **'ΝΑΡΡΗΣΗ · NIGHT NOTE'**
  String get gameOverNarrationLabel;

  /// No description provided for @gameOverAwardsLabel.
  ///
  /// In el, this message translates to:
  /// **'ΒΡΑΒΕΙΑ · AWARDS'**
  String get gameOverAwardsLabel;

  /// No description provided for @gameOverMomentsLabel.
  ///
  /// In el, this message translates to:
  /// **'ΣΤΙΓΜΕΣ · MOMENTS'**
  String get gameOverMomentsLabel;

  /// No description provided for @gameOverPoints.
  ///
  /// In el, this message translates to:
  /// **'{score} πόντοι'**
  String gameOverPoints(int score);

  /// No description provided for @gameOverRematch.
  ///
  /// In el, this message translates to:
  /// **'Νέο παιχνίδι'**
  String get gameOverRematch;

  /// No description provided for @gameOverShare.
  ///
  /// In el, this message translates to:
  /// **'Κοινοποίηση'**
  String get gameOverShare;

  /// No description provided for @gameOverBackToMenu.
  ///
  /// In el, this message translates to:
  /// **'Πίσω στο μενού'**
  String get gameOverBackToMenu;

  /// No description provided for @leaderboardTitle.
  ///
  /// In el, this message translates to:
  /// **'Κατάταξη'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In el, this message translates to:
  /// **'τα σκορ του τραπεζιού'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardYouSection.
  ///
  /// In el, this message translates to:
  /// **'§ 01 · ΟΙ ΣΤΑΤΙΣΤΙΚΕΣ ΣΟΥ · YOU'**
  String get leaderboardYouSection;

  /// No description provided for @leaderboardTopSection.
  ///
  /// In el, this message translates to:
  /// **'§ 02 · TOP 10 · LEADERS'**
  String get leaderboardTopSection;

  /// No description provided for @leaderboardYouBadge.
  ///
  /// In el, this message translates to:
  /// **'ΕΣΥ'**
  String get leaderboardYouBadge;

  /// No description provided for @leaderboardWinsLabel.
  ///
  /// In el, this message translates to:
  /// **'WINS'**
  String get leaderboardWinsLabel;

  /// No description provided for @leaderboardYourPosition.
  ///
  /// In el, this message translates to:
  /// **'η θέση σου'**
  String get leaderboardYourPosition;

  /// No description provided for @leaderboardEmptyTitle.
  ///
  /// In el, this message translates to:
  /// **'κενό φύλλο'**
  String get leaderboardEmptyTitle;

  /// No description provided for @leaderboardEmptyBody.
  ///
  /// In el, this message translates to:
  /// **'γίνε ο πρώτος που θα μπει στην κατάταξη.\nένα κλειστό παιχνίδι αρκεί.'**
  String get leaderboardEmptyBody;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In el, this message translates to:
  /// **'Γλώσσα'**
  String get profileLanguageLabel;

  /// No description provided for @profileSignOut.
  ///
  /// In el, this message translates to:
  /// **'Αποσύνδεση'**
  String get profileSignOut;
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
      <String>['el', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
