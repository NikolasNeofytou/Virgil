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
    Locale('en'),
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

  /// No description provided for @lobbyGreetingMorning.
  ///
  /// In el, this message translates to:
  /// **'Καλημέρα'**
  String get lobbyGreetingMorning;

  /// No description provided for @lobbyGreetingAfternoon.
  ///
  /// In el, this message translates to:
  /// **'Καλησπέρα'**
  String get lobbyGreetingAfternoon;

  /// No description provided for @lobbyGreetingEvening.
  ///
  /// In el, this message translates to:
  /// **'Καλό βράδυ'**
  String get lobbyGreetingEvening;

  /// No description provided for @lobbyGreetingFallback.
  ///
  /// In el, this message translates to:
  /// **'Καλώς ήρθες'**
  String get lobbyGreetingFallback;

  /// No description provided for @lobbyHeroTitle.
  ///
  /// In el, this message translates to:
  /// **'Στρώθηκε τραπέζι για εσένα.'**
  String get lobbyHeroTitle;

  /// No description provided for @lobbyTodayLabel.
  ///
  /// In el, this message translates to:
  /// **'ΣΗΜΕΡΑ'**
  String get lobbyTodayLabel;

  /// No description provided for @lobbyTonightSection.
  ///
  /// In el, this message translates to:
  /// **'ΑΠΟΨΕ · TONIGHT'**
  String get lobbyTonightSection;

  /// No description provided for @lobbyEstimationName.
  ///
  /// In el, this message translates to:
  /// **'Πρόβλεψη'**
  String get lobbyEstimationName;

  /// No description provided for @lobbyEstimationDescription.
  ///
  /// In el, this message translates to:
  /// **'Πες πόσες μπάζες θα πάρεις. Δες ποιος ξέρει τα χαρτιά του.'**
  String get lobbyEstimationDescription;

  /// No description provided for @lobbyTakeYourSeat.
  ///
  /// In el, this message translates to:
  /// **'Πιάσε θέση'**
  String get lobbyTakeYourSeat;

  /// No description provided for @lobbyJoin.
  ///
  /// In el, this message translates to:
  /// **'Μπες'**
  String get lobbyJoin;

  /// No description provided for @lobbyContinueLabel.
  ///
  /// In el, this message translates to:
  /// **'Συνέχισε'**
  String get lobbyContinueLabel;

  /// No description provided for @lobbyInProgressSection.
  ///
  /// In el, this message translates to:
  /// **'ΣΕ ΕΞΕΛΙΞΗ · IN PROGRESS'**
  String get lobbyInProgressSection;

  /// No description provided for @lobbyInProgressLobby.
  ///
  /// In el, this message translates to:
  /// **'στο δωμάτιο'**
  String get lobbyInProgressLobby;

  /// No description provided for @lobbyInProgressRound.
  ///
  /// In el, this message translates to:
  /// **'Γύρος {round}'**
  String lobbyInProgressRound(int round);

  /// No description provided for @lobbyParcaInPlaySection.
  ///
  /// In el, this message translates to:
  /// **'ΠΑΡΕΑ · IN PLAY'**
  String get lobbyParcaInPlaySection;

  /// No description provided for @lobbyParcaResting.
  ///
  /// In el, this message translates to:
  /// **'η παρέα ξεκουράζεται'**
  String get lobbyParcaResting;

  /// No description provided for @lobbyFriendStatusWaiting.
  ///
  /// In el, this message translates to:
  /// **'καθιστά'**
  String get lobbyFriendStatusWaiting;

  /// No description provided for @lobbyFriendStatusActive.
  ///
  /// In el, this message translates to:
  /// **'παίζει'**
  String get lobbyFriendStatusActive;

  /// No description provided for @lobbyFriendJoinError.
  ///
  /// In el, this message translates to:
  /// **'δεν μπόρεσα να μπω'**
  String get lobbyFriendJoinError;

  /// No description provided for @lobbyGamesSection.
  ///
  /// In el, this message translates to:
  /// **'ΠΑΙΧΝΙΔΙΑ · GAMES'**
  String get lobbyGamesSection;

  /// No description provided for @lobbyGamePilotta.
  ///
  /// In el, this message translates to:
  /// **'Πιλόττα'**
  String get lobbyGamePilotta;

  /// No description provided for @lobbyGamePilottaTagline.
  ///
  /// In el, this message translates to:
  /// **'Η Κυπριακή κλασική του καφενείου.'**
  String get lobbyGamePilottaTagline;

  /// No description provided for @lobbyGameTavli.
  ///
  /// In el, this message translates to:
  /// **'Ταβλί'**
  String get lobbyGameTavli;

  /// No description provided for @lobbyGameTavliTagline.
  ///
  /// In el, this message translates to:
  /// **'Τρία παιχνίδια — Πόρτες, Πλακωτό, Φεύγα.'**
  String get lobbyGameTavliTagline;

  /// No description provided for @lobbyGameBiriba.
  ///
  /// In el, this message translates to:
  /// **'Μπιρίμπα'**
  String get lobbyGameBiriba;

  /// No description provided for @lobbyGameBiribaTagline.
  ///
  /// In el, this message translates to:
  /// **'Δύο τράπουλες. Μεγάλα παιχνίδια. Οικογενειακό.'**
  String get lobbyGameBiribaTagline;

  /// No description provided for @lobbyChipLive.
  ///
  /// In el, this message translates to:
  /// **'live'**
  String get lobbyChipLive;

  /// No description provided for @lobbyChipSoon.
  ///
  /// In el, this message translates to:
  /// **'σύντομα'**
  String get lobbyChipSoon;

  /// No description provided for @pareaTitle.
  ///
  /// In el, this message translates to:
  /// **'Παρέα'**
  String get pareaTitle;

  /// No description provided for @pareaSubtitle.
  ///
  /// In el, this message translates to:
  /// **'η παρέα σου'**
  String get pareaSubtitle;

  /// No description provided for @pareaAddPrompt.
  ///
  /// In el, this message translates to:
  /// **'Πρόσθεσε φίλο'**
  String get pareaAddPrompt;

  /// No description provided for @pareaAddHint.
  ///
  /// In el, this message translates to:
  /// **'όνομα'**
  String get pareaAddHint;

  /// No description provided for @pareaAddSubmit.
  ///
  /// In el, this message translates to:
  /// **'Στείλε'**
  String get pareaAddSubmit;

  /// No description provided for @pareaAddSuccess.
  ///
  /// In el, this message translates to:
  /// **'στάλθηκε στον @{username}'**
  String pareaAddSuccess(String username);

  /// No description provided for @pareaAddErrorGeneric.
  ///
  /// In el, this message translates to:
  /// **'σφάλμα · δοκίμασε ξανά'**
  String get pareaAddErrorGeneric;

  /// No description provided for @pareaInboxSection.
  ///
  /// In el, this message translates to:
  /// **'ΑΙΤΗΣΕΙΣ · INBOX'**
  String get pareaInboxSection;

  /// No description provided for @pareaInboxEmpty.
  ///
  /// In el, this message translates to:
  /// **'δεν έχεις αιτήσεις αυτή τη στιγμή'**
  String get pareaInboxEmpty;

  /// No description provided for @pareaInboxWantsToBeFriends.
  ///
  /// In el, this message translates to:
  /// **'θέλει να γίνει φίλος σου'**
  String get pareaInboxWantsToBeFriends;

  /// No description provided for @pareaInboxAccept.
  ///
  /// In el, this message translates to:
  /// **'Δέξου'**
  String get pareaInboxAccept;

  /// No description provided for @pareaInboxDecline.
  ///
  /// In el, this message translates to:
  /// **'Απόρριψη'**
  String get pareaInboxDecline;

  /// No description provided for @pareaYoursSection.
  ///
  /// In el, this message translates to:
  /// **'ΦΙΛΟΙ · YOURS'**
  String get pareaYoursSection;

  /// No description provided for @pareaYoursEmpty.
  ///
  /// In el, this message translates to:
  /// **'πρόσθεσε τον πρώτο σου φίλο πιο πάνω'**
  String get pareaYoursEmpty;

  /// No description provided for @pareaSentSection.
  ///
  /// In el, this message translates to:
  /// **'ΣΕ ΑΝΑΜΟΝΗ · SENT'**
  String get pareaSentSection;

  /// No description provided for @pareaSentEmpty.
  ///
  /// In el, this message translates to:
  /// **'καμία αίτηση σε αναμονή'**
  String get pareaSentEmpty;

  /// No description provided for @pareaSentLabel.
  ///
  /// In el, this message translates to:
  /// **'αναμονή επιβεβαίωσης'**
  String get pareaSentLabel;

  /// No description provided for @pareaSentCancel.
  ///
  /// In el, this message translates to:
  /// **'Ακύρωση'**
  String get pareaSentCancel;

  /// No description provided for @pareaUnfriendTitle.
  ///
  /// In el, this message translates to:
  /// **'Αφαίρεση @{username};'**
  String pareaUnfriendTitle(String username);

  /// No description provided for @pareaUnfriendBody.
  ///
  /// In el, this message translates to:
  /// **'Η φιλία θα διαγραφεί και για τους δύο.'**
  String get pareaUnfriendBody;

  /// No description provided for @pareaUnfriendConfirm.
  ///
  /// In el, this message translates to:
  /// **'Αφαίρεσε'**
  String get pareaUnfriendConfirm;

  /// No description provided for @pareaUnfriendCancel.
  ///
  /// In el, this message translates to:
  /// **'Άκυρο'**
  String get pareaUnfriendCancel;

  /// No description provided for @tournamentSection.
  ///
  /// In el, this message translates to:
  /// **'ΤΟΥΡΝΟΥΑ · TOURNAMENT'**
  String get tournamentSection;

  /// No description provided for @tournamentTopSection.
  ///
  /// In el, this message translates to:
  /// **'ΚΟΡΥΦΗ · TOP 10'**
  String get tournamentTopSection;

  /// No description provided for @tournamentYouSection.
  ///
  /// In el, this message translates to:
  /// **'ΕΣΥ · YOU'**
  String get tournamentYouSection;

  /// No description provided for @tournamentStatGames.
  ///
  /// In el, this message translates to:
  /// **'GAMES'**
  String get tournamentStatGames;

  /// No description provided for @tournamentStatWins.
  ///
  /// In el, this message translates to:
  /// **'WINS'**
  String get tournamentStatWins;

  /// No description provided for @tournamentStatAccuracy.
  ///
  /// In el, this message translates to:
  /// **'ACCURACY'**
  String get tournamentStatAccuracy;

  /// No description provided for @tournamentStatPoints.
  ///
  /// In el, this message translates to:
  /// **'POINTS'**
  String get tournamentStatPoints;

  /// No description provided for @tournamentEmptyTitle.
  ///
  /// In el, this message translates to:
  /// **'κενό φύλλο'**
  String get tournamentEmptyTitle;

  /// No description provided for @tournamentEmptyBody.
  ///
  /// In el, this message translates to:
  /// **'γίνε ο πρώτος που θα μπει στην κατάταξη.\nένα κλειστό παιχνίδι αρκεί.'**
  String get tournamentEmptyBody;

  /// No description provided for @tournamentYouAreHere.
  ///
  /// In el, this message translates to:
  /// **'η θέση σου'**
  String get tournamentYouAreHere;

  /// No description provided for @tournamentNoGamesTitle.
  ///
  /// In el, this message translates to:
  /// **'κανένα κλειστό παιχνίδι ακόμη'**
  String get tournamentNoGamesTitle;

  /// No description provided for @tournamentNoGamesBody.
  ///
  /// In el, this message translates to:
  /// **'ξεκίνα ένα για να μπεις στο τουρνουά.'**
  String get tournamentNoGamesBody;

  /// No description provided for @tournamentGamesPointsLabel.
  ///
  /// In el, this message translates to:
  /// **'{games} παιχνίδια · {points} π.'**
  String tournamentGamesPointsLabel(int games, int points);
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
    'that was used.',
  );
}
