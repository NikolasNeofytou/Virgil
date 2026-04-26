import '../models/estimation_round.dart';

/// Generates a short Greek narration of a finished estimation game — the
/// "Virgil narrates your night" voice on the game-over panel.
///
/// Pure: no IO, no state. Same inputs → same output (the [gameId] seeds
/// variant selection so a given game always reads the same way).
class GameNarrator {
  GameNarrator._();

  /// Returns a 2-3 sentence narration, or null if the game is too sparse
  /// to be worth narrating.
  static String? narrate({
    required String gameId,
    required List<EstimationRound> rounds,
    required Map<String, String> usernames,
    required Map<String, int> finalScores,
    required String winnerId,
  }) {
    if (finalScores.length < 2) return null;
    if (rounds.isEmpty) return null;
    final winnerName = usernames[winnerId];
    if (winnerName == null) return null;

    final shape = _GameShape.from(
      rounds: rounds,
      finalScores: finalScores,
      winnerId: winnerId,
    );
    if (shape == null) return null;

    final seed = _seedFromGameId(gameId);
    final opener = _opener(winnerName, shape.winnerScore, seed);
    final body = _body(shape, usernames);
    final closer = _closer(seed);

    return '$opener $body $closer';
  }

  // ── Sentence builders ──────────────────────────────────────────────────────

  static String _opener(String winner, int score, int seed) {
    final variants = [
      'Νικητής απόψε $winner, με $score πόντους.',
      '$winner σήκωσε τη δάφνη απόψε με $score πόντους.',
      'Με $score πόντους, $winner κρατάει τη βραδιά.',
    ];
    return variants[seed % variants.length];
  }

  /// Picks the body in priority order — first satisfied condition wins.
  /// Order matters: a close game beats a streak game beats a comeback,
  /// because that's the order of narrative striking-ness.
  static String _body(_GameShape shape, Map<String, String> usernames) {
    final runnerUp = usernames[shape.runnerUpId] ?? '???';

    if (shape.margin <= 3) {
      if (shape.margin == 0) {
        return 'Ισόπαλοι μέχρι τους τελευταίους γύρους — η νίκη κρίθηκε στο νήμα.';
      }
      final pts = shape.margin == 1 ? 'πόντου' : 'πόντων';
      return 'Διαφορά μόλις ${shape.margin} $pts από $runnerUp.';
    }

    if (shape.winnerStreak >= 3) {
      return 'Πρόβλεψε σωστά ${shape.winnerStreak} γύρους στη σειρά — αυτό έκανε τη διαφορά.';
    }

    if (shape.comebackFromBottomHalf) {
      return 'Από κάτω στη μέση του παιχνιδιού, αλλά ανέβηκε σταδιακά μέχρι την κορυφή.';
    }

    if (shape.wireToWire) {
      return 'Πρώτος από νωρίς και κανείς δεν πλησίασε.';
    }

    if (shape.margin >= 20) {
      return 'Άνετη νίκη με διαφορά ${shape.margin} πόντων.';
    }

    return 'Σταθερό παιχνίδι — η νίκη κρίθηκε στους τελευταίους γύρους.';
  }

  static String _closer(int seed) {
    const variants = [
      'Καλό ξενύχτι.',
      'Μέχρι την επόμενη.',
      'Καλή σας νύχτα.',
      'Τα ξαναλέμε.',
      'Φύγε κοιμήσου.',
    ];
    // Different bucket from opener so a single seed doesn't lock both.
    return variants[(seed ~/ 7) % variants.length];
  }

  /// Stable string hash — identical games always pick identical variants.
  static int _seedFromGameId(String gameId) {
    var hash = 0;
    for (final code in gameId.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }
}

/// Computed signals about how the game played out. Internal — exists only
/// to keep [GameNarrator._body] readable.
class _GameShape {
  _GameShape({
    required this.winnerScore,
    required this.runnerUpId,
    required this.margin,
    required this.winnerStreak,
    required this.comebackFromBottomHalf,
    required this.wireToWire,
  });

  final int winnerScore;
  final String runnerUpId;

  /// Winner's score minus runner-up's score. Always ≥ 0.
  final int margin;

  /// Longest run of consecutive exact predictions by the winner.
  final int winnerStreak;

  /// True if the winner sat in the bottom half of the rankings at the
  /// halfway-point round.
  final bool comebackFromBottomHalf;

  /// True if the winner held the #1 cumulative score from round ≤3 all the
  /// way to the end without ever being passed.
  final bool wireToWire;

  static _GameShape? from({
    required List<EstimationRound> rounds,
    required Map<String, int> finalScores,
    required String winnerId,
  }) {
    final sorted = finalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.length < 2) return null;
    final winnerScore = sorted.first.value;
    final runnerUp = sorted[1];
    final margin = winnerScore - runnerUp.value;

    final completed = rounds
        .where((r) => r.prediction != null && r.actualTricks != null)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    if (completed.isEmpty) return null;
    final maxRound =
        completed.map((r) => r.roundNumber).reduce((a, b) => a > b ? a : b);

    // Winner's longest exact-prediction streak.
    final winnerRounds =
        completed.where((r) => r.playerId == winnerId).toList();
    var streak = 0;
    var maxStreak = 0;
    for (final r in winnerRounds) {
      if (r.prediction == r.actualTricks) {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 0;
      }
    }

    // Cumulative scores after each round.
    final cumulative = <int, Map<String, int>>{};
    final running = <String, int>{};
    for (var r = 1; r <= maxRound; r++) {
      for (final entry in completed.where((e) => e.roundNumber == r)) {
        running[entry.playerId] =
            (running[entry.playerId] ?? 0) + (entry.score ?? 0);
      }
      cumulative[r] = Map<String, int>.from(running);
    }

    // Did the winner sit in the bottom half at the midpoint round?
    final midRound = (maxRound / 2).floor();
    var comeback = false;
    if (midRound >= 2) {
      final scoresAtMid = cumulative[midRound] ?? const <String, int>{};
      if (scoresAtMid.length >= finalScores.length) {
        final ranked = scoresAtMid.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final winnerRank = ranked.indexWhere((e) => e.key == winnerId);
        comeback = winnerRank >= (ranked.length / 2).floor();
      }
    }

    // Wire-to-wire: winner first took the lead by round ≤3 and never lost it.
    var firstLeadRound = -1;
    var wireToWire = false;
    for (var r = 1; r <= maxRound; r++) {
      final scores = cumulative[r] ?? const <String, int>{};
      if (scores.isEmpty) continue;
      final leader = (scores.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .first
          .key;
      if (firstLeadRound < 0 && leader == winnerId) {
        firstLeadRound = r;
      }
      if (firstLeadRound > 0 && leader != winnerId) {
        firstLeadRound = -1; // lost the lead, reset
      }
    }
    if (firstLeadRound > 0 && firstLeadRound <= 3) wireToWire = true;

    return _GameShape(
      winnerScore: winnerScore,
      runnerUpId: runnerUp.key,
      margin: margin,
      winnerStreak: maxStreak,
      comebackFromBottomHalf: comeback,
      wireToWire: wireToWire,
    );
  }
}
