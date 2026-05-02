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
  String get signInPasswordLabel => 'Password';

  @override
  String get signInSubmitPassword => 'Sign in';

  @override
  String get signInSubmitOtp => 'Send code';

  @override
  String get signInToggleToOtp => 'Sign in with email OTP';

  @override
  String get signInToggleToPassword => 'Sign in with a password';

  @override
  String get signInOtpSection => 'CHECK YOUR EMAIL';

  @override
  String get signInOtpSent => 'we sent you a code';

  @override
  String get signInOtpVerify => 'Verify';

  @override
  String get signInBack => 'Back';

  @override
  String get usernamePickerSection => '§ 01 · NAME';

  @override
  String get usernamePickerTitle => 'Pick a name';

  @override
  String get usernamePickerSubtitle => 'your name at the table';

  @override
  String get usernamePickerHint => '3–24 chars · letters, numbers, _';

  @override
  String get usernamePickerInputHint => 'name…';

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
  String get profileTitle => 'Profile';

  @override
  String profileLoadError(String error) {
    return 'error · $error';
  }

  @override
  String get profileStatsSection => '§ 01 · STATS';

  @override
  String get profileHistorySection => '§ 02 · HISTORY';

  @override
  String get profileSettingsSection => '§ 03 · SETTINGS';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get profileIconLabel => 'Icon';

  @override
  String get profileIconAegean => 'Aegean';

  @override
  String get profileIconAegeanRole => 'DEFAULT';

  @override
  String get profileIconCoral => 'Coral';

  @override
  String get profileIconCoralRole => 'TOURNAMENTS';

  @override
  String get profileIconOchre => 'Ochre';

  @override
  String get profileIconOchreRole => 'RANKED';

  @override
  String get profileIconError => 'couldn\'t change the icon';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get historyTitle => 'My games';

  @override
  String get historySummaryTitle => 'Summary';

  @override
  String get createRoomTitle => 'New room';

  @override
  String get createRoomPlayersSection => '§ 01 · PLAYERS';

  @override
  String get createRoomLengthSection => '§ 02 · LENGTH';

  @override
  String get createRoomCreateButton => 'Create room';

  @override
  String get joinRoomTitle => 'Join a room';

  @override
  String get joinRoomCodeSection => '§ 01 · CODE';

  @override
  String get joinRoomPasteChip => 'paste';

  @override
  String get joinRoomJoinButton => 'Join';

  @override
  String get roomLobbyTitle => 'Room';

  @override
  String roomLobbyError(String error) {
    return 'Error: $error';
  }

  @override
  String get roomLobbyExitTitle => 'Leave?';

  @override
  String get roomLobbyExitBody => 'You will leave the room.';

  @override
  String get roomLobbyExitCancel => 'Cancel';

  @override
  String get roomLobbyExitConfirm => 'Leave';

  @override
  String get roomLobbyPlayersSection => 'SEATED';

  @override
  String get roomLobbyRoomCodeSection => 'ROOM CODE';

  @override
  String get roomLobbySessionNameHint => 'session name (optional)';

  @override
  String get roomLobbyStartGame => 'Start the game';

  @override
  String get roomLobbyWaitingPlayers => 'Waiting for players…';

  @override
  String get roomLobbyCopiedSnack => 'copied';

  @override
  String get gameTitle => 'Game';

  @override
  String get gameLiveLeaderboardTooltip => 'Live standings';

  @override
  String gameLoadError(String error) {
    return 'Error: $error';
  }

  @override
  String get gameNotFound => 'Game not found';

  @override
  String gameUnknownPhase(String phase) {
    return 'Unknown phase: $phase';
  }

  @override
  String get gameLeaveTitle => 'Leave?';

  @override
  String get gameLeaveBody => 'You will leave the game.';

  @override
  String get gameLeaveCancel => 'Cancel';

  @override
  String get gameLeaveConfirm => 'Leave';

  @override
  String get gameRoundEyebrow => 'ROUND';

  @override
  String gameCardsThisRound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get predictionLockButton => 'Lock in';

  @override
  String get predictionMyLockedTitle => 'Your call is locked in';

  @override
  String get predictionWaitingTitle => 'waiting…';

  @override
  String predictionTurnOf(String name) {
    return '$name\'s turn';
  }

  @override
  String get predictionBidOrderSection => 'BID ORDER';

  @override
  String get playingPastSection => 'PAST';

  @override
  String get playingPastEmpty => 'no tricks yet';

  @override
  String get playingMistakeButton => 'Mistake';

  @override
  String get playingConfirmButton => 'Confirm';

  @override
  String get playingProposalSection => 'PROPOSED WINNER';

  @override
  String playingProposalBy(String name) {
    return 'by $name';
  }

  @override
  String playingConfirmationCount(int count, int threshold) {
    return 'agreed $count / $threshold';
  }

  @override
  String get playingProposerWaiting => 'waiting for the others…';

  @override
  String get playingTrickEyebrow => 'TRICK';

  @override
  String get roundHeaderLeadsLabel => 'LEADS';

  @override
  String get roundHeaderDealerLabel => 'DEALER';

  @override
  String get scoreTallySection => 'SCORE';

  @override
  String get liveScoreboardTitle => 'LIVE STANDINGS';

  @override
  String get liveScoreboardChartTitle => 'SCORE CHART';

  @override
  String get shortStrawTitle => 'DRAWING LOTS';

  @override
  String get predictionRoundEyebrow => 'PREDICTION ROUND';

  @override
  String get validatingResultsSection => 'Results';

  @override
  String get validatingConfirmedChip => 'Confirmed';

  @override
  String get validatingConfirmButton => 'Confirm results';

  @override
  String get validatingChallengeTooltip => 'Dispute';

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
  String gameOverShareError(String error) {
    return 'Share error: $error';
  }

  @override
  String get gameOverSaveToPhotos => 'Save to Photos';

  @override
  String get gameOverSavedToPhotos => 'saved to your photos';

  @override
  String get gameOverSaveError => 'could not save · check Photos permission';

  @override
  String gameOverGenericError(String error) {
    return 'Error: $error';
  }

  @override
  String get gameOverBackToMenu => 'Back to menu';

  @override
  String get momentsAddPrompt => 'Add a moment';

  @override
  String get momentsAddSubtitle => 'a line to remember this game by';

  @override
  String get momentsHintExample =>
      'e.g. Caesar called 5, took 0. Lovely night.';

  @override
  String get momentsRoundChipAll => 'ALL';

  @override
  String get momentsSaveButton => 'Save';

  @override
  String momentsSaveError(String error) {
    return 'Error: $error';
  }

  @override
  String get momentsDeleteTitle => 'Delete moment?';

  @override
  String get momentsDeleteBody => 'It will be removed from the set.';

  @override
  String get momentsDeleteCancel => 'Cancel';

  @override
  String get momentsDeleteConfirm => 'Delete';

  @override
  String momentsDeleteError(String error) {
    return 'Delete error: $error';
  }

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardSubtitle => 'the scores at the table';

  @override
  String get leaderboardYouSection => '§ 01 · YOU';

  @override
  String get leaderboardTopSection => '§ 02 · LEADERS';

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
  String get lobbyParcaInPlaySection => 'IN PLAY';

  @override
  String get lobbyParcaResting => 'the parea is resting';

  @override
  String get lobbyFriendStatusWaiting => 'waiting';

  @override
  String get lobbyFriendStatusActive => 'playing';

  @override
  String get lobbyFriendJoinError => 'couldn\'t join';

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

  @override
  String pareaSharedGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games · 30d',
      one: '1 game · 30d',
    );
    return '$_temp0';
  }

  @override
  String get pareaTitle => 'Parea';

  @override
  String get pareaSubtitle => 'your company';

  @override
  String get pareaAddPrompt => 'Add a friend';

  @override
  String get pareaAddHint => 'username';

  @override
  String get pareaAddSubmit => 'Send';

  @override
  String pareaAddSuccess(String username) {
    return 'sent to @$username';
  }

  @override
  String get pareaAddErrorGeneric => 'error · try again';

  @override
  String get pareaInboxSection => 'INBOX';

  @override
  String get pareaInboxEmpty => 'no requests right now';

  @override
  String get pareaInboxWantsToBeFriends => 'wants to be friends';

  @override
  String get pareaInboxAccept => 'Accept';

  @override
  String get pareaInboxDecline => 'Decline';

  @override
  String get pareaYoursSection => 'YOURS';

  @override
  String get pareaYoursEmpty => 'add your first friend above';

  @override
  String get pareaSentSection => 'SENT';

  @override
  String get pareaSentEmpty => 'no requests pending';

  @override
  String get pareaSentLabel => 'awaiting confirmation';

  @override
  String get pareaSentCancel => 'Cancel';

  @override
  String pareaUnfriendTitle(String username) {
    return 'Remove @$username?';
  }

  @override
  String get pareaUnfriendBody =>
      'The friendship will be removed for both of you.';

  @override
  String get pareaUnfriendConfirm => 'Remove';

  @override
  String get pareaUnfriendCancel => 'Cancel';

  @override
  String get tournamentSection => 'TOURNAMENT';

  @override
  String get tournamentTopSection => 'TOP 10';

  @override
  String get tournamentYouSection => 'YOU';

  @override
  String get tournamentStatGames => 'GAMES';

  @override
  String get tournamentStatWins => 'WINS';

  @override
  String get tournamentStatAccuracy => 'ACCURACY';

  @override
  String get tournamentStatPoints => 'POINTS';

  @override
  String get tournamentEmptyTitle => 'empty page';

  @override
  String get tournamentEmptyBody =>
      'be the first one on the board.\none finished game is enough.';

  @override
  String get tournamentYouAreHere => 'your position';

  @override
  String get tournamentNoGamesTitle => 'no closed games yet';

  @override
  String get tournamentNoGamesBody => 'start one to enter the tournament.';

  @override
  String tournamentGamesPointsLabel(int games, int points) {
    return '$games games · $points pts';
  }
}
