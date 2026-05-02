// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Virgil';

  @override
  String get appTagline => 'ένας οδηγός για το τραπέζι';

  @override
  String get tabPlay => 'Παίξε';

  @override
  String get tabFriends => 'Φίλοι';

  @override
  String get tabLeaderboard => 'Κατάταξη';

  @override
  String get tabProfile => 'Προφίλ';

  @override
  String get signInTitle => 'Καλώς ήρθες';

  @override
  String get signInSubtitle => 'συνδέσου για να μπεις στο τραπέζι';

  @override
  String get signInPasswordLabel => 'Κωδικός';

  @override
  String get signInSubmitPassword => 'Σύνδεση';

  @override
  String get signInSubmitOtp => 'Αποστολή κωδικού';

  @override
  String get signInToggleToOtp => 'Σύνδεση με email OTP';

  @override
  String get signInToggleToPassword => 'Σύνδεση με κωδικό';

  @override
  String get signInOtpSection => 'ΕΛΕΓΞΕ ΤΟ EMAIL';

  @override
  String get signInOtpSent => 'σου στείλαμε κωδικό';

  @override
  String get signInOtpVerify => 'Επιβεβαίωση';

  @override
  String get signInBack => 'Πίσω';

  @override
  String get usernamePickerSection => '§ 01 · ΟΝΟΜΑ';

  @override
  String get usernamePickerTitle => 'Διάλεξε όνομα';

  @override
  String get usernamePickerSubtitle => 'το όνομά σου στο τραπέζι';

  @override
  String get usernamePickerHint => '3–24 χαρακτήρες · γράμματα, αριθμοί, _';

  @override
  String get usernamePickerInputHint => 'όνομα…';

  @override
  String get usernamePickerSubmit => 'Συνέχεια';

  @override
  String get usernamePickerErrorInvalid =>
      '3–24 χαρακτήρες · γράμματα, αριθμοί, _';

  @override
  String get usernamePickerErrorTaken => 'αυτό το όνομα υπάρχει ήδη';

  @override
  String get usernamePickerErrorSession => 'η σύνδεση έληξε · συνδέσου ξανά';

  @override
  String get usernamePickerErrorGeneric => 'σφάλμα · δοκίμασε ξανά';

  @override
  String get profileTitle => 'Προφίλ';

  @override
  String profileLoadError(String error) {
    return 'σφάλμα · $error';
  }

  @override
  String get profileStatsSection => '§ 01 · ΣΤΑΤΙΣΤΙΚΑ';

  @override
  String get profileHistorySection => '§ 02 · ΤΑ ΠΑΙΧΝΙΔΙΑ ΜΟΥ';

  @override
  String get profileSettingsSection => '§ 03 · ΡΥΘΜΙΣΕΙΣ';

  @override
  String get profileLanguageLabel => 'Γλώσσα';

  @override
  String get profileIconLabel => 'Εικονίδιο';

  @override
  String get profileIconAegean => 'Αιγαίο';

  @override
  String get profileIconAegeanRole => 'ΒΑΣΙΚΟ';

  @override
  String get profileIconCoral => 'Κοράλλι';

  @override
  String get profileIconCoralRole => 'ΤΟΥΡΝΟΥΑ';

  @override
  String get profileIconOchre => 'Ώχρα';

  @override
  String get profileIconOchreRole => 'ΒΑΘΜΙΔΑ';

  @override
  String get profileIconError => 'δεν άλλαξε το εικονίδιο';

  @override
  String get profileSignOut => 'Αποσύνδεση';

  @override
  String get historyTitle => 'Τα παιχνίδια μου';

  @override
  String get historySummaryTitle => 'Σύνοψη';

  @override
  String get createRoomTitle => 'Νέο δωμάτιο';

  @override
  String get createRoomPlayersSection => '§ 01 · ΠΑΙΚΤΕΣ';

  @override
  String get createRoomLengthSection => '§ 02 · ΓΥΡΟΙ';

  @override
  String get createRoomCreateButton => 'Δημιούργησε δωμάτιο';

  @override
  String get joinRoomTitle => 'Μπες σε δωμάτιο';

  @override
  String get joinRoomCodeSection => '§ 01 · ΚΩΔΙΚΟΣ';

  @override
  String get joinRoomPasteChip => 'επικόλληση';

  @override
  String get joinRoomJoinButton => 'Συμμετοχή';

  @override
  String get roomLobbyTitle => 'Δωμάτιο';

  @override
  String roomLobbyError(String error) {
    return 'Σφάλμα: $error';
  }

  @override
  String get roomLobbyExitTitle => 'Αποχώρηση;';

  @override
  String get roomLobbyExitBody => 'Θα βγεις από το δωμάτιο.';

  @override
  String get roomLobbyExitCancel => 'Άκυρο';

  @override
  String get roomLobbyExitConfirm => 'Βγες';

  @override
  String get roomLobbyPlayersSection => 'ΠΑΙΚΤΕΣ';

  @override
  String get roomLobbyRoomCodeSection => 'ΚΩΔΙΚΟΣ';

  @override
  String get roomLobbySessionNameHint => 'όνομα παιχνιδιού (προαιρετικό)';

  @override
  String get roomLobbyStartGame => 'Ξεκίνα το παιχνίδι';

  @override
  String get roomLobbyWaitingPlayers => 'Περιμένω παίκτες…';

  @override
  String get roomLobbyCopiedSnack => 'αντιγράφτηκε';

  @override
  String get gameTitle => 'Παιχνίδι';

  @override
  String get gameLiveLeaderboardTooltip => 'Ζωντανή κατάταξη';

  @override
  String gameLoadError(String error) {
    return 'Σφάλμα: $error';
  }

  @override
  String get gameNotFound => 'Το παιχνίδι δεν βρέθηκε';

  @override
  String gameUnknownPhase(String phase) {
    return 'Άγνωστη φάση: $phase';
  }

  @override
  String get gameLeaveTitle => 'Αποχώρηση;';

  @override
  String get gameLeaveBody => 'Θα βγεις από το παιχνίδι.';

  @override
  String get gameLeaveCancel => 'Άκυρο';

  @override
  String get gameLeaveConfirm => 'Βγες';

  @override
  String get gameRoundEyebrow => 'ΓΥΡΟΣ';

  @override
  String gameCardsThisRound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count κάρτες',
      one: '1 κάρτα',
    );
    return '$_temp0';
  }

  @override
  String get predictionLockButton => 'Κλείδωμα';

  @override
  String get predictionMyLockedTitle => 'Η πρόβλεψή σου κλειδώθηκε';

  @override
  String get predictionWaitingTitle => 'αναμονή…';

  @override
  String predictionTurnOf(String name) {
    return 'σειρά του $name';
  }

  @override
  String get predictionBidOrderSection => 'ΣΕΙΡΑ';

  @override
  String get playingPastSection => 'ΠΡΟΗΓΟΥΜΕΝΕΣ';

  @override
  String get playingPastEmpty => 'καμιά μπάζα ακόμα';

  @override
  String get playingMistakeButton => 'Λάθος';

  @override
  String get playingConfirmButton => 'Επιβεβαίωση';

  @override
  String get playingProposalSection => 'ΠΡΟΤΑΣΗ';

  @override
  String playingProposalBy(String name) {
    return 'από $name';
  }

  @override
  String playingConfirmationCount(int count, int threshold) {
    return 'συμφωνίες $count / $threshold';
  }

  @override
  String get playingProposerWaiting => 'αναμονή για τους υπόλοιπους…';

  @override
  String get playingTrickEyebrow => 'ΜΠΑΖΑ';

  @override
  String get roundHeaderLeadsLabel => 'ΞΕΚΙΝΑ';

  @override
  String get roundHeaderDealerLabel => 'ΜΟΙΡΑΖΕΙ';

  @override
  String get scoreTallySection => 'ΣΚΟΡ';

  @override
  String get liveScoreboardTitle => 'ΖΩΝΤΑΝΗ ΚΑΤΑΤΑΞΗ';

  @override
  String get liveScoreboardChartTitle => 'ΕΞΕΛΙΞΗ ΣΚΟΡ';

  @override
  String get shortStrawTitle => 'ΤΡΑΒΟΥΜΕ ΚΛΗΡΟ';

  @override
  String get predictionRoundEyebrow => 'ΓΥΡΟΣ ΠΡΟΒΛΕΨΕΩΝ';

  @override
  String get validatingResultsSection => 'Αποτελέσματα';

  @override
  String get validatingConfirmedChip => 'Επιβεβαιώθηκε';

  @override
  String get validatingConfirmButton => 'Επιβεβαίωση αποτελεσμάτων';

  @override
  String get validatingChallengeTooltip => 'Αμφισβήτηση';

  @override
  String get gameOverWinnerLabel => 'ΝΙΚΗΤΗΣ';

  @override
  String get gameOverFinalLabel => 'ΚΑΤΑΤΑΞΗ';

  @override
  String get gameOverNarrationLabel => 'ΝΑΡΡΗΣΗ';

  @override
  String get gameOverAwardsLabel => 'ΒΡΑΒΕΙΑ';

  @override
  String get gameOverMomentsLabel => 'ΣΤΙΓΜΕΣ';

  @override
  String gameOverPoints(int score) {
    return '$score πόντοι';
  }

  @override
  String get gameOverRematch => 'Νέο παιχνίδι';

  @override
  String get gameOverShare => 'Κοινοποίηση';

  @override
  String gameOverShareError(String error) {
    return 'Σφάλμα κοινοποίησης: $error';
  }

  @override
  String get gameOverSaveToPhotos => 'Αποθήκευση στις φωτογραφίες';

  @override
  String get gameOverSavedToPhotos => 'αποθηκεύτηκε στις φωτογραφίες';

  @override
  String get gameOverSaveError => 'δεν αποθηκεύτηκε · έλεγξε τα δικαιώματα';

  @override
  String gameOverGenericError(String error) {
    return 'Σφάλμα: $error';
  }

  @override
  String get gameOverBackToMenu => 'Πίσω στο μενού';

  @override
  String get momentsAddPrompt => 'Πρόσθεσε στιγμή';

  @override
  String get momentsAddSubtitle => 'μια φράση για να θυμάστε αυτό το παιχνίδι';

  @override
  String get momentsHintExample =>
      'π.χ. Ο Caesar κάλεσε 5, πήρε 0. Ωραία βραδιά.';

  @override
  String get momentsRoundChipAll => 'ΌΛΟ';

  @override
  String get momentsSaveButton => 'Αποθήκευση';

  @override
  String momentsSaveError(String error) {
    return 'Σφάλμα: $error';
  }

  @override
  String get momentsDeleteTitle => 'Διαγραφή στιγμής;';

  @override
  String get momentsDeleteBody => 'Θα αφαιρεθεί από το σύνολο.';

  @override
  String get momentsDeleteCancel => 'Άκυρο';

  @override
  String get momentsDeleteConfirm => 'Διέγραψε';

  @override
  String momentsDeleteError(String error) {
    return 'Σφάλμα διαγραφής: $error';
  }

  @override
  String get leaderboardTitle => 'Κατάταξη';

  @override
  String get leaderboardSubtitle => 'τα σκορ του τραπεζιού';

  @override
  String get leaderboardYouSection => '§ 01 · ΟΙ ΣΤΑΤΙΣΤΙΚΕΣ ΣΟΥ';

  @override
  String get leaderboardTopSection => '§ 02 · ΚΟΡΥΦΑΙΟΙ';

  @override
  String get leaderboardYouBadge => 'ΕΣΥ';

  @override
  String get leaderboardWinsLabel => 'WINS';

  @override
  String get leaderboardYourPosition => 'η θέση σου';

  @override
  String get leaderboardEmptyTitle => 'κενό φύλλο';

  @override
  String get leaderboardEmptyBody =>
      'γίνε ο πρώτος που θα μπει στην κατάταξη.\nένα κλειστό παιχνίδι αρκεί.';

  @override
  String get lobbyGreetingMorning => 'Καλημέρα';

  @override
  String get lobbyGreetingAfternoon => 'Καλησπέρα';

  @override
  String get lobbyGreetingEvening => 'Καλό βράδυ';

  @override
  String get lobbyGreetingFallback => 'Καλώς ήρθες';

  @override
  String get lobbyHeroTitle => 'Στρώθηκε τραπέζι για εσένα.';

  @override
  String get lobbyTodayLabel => 'ΣΗΜΕΡΑ';

  @override
  String get lobbyTonightSection => 'ΑΠΟΨΕ';

  @override
  String get lobbyEstimationName => 'Πρόβλεψη';

  @override
  String get lobbyEstimationDescription =>
      'Πες πόσες μπάζες θα πάρεις. Δες ποιος ξέρει τα χαρτιά του.';

  @override
  String get lobbyTakeYourSeat => 'Πιάσε θέση';

  @override
  String get lobbyJoin => 'Μπες';

  @override
  String get lobbyContinueLabel => 'Συνέχισε';

  @override
  String get lobbyInProgressSection => 'ΣΕ ΕΞΕΛΙΞΗ';

  @override
  String get lobbyInProgressLobby => 'στο δωμάτιο';

  @override
  String lobbyInProgressRound(int round) {
    return 'Γύρος $round';
  }

  @override
  String get lobbyParcaInPlaySection => 'ΠΑΡΕΑ';

  @override
  String get lobbyParcaResting => 'η παρέα ξεκουράζεται';

  @override
  String get lobbyFriendStatusWaiting => 'καθιστά';

  @override
  String get lobbyFriendStatusActive => 'παίζει';

  @override
  String get lobbyFriendJoinError => 'δεν μπόρεσα να μπω';

  @override
  String get lobbyGamesSection => 'ΠΑΙΧΝΙΔΙΑ';

  @override
  String get lobbyGamePilotta => 'Πιλόττα';

  @override
  String get lobbyGamePilottaTagline => 'Η Κυπριακή κλασική του καφενείου.';

  @override
  String get lobbyGameTavli => 'Ταβλί';

  @override
  String get lobbyGameTavliTagline =>
      'Τρία παιχνίδια — Πόρτες, Πλακωτό, Φεύγα.';

  @override
  String get lobbyGameBiriba => 'Μπιρίμπα';

  @override
  String get lobbyGameBiribaTagline =>
      'Δύο τράπουλες. Μεγάλα παιχνίδια. Οικογενειακό.';

  @override
  String get lobbyChipLive => 'live';

  @override
  String get lobbyChipSoon => 'σύντομα';

  @override
  String pareaSharedGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count παρτίδες · 30 μέρες',
      one: '1 παρτίδα · 30 μέρες',
    );
    return '$_temp0';
  }

  @override
  String get pareaTitle => 'Παρέα';

  @override
  String get pareaSubtitle => 'η παρέα σου';

  @override
  String get pareaAddPrompt => 'Πρόσθεσε φίλο';

  @override
  String get pareaAddHint => 'όνομα';

  @override
  String get pareaAddSubmit => 'Στείλε';

  @override
  String pareaAddSuccess(String username) {
    return 'στάλθηκε στον @$username';
  }

  @override
  String get pareaAddErrorGeneric => 'σφάλμα · δοκίμασε ξανά';

  @override
  String get pareaInboxSection => 'ΑΙΤΗΣΕΙΣ';

  @override
  String get pareaInboxEmpty => 'δεν έχεις αιτήσεις αυτή τη στιγμή';

  @override
  String get pareaInboxWantsToBeFriends => 'θέλει να γίνει φίλος σου';

  @override
  String get pareaInboxAccept => 'Δέξου';

  @override
  String get pareaInboxDecline => 'Απόρριψη';

  @override
  String get pareaYoursSection => 'ΦΙΛΟΙ';

  @override
  String get pareaYoursEmpty => 'πρόσθεσε τον πρώτο σου φίλο πιο πάνω';

  @override
  String get pareaSentSection => 'ΣΕ ΑΝΑΜΟΝΗ';

  @override
  String get pareaSentEmpty => 'καμία αίτηση σε αναμονή';

  @override
  String get pareaSentLabel => 'αναμονή επιβεβαίωσης';

  @override
  String get pareaSentCancel => 'Ακύρωση';

  @override
  String pareaUnfriendTitle(String username) {
    return 'Αφαίρεση @$username;';
  }

  @override
  String get pareaUnfriendBody => 'Η φιλία θα διαγραφεί και για τους δύο.';

  @override
  String get pareaUnfriendConfirm => 'Αφαίρεσε';

  @override
  String get pareaUnfriendCancel => 'Άκυρο';

  @override
  String get tournamentSection => 'ΤΟΥΡΝΟΥΑ';

  @override
  String get tournamentTopSection => 'ΚΟΡΥΦΗ';

  @override
  String get tournamentYouSection => 'ΕΣΥ';

  @override
  String get tournamentStatGames => 'GAMES';

  @override
  String get tournamentStatWins => 'WINS';

  @override
  String get tournamentStatAccuracy => 'ACCURACY';

  @override
  String get tournamentStatPoints => 'POINTS';

  @override
  String get tournamentEmptyTitle => 'κενό φύλλο';

  @override
  String get tournamentEmptyBody =>
      'γίνε ο πρώτος που θα μπει στην κατάταξη.\nένα κλειστό παιχνίδι αρκεί.';

  @override
  String get tournamentYouAreHere => 'η θέση σου';

  @override
  String get tournamentNoGamesTitle => 'κανένα κλειστό παιχνίδι ακόμη';

  @override
  String get tournamentNoGamesBody => 'ξεκίνα ένα για να μπεις στο τουρνουά.';

  @override
  String tournamentGamesPointsLabel(int games, int points) {
    return '$games παιχνίδια · $points π.';
  }
}
