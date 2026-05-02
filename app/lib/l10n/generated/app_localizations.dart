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

  /// No description provided for @signInPasswordLabel.
  ///
  /// In el, this message translates to:
  /// **'Κωδικός'**
  String get signInPasswordLabel;

  /// No description provided for @signInSubmitPassword.
  ///
  /// In el, this message translates to:
  /// **'Σύνδεση'**
  String get signInSubmitPassword;

  /// No description provided for @signInSubmitOtp.
  ///
  /// In el, this message translates to:
  /// **'Αποστολή κωδικού'**
  String get signInSubmitOtp;

  /// No description provided for @signInToggleToOtp.
  ///
  /// In el, this message translates to:
  /// **'Σύνδεση με email OTP'**
  String get signInToggleToOtp;

  /// No description provided for @signInToggleToPassword.
  ///
  /// In el, this message translates to:
  /// **'Σύνδεση με κωδικό'**
  String get signInToggleToPassword;

  /// No description provided for @signInOtpSection.
  ///
  /// In el, this message translates to:
  /// **'ΕΛΕΓΞΕ ΤΟ EMAIL'**
  String get signInOtpSection;

  /// No description provided for @signInOtpSent.
  ///
  /// In el, this message translates to:
  /// **'σου στείλαμε κωδικό'**
  String get signInOtpSent;

  /// No description provided for @signInOtpVerify.
  ///
  /// In el, this message translates to:
  /// **'Επιβεβαίωση'**
  String get signInOtpVerify;

  /// No description provided for @signInBack.
  ///
  /// In el, this message translates to:
  /// **'Πίσω'**
  String get signInBack;

  /// No description provided for @usernamePickerSection.
  ///
  /// In el, this message translates to:
  /// **'§ 01 · ΟΝΟΜΑ'**
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

  /// No description provided for @usernamePickerInputHint.
  ///
  /// In el, this message translates to:
  /// **'όνομα…'**
  String get usernamePickerInputHint;

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

  /// No description provided for @profileTitle.
  ///
  /// In el, this message translates to:
  /// **'Προφίλ'**
  String get profileTitle;

  /// No description provided for @profileLoadError.
  ///
  /// In el, this message translates to:
  /// **'σφάλμα · {error}'**
  String profileLoadError(String error);

  /// No description provided for @profileStatsSection.
  ///
  /// In el, this message translates to:
  /// **'§ 01 · ΣΤΑΤΙΣΤΙΚΑ'**
  String get profileStatsSection;

  /// No description provided for @profileHistorySection.
  ///
  /// In el, this message translates to:
  /// **'§ 02 · ΤΑ ΠΑΙΧΝΙΔΙΑ ΜΟΥ'**
  String get profileHistorySection;

  /// No description provided for @profileSettingsSection.
  ///
  /// In el, this message translates to:
  /// **'§ 03 · ΡΥΘΜΙΣΕΙΣ'**
  String get profileSettingsSection;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In el, this message translates to:
  /// **'Γλώσσα'**
  String get profileLanguageLabel;

  /// No description provided for @profileIconLabel.
  ///
  /// In el, this message translates to:
  /// **'Εικονίδιο'**
  String get profileIconLabel;

  /// No description provided for @profileIconAegean.
  ///
  /// In el, this message translates to:
  /// **'Αιγαίο'**
  String get profileIconAegean;

  /// No description provided for @profileIconAegeanRole.
  ///
  /// In el, this message translates to:
  /// **'ΒΑΣΙΚΟ'**
  String get profileIconAegeanRole;

  /// No description provided for @profileIconCoral.
  ///
  /// In el, this message translates to:
  /// **'Κοράλλι'**
  String get profileIconCoral;

  /// No description provided for @profileIconCoralRole.
  ///
  /// In el, this message translates to:
  /// **'ΤΟΥΡΝΟΥΑ'**
  String get profileIconCoralRole;

  /// No description provided for @profileIconOchre.
  ///
  /// In el, this message translates to:
  /// **'Ώχρα'**
  String get profileIconOchre;

  /// No description provided for @profileIconOchreRole.
  ///
  /// In el, this message translates to:
  /// **'ΒΑΘΜΙΔΑ'**
  String get profileIconOchreRole;

  /// No description provided for @profileIconError.
  ///
  /// In el, this message translates to:
  /// **'δεν άλλαξε το εικονίδιο'**
  String get profileIconError;

  /// No description provided for @profileSignOut.
  ///
  /// In el, this message translates to:
  /// **'Αποσύνδεση'**
  String get profileSignOut;

  /// No description provided for @historyTitle.
  ///
  /// In el, this message translates to:
  /// **'Τα παιχνίδια μου'**
  String get historyTitle;

  /// No description provided for @historySummaryTitle.
  ///
  /// In el, this message translates to:
  /// **'Σύνοψη'**
  String get historySummaryTitle;

  /// No description provided for @createRoomTitle.
  ///
  /// In el, this message translates to:
  /// **'Νέο δωμάτιο'**
  String get createRoomTitle;

  /// No description provided for @createRoomPlayersSection.
  ///
  /// In el, this message translates to:
  /// **'§ 01 · ΠΑΙΚΤΕΣ'**
  String get createRoomPlayersSection;

  /// No description provided for @createRoomLengthSection.
  ///
  /// In el, this message translates to:
  /// **'§ 02 · ΓΥΡΟΙ'**
  String get createRoomLengthSection;

  /// No description provided for @createRoomCreateButton.
  ///
  /// In el, this message translates to:
  /// **'Δημιούργησε δωμάτιο'**
  String get createRoomCreateButton;

  /// No description provided for @joinRoomTitle.
  ///
  /// In el, this message translates to:
  /// **'Μπες σε δωμάτιο'**
  String get joinRoomTitle;

  /// No description provided for @joinRoomCodeSection.
  ///
  /// In el, this message translates to:
  /// **'§ 01 · ΚΩΔΙΚΟΣ'**
  String get joinRoomCodeSection;

  /// No description provided for @joinRoomPasteChip.
  ///
  /// In el, this message translates to:
  /// **'επικόλληση'**
  String get joinRoomPasteChip;

  /// No description provided for @joinRoomJoinButton.
  ///
  /// In el, this message translates to:
  /// **'Συμμετοχή'**
  String get joinRoomJoinButton;

  /// No description provided for @roomLobbyTitle.
  ///
  /// In el, this message translates to:
  /// **'Δωμάτιο'**
  String get roomLobbyTitle;

  /// No description provided for @roomLobbyError.
  ///
  /// In el, this message translates to:
  /// **'Σφάλμα: {error}'**
  String roomLobbyError(String error);

  /// No description provided for @roomLobbyExitTitle.
  ///
  /// In el, this message translates to:
  /// **'Αποχώρηση;'**
  String get roomLobbyExitTitle;

  /// No description provided for @roomLobbyExitBody.
  ///
  /// In el, this message translates to:
  /// **'Θα βγεις από το δωμάτιο.'**
  String get roomLobbyExitBody;

  /// No description provided for @roomLobbyExitCancel.
  ///
  /// In el, this message translates to:
  /// **'Άκυρο'**
  String get roomLobbyExitCancel;

  /// No description provided for @roomLobbyExitConfirm.
  ///
  /// In el, this message translates to:
  /// **'Βγες'**
  String get roomLobbyExitConfirm;

  /// No description provided for @roomLobbyPlayersSection.
  ///
  /// In el, this message translates to:
  /// **'ΠΑΙΚΤΕΣ'**
  String get roomLobbyPlayersSection;

  /// No description provided for @roomLobbyRoomCodeSection.
  ///
  /// In el, this message translates to:
  /// **'ΚΩΔΙΚΟΣ'**
  String get roomLobbyRoomCodeSection;

  /// No description provided for @roomLobbySessionNameHint.
  ///
  /// In el, this message translates to:
  /// **'όνομα παιχνιδιού (προαιρετικό)'**
  String get roomLobbySessionNameHint;

  /// No description provided for @roomLobbyStartGame.
  ///
  /// In el, this message translates to:
  /// **'Ξεκίνα το παιχνίδι'**
  String get roomLobbyStartGame;

  /// No description provided for @roomLobbyWaitingPlayers.
  ///
  /// In el, this message translates to:
  /// **'Περιμένω παίκτες…'**
  String get roomLobbyWaitingPlayers;

  /// No description provided for @roomLobbyCopiedSnack.
  ///
  /// In el, this message translates to:
  /// **'αντιγράφτηκε'**
  String get roomLobbyCopiedSnack;

  /// No description provided for @gameTitle.
  ///
  /// In el, this message translates to:
  /// **'Παιχνίδι'**
  String get gameTitle;

  /// No description provided for @gameLiveLeaderboardTooltip.
  ///
  /// In el, this message translates to:
  /// **'Ζωντανή κατάταξη'**
  String get gameLiveLeaderboardTooltip;

  /// No description provided for @gameLoadError.
  ///
  /// In el, this message translates to:
  /// **'Σφάλμα: {error}'**
  String gameLoadError(String error);

  /// No description provided for @gameNotFound.
  ///
  /// In el, this message translates to:
  /// **'Το παιχνίδι δεν βρέθηκε'**
  String get gameNotFound;

  /// No description provided for @gameUnknownPhase.
  ///
  /// In el, this message translates to:
  /// **'Άγνωστη φάση: {phase}'**
  String gameUnknownPhase(String phase);

  /// No description provided for @gameLeaveTitle.
  ///
  /// In el, this message translates to:
  /// **'Αποχώρηση;'**
  String get gameLeaveTitle;

  /// No description provided for @gameLeaveBody.
  ///
  /// In el, this message translates to:
  /// **'Θα βγεις από το παιχνίδι.'**
  String get gameLeaveBody;

  /// No description provided for @gameLeaveCancel.
  ///
  /// In el, this message translates to:
  /// **'Άκυρο'**
  String get gameLeaveCancel;

  /// No description provided for @gameLeaveConfirm.
  ///
  /// In el, this message translates to:
  /// **'Βγες'**
  String get gameLeaveConfirm;

  /// No description provided for @gameRoundEyebrow.
  ///
  /// In el, this message translates to:
  /// **'ΓΥΡΟΣ'**
  String get gameRoundEyebrow;

  /// No description provided for @gameCardsThisRound.
  ///
  /// In el, this message translates to:
  /// **'{count, plural, =1 {1 κάρτα} other {{count} κάρτες}}'**
  String gameCardsThisRound(int count);

  /// No description provided for @predictionLockButton.
  ///
  /// In el, this message translates to:
  /// **'Κλείδωμα'**
  String get predictionLockButton;

  /// No description provided for @predictionMyLockedTitle.
  ///
  /// In el, this message translates to:
  /// **'Η πρόβλεψή σου κλειδώθηκε'**
  String get predictionMyLockedTitle;

  /// No description provided for @predictionWaitingTitle.
  ///
  /// In el, this message translates to:
  /// **'αναμονή…'**
  String get predictionWaitingTitle;

  /// No description provided for @predictionTurnOf.
  ///
  /// In el, this message translates to:
  /// **'σειρά του {name}'**
  String predictionTurnOf(String name);

  /// No description provided for @predictionBidOrderSection.
  ///
  /// In el, this message translates to:
  /// **'ΣΕΙΡΑ'**
  String get predictionBidOrderSection;

  /// No description provided for @playingPastSection.
  ///
  /// In el, this message translates to:
  /// **'ΠΡΟΗΓΟΥΜΕΝΕΣ'**
  String get playingPastSection;

  /// No description provided for @playingPastEmpty.
  ///
  /// In el, this message translates to:
  /// **'καμιά μπάζα ακόμα'**
  String get playingPastEmpty;

  /// No description provided for @playingMistakeButton.
  ///
  /// In el, this message translates to:
  /// **'Λάθος'**
  String get playingMistakeButton;

  /// No description provided for @playingConfirmButton.
  ///
  /// In el, this message translates to:
  /// **'Επιβεβαίωση'**
  String get playingConfirmButton;

  /// No description provided for @playingProposalSection.
  ///
  /// In el, this message translates to:
  /// **'ΠΡΟΤΑΣΗ'**
  String get playingProposalSection;

  /// No description provided for @playingProposalBy.
  ///
  /// In el, this message translates to:
  /// **'από {name}'**
  String playingProposalBy(String name);

  /// No description provided for @playingConfirmationCount.
  ///
  /// In el, this message translates to:
  /// **'συμφωνίες {count} / {threshold}'**
  String playingConfirmationCount(int count, int threshold);

  /// No description provided for @playingProposerWaiting.
  ///
  /// In el, this message translates to:
  /// **'αναμονή για τους υπόλοιπους…'**
  String get playingProposerWaiting;

  /// No description provided for @playingTrickEyebrow.
  ///
  /// In el, this message translates to:
  /// **'ΜΠΑΖΑ'**
  String get playingTrickEyebrow;

  /// No description provided for @roundHeaderLeadsLabel.
  ///
  /// In el, this message translates to:
  /// **'ΞΕΚΙΝΑ'**
  String get roundHeaderLeadsLabel;

  /// No description provided for @roundHeaderDealerLabel.
  ///
  /// In el, this message translates to:
  /// **'ΜΟΙΡΑΖΕΙ'**
  String get roundHeaderDealerLabel;

  /// No description provided for @scoreTallySection.
  ///
  /// In el, this message translates to:
  /// **'ΣΚΟΡ'**
  String get scoreTallySection;

  /// No description provided for @liveScoreboardTitle.
  ///
  /// In el, this message translates to:
  /// **'ΖΩΝΤΑΝΗ ΚΑΤΑΤΑΞΗ'**
  String get liveScoreboardTitle;

  /// No description provided for @liveScoreboardChartTitle.
  ///
  /// In el, this message translates to:
  /// **'ΕΞΕΛΙΞΗ ΣΚΟΡ'**
  String get liveScoreboardChartTitle;

  /// No description provided for @shortStrawTitle.
  ///
  /// In el, this message translates to:
  /// **'ΤΡΑΒΟΥΜΕ ΚΛΗΡΟ'**
  String get shortStrawTitle;

  /// No description provided for @predictionRoundEyebrow.
  ///
  /// In el, this message translates to:
  /// **'ΓΥΡΟΣ ΠΡΟΒΛΕΨΕΩΝ'**
  String get predictionRoundEyebrow;

  /// No description provided for @validatingResultsSection.
  ///
  /// In el, this message translates to:
  /// **'Αποτελέσματα'**
  String get validatingResultsSection;

  /// No description provided for @validatingConfirmedChip.
  ///
  /// In el, this message translates to:
  /// **'Επιβεβαιώθηκε'**
  String get validatingConfirmedChip;

  /// No description provided for @validatingConfirmButton.
  ///
  /// In el, this message translates to:
  /// **'Επιβεβαίωση αποτελεσμάτων'**
  String get validatingConfirmButton;

  /// No description provided for @validatingChallengeTooltip.
  ///
  /// In el, this message translates to:
  /// **'Αμφισβήτηση'**
  String get validatingChallengeTooltip;

  /// No description provided for @gameOverWinnerLabel.
  ///
  /// In el, this message translates to:
  /// **'ΝΙΚΗΤΗΣ'**
  String get gameOverWinnerLabel;

  /// No description provided for @gameOverFinalLabel.
  ///
  /// In el, this message translates to:
  /// **'ΚΑΤΑΤΑΞΗ'**
  String get gameOverFinalLabel;

  /// No description provided for @gameOverNarrationLabel.
  ///
  /// In el, this message translates to:
  /// **'ΝΑΡΡΗΣΗ'**
  String get gameOverNarrationLabel;

  /// No description provided for @gameOverAwardsLabel.
  ///
  /// In el, this message translates to:
  /// **'ΒΡΑΒΕΙΑ'**
  String get gameOverAwardsLabel;

  /// No description provided for @gameOverMomentsLabel.
  ///
  /// In el, this message translates to:
  /// **'ΣΤΙΓΜΕΣ'**
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

  /// No description provided for @gameOverShareError.
  ///
  /// In el, this message translates to:
  /// **'Σφάλμα κοινοποίησης: {error}'**
  String gameOverShareError(String error);

  /// No description provided for @gameOverSaveToPhotos.
  ///
  /// In el, this message translates to:
  /// **'Αποθήκευση στις φωτογραφίες'**
  String get gameOverSaveToPhotos;

  /// No description provided for @gameOverSavedToPhotos.
  ///
  /// In el, this message translates to:
  /// **'αποθηκεύτηκε στις φωτογραφίες'**
  String get gameOverSavedToPhotos;

  /// No description provided for @gameOverSaveError.
  ///
  /// In el, this message translates to:
  /// **'δεν αποθηκεύτηκε · έλεγξε τα δικαιώματα'**
  String get gameOverSaveError;

  /// No description provided for @gameOverGenericError.
  ///
  /// In el, this message translates to:
  /// **'Σφάλμα: {error}'**
  String gameOverGenericError(String error);

  /// No description provided for @gameOverBackToMenu.
  ///
  /// In el, this message translates to:
  /// **'Πίσω στο μενού'**
  String get gameOverBackToMenu;

  /// No description provided for @momentsAddPrompt.
  ///
  /// In el, this message translates to:
  /// **'Πρόσθεσε στιγμή'**
  String get momentsAddPrompt;

  /// No description provided for @momentsAddSubtitle.
  ///
  /// In el, this message translates to:
  /// **'μια φράση για να θυμάστε αυτό το παιχνίδι'**
  String get momentsAddSubtitle;

  /// No description provided for @momentsHintExample.
  ///
  /// In el, this message translates to:
  /// **'π.χ. Ο Caesar κάλεσε 5, πήρε 0. Ωραία βραδιά.'**
  String get momentsHintExample;

  /// No description provided for @momentsRoundChipAll.
  ///
  /// In el, this message translates to:
  /// **'ΌΛΟ'**
  String get momentsRoundChipAll;

  /// No description provided for @momentsSaveButton.
  ///
  /// In el, this message translates to:
  /// **'Αποθήκευση'**
  String get momentsSaveButton;

  /// No description provided for @momentsSaveError.
  ///
  /// In el, this message translates to:
  /// **'Σφάλμα: {error}'**
  String momentsSaveError(String error);

  /// No description provided for @momentsDeleteTitle.
  ///
  /// In el, this message translates to:
  /// **'Διαγραφή στιγμής;'**
  String get momentsDeleteTitle;

  /// No description provided for @momentsDeleteBody.
  ///
  /// In el, this message translates to:
  /// **'Θα αφαιρεθεί από το σύνολο.'**
  String get momentsDeleteBody;

  /// No description provided for @momentsDeleteCancel.
  ///
  /// In el, this message translates to:
  /// **'Άκυρο'**
  String get momentsDeleteCancel;

  /// No description provided for @momentsDeleteConfirm.
  ///
  /// In el, this message translates to:
  /// **'Διέγραψε'**
  String get momentsDeleteConfirm;

  /// No description provided for @momentsDeleteError.
  ///
  /// In el, this message translates to:
  /// **'Σφάλμα διαγραφής: {error}'**
  String momentsDeleteError(String error);

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
  /// **'§ 01 · ΟΙ ΣΤΑΤΙΣΤΙΚΕΣ ΣΟΥ'**
  String get leaderboardYouSection;

  /// No description provided for @leaderboardTopSection.
  ///
  /// In el, this message translates to:
  /// **'§ 02 · ΚΟΡΥΦΑΙΟΙ'**
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
  /// **'ΑΠΟΨΕ'**
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
  /// **'ΣΕ ΕΞΕΛΙΞΗ'**
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
  /// **'ΠΑΡΕΑ'**
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
  /// **'ΠΑΙΧΝΙΔΙΑ'**
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

  /// No description provided for @pareaSharedGames.
  ///
  /// In el, this message translates to:
  /// **'{count, plural, =1 {1 παρτίδα · 30 μέρες} other {{count} παρτίδες · 30 μέρες}}'**
  String pareaSharedGames(int count);

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
  /// **'ΑΙΤΗΣΕΙΣ'**
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
  /// **'ΦΙΛΟΙ'**
  String get pareaYoursSection;

  /// No description provided for @pareaYoursEmpty.
  ///
  /// In el, this message translates to:
  /// **'πρόσθεσε τον πρώτο σου φίλο πιο πάνω'**
  String get pareaYoursEmpty;

  /// No description provided for @pareaSentSection.
  ///
  /// In el, this message translates to:
  /// **'ΣΕ ΑΝΑΜΟΝΗ'**
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
  /// **'ΤΟΥΡΝΟΥΑ'**
  String get tournamentSection;

  /// No description provided for @tournamentTopSection.
  ///
  /// In el, this message translates to:
  /// **'ΚΟΡΥΦΗ'**
  String get tournamentTopSection;

  /// No description provided for @tournamentYouSection.
  ///
  /// In el, this message translates to:
  /// **'ΕΣΥ'**
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
      'that was used.');
}
