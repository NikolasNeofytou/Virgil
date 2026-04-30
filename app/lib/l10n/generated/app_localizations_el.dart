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
  String get usernamePickerSection => '§ 01 · ΟΝΟΜΑ · NAME';

  @override
  String get usernamePickerTitle => 'Διάλεξε όνομα';

  @override
  String get usernamePickerSubtitle => 'το όνομά σου στο τραπέζι';

  @override
  String get usernamePickerHint => '3–24 χαρακτήρες · γράμματα, αριθμοί, _';

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
  String get gameOverWinnerLabel => 'ΝΙΚΗΤΗΣ · WINNER';

  @override
  String get gameOverFinalLabel => 'ΚΑΤΑΤΑΞΗ · FINAL';

  @override
  String get gameOverNarrationLabel => 'ΝΑΡΡΗΣΗ · NIGHT NOTE';

  @override
  String get gameOverAwardsLabel => 'ΒΡΑΒΕΙΑ · AWARDS';

  @override
  String get gameOverMomentsLabel => 'ΣΤΙΓΜΕΣ · MOMENTS';

  @override
  String gameOverPoints(int score) {
    return '$score πόντοι';
  }

  @override
  String get gameOverRematch => 'Νέο παιχνίδι';

  @override
  String get gameOverShare => 'Κοινοποίηση';

  @override
  String get gameOverBackToMenu => 'Πίσω στο μενού';

  @override
  String get leaderboardTitle => 'Κατάταξη';

  @override
  String get leaderboardSubtitle => 'τα σκορ του τραπεζιού';

  @override
  String get leaderboardYouSection => '§ 01 · ΟΙ ΣΤΑΤΙΣΤΙΚΕΣ ΣΟΥ · YOU';

  @override
  String get leaderboardTopSection => '§ 02 · TOP 10 · LEADERS';

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
  String get lobbyTonightSection => 'ΑΠΟΨΕ · TONIGHT';

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
  String get lobbyInProgressSection => 'ΣΕ ΕΞΕΛΙΞΗ · IN PROGRESS';

  @override
  String get lobbyInProgressLobby => 'στο δωμάτιο';

  @override
  String lobbyInProgressRound(int round) {
    return 'Γύρος $round';
  }

  @override
  String get lobbyParcaInPlaySection => 'ΠΑΡΕΑ · IN PLAY';

  @override
  String get lobbyParcaResting => 'η παρέα ξεκουράζεται';

  @override
  String get lobbyFriendStatusWaiting => 'καθιστά';

  @override
  String get lobbyFriendStatusActive => 'παίζει';

  @override
  String get lobbyFriendJoinError => 'δεν μπόρεσα να μπω';

  @override
  String get lobbyGamesSection => 'ΠΑΙΧΝΙΔΙΑ · GAMES';

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
  String get pareaInboxSection => 'ΑΙΤΗΣΕΙΣ · INBOX';

  @override
  String get pareaInboxEmpty => 'δεν έχεις αιτήσεις αυτή τη στιγμή';

  @override
  String get pareaInboxWantsToBeFriends => 'θέλει να γίνει φίλος σου';

  @override
  String get pareaInboxAccept => 'Δέξου';

  @override
  String get pareaInboxDecline => 'Απόρριψη';

  @override
  String get pareaYoursSection => 'ΦΙΛΟΙ · YOURS';

  @override
  String get pareaYoursEmpty => 'πρόσθεσε τον πρώτο σου φίλο πιο πάνω';

  @override
  String get pareaSentSection => 'ΣΕ ΑΝΑΜΟΝΗ · SENT';

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
  String get tournamentSection => 'ΤΟΥΡΝΟΥΑ · TOURNAMENT';

  @override
  String get tournamentTopSection => 'ΚΟΡΥΦΗ · TOP 10';

  @override
  String get tournamentYouSection => 'ΕΣΥ · YOU';

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
