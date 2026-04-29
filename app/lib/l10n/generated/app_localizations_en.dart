// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Virgil';

  @override
  String get appTagline => 'a guide for the table';

  @override
  String get tabPlay => 'Play';

  @override
  String get tabFriends => 'Friends';

  @override
  String get tabLeaderboard => 'Leaderboard';

  @override
  String get tabProfile => 'Profile';

  @override
  String get signInTitle => 'Welcome';

  @override
  String get signInSubtitle => 'sign in to take a seat';

  @override
  String get usernamePickerSection => '§ 01 · NAME';

  @override
  String get usernamePickerTitle => 'Pick a name';

  @override
  String get usernamePickerSubtitle => 'your name at the table';

  @override
  String get usernamePickerHint => '3–24 chars · letters, numbers, _';

  @override
  String get usernamePickerSubmit => 'Continue';

  @override
  String get usernamePickerErrorInvalid => '3–24 chars · letters, numbers, _';

  @override
  String get usernamePickerErrorTaken => 'that name is already taken';

  @override
  String get usernamePickerErrorSession => 'session expired · sign in again';

  @override
  String get usernamePickerErrorGeneric => 'error · try again';

  @override
  String get gameOverWinnerLabel => 'WINNER';

  @override
  String get gameOverFinalLabel => 'FINAL';

  @override
  String get gameOverNarrationLabel => 'NIGHT NOTE';

  @override
  String get gameOverAwardsLabel => 'AWARDS';

  @override
  String get gameOverMomentsLabel => 'MOMENTS';

  @override
  String gameOverPoints(int score) {
    return '$score points';
  }

  @override
  String get gameOverRematch => 'New game';

  @override
  String get gameOverShare => 'Share';

  @override
  String get gameOverBackToMenu => 'Back to menu';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardSubtitle => 'the scores at the table';

  @override
  String get leaderboardYouSection => '§ 01 · YOU';

  @override
  String get leaderboardTopSection => '§ 02 · TOP 10 · LEADERS';

  @override
  String get leaderboardYouBadge => 'YOU';

  @override
  String get leaderboardWinsLabel => 'WINS';

  @override
  String get leaderboardYourPosition => 'your position';

  @override
  String get leaderboardEmptyTitle => 'empty page';

  @override
  String get leaderboardEmptyBody =>
      'be the first one on the board.\none finished game is enough.';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get lobbyGreetingMorning => 'Good morning';

  @override
  String get lobbyGreetingAfternoon => 'Good afternoon';

  @override
  String get lobbyGreetingEvening => 'Good evening';

  @override
  String get lobbyGreetingFallback => 'Welcome';

  @override
  String get lobbyHeroTitle => 'A table is set for you.';

  @override
  String get lobbyTodayLabel => 'TODAY';

  @override
  String get lobbyTonightSection => 'TONIGHT';

  @override
  String get lobbyEstimationName => 'Estimation';

  @override
  String get lobbyEstimationDescription =>
      'Call your tricks. See who reads the cards.';

  @override
  String get lobbyTakeYourSeat => 'Take your seat';

  @override
  String get lobbyJoin => 'Join';

  @override
  String get lobbyContinueLabel => 'Continue';

  @override
  String get lobbyInProgressSection => 'IN PROGRESS';

  @override
  String get lobbyInProgressLobby => 'lobby';

  @override
  String lobbyInProgressRound(int round) {
    return 'Round $round';
  }

  @override
  String get lobbyGamesSection => 'GAMES';

  @override
  String get lobbyGamePilotta => 'Pilotta';

  @override
  String get lobbyGamePilottaTagline => 'Cypriot living-room classic.';

  @override
  String get lobbyGameTavli => 'Tavli';

  @override
  String get lobbyGameTavliTagline => 'Three games — Portes, Plakoto, Fevga.';

  @override
  String get lobbyGameBiriba => 'Biriba';

  @override
  String get lobbyGameBiribaTagline =>
      'Two decks. Long sittings. Family staple.';

  @override
  String get lobbyChipLive => 'live';

  @override
  String get lobbyChipSoon => 'soon';
}
