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
  String get profileSignOut => 'Αποσύνδεση';
}
