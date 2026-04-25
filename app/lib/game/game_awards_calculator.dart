import '../models/estimation_round.dart';
import '../models/game_award.dart';

/// Computes celebratory awards from a finished estimation game.
///
/// Pure: no IO, no side-effects. Re-run on every summary view; cheap because
/// games have at most ~50 rounds × 4 players = 200 row inputs.
class GameAwardsCalculator {
  GameAwardsCalculator._();

  /// Minimum rounds-with-data per player before they're eligible for
  /// accuracy-based awards. Avoids declaring someone "Best Predictor" off a
  /// single lucky round in a 2-round demo game.
  static const _minRoundsForAccuracy = 3;

  /// Minimum streak length to award Hot Streak.
  static const _minStreak = 3;

  /// Returns the awards earned in this game. Order is presentation order.
  static List<GameAward> compute({
    required List<EstimationRound> rounds,
    required Map<String, String> usernames,
    required String winnerId,
    required Map<String, int> finalScores,
  }) {
    // Only rounds with both prediction and actual count toward accuracy/streak
    // calcs (defensive — finished games should have all of them).
    final completed = rounds
        .where((r) => r.prediction != null && r.actualTricks != null)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    if (completed.isEmpty) return const [];

    final byPlayer = <String, List<EstimationRound>>{};
    for (final r in completed) {
      byPlayer.putIfAbsent(r.playerId, () => []).add(r);
    }

    final awards = <GameAward>[];

    final cleanSweep = _cleanSweep(byPlayer, usernames);
    if (cleanSweep != null) awards.add(cleanSweep);

    final bestPredictor = _bestPredictor(
      byPlayer,
      usernames,
      excludePlayerId: cleanSweep?.playerId,
    );
    if (bestPredictor != null) awards.add(bestPredictor);

    final hotStreak = _hotStreak(byPlayer, usernames);
    if (hotStreak != null) awards.add(hotStreak);

    final upsetOrSlow = _upsetOrSlowStarter(
      completed: completed,
      byPlayer: byPlayer,
      usernames: usernames,
      winnerId: winnerId,
      finalScores: finalScores,
    );
    if (upsetOrSlow != null) awards.add(upsetOrSlow);

    final deadReckoner = _deadReckoner(byPlayer, usernames);
    if (deadReckoner != null) awards.add(deadReckoner);

    return awards;
  }

  // ── Award rules ────────────────────────────────────────────────────────────

  /// 🎯 Highest exact-hit rate (ties broken by raw hit count).
  static GameAward? _bestPredictor(
    Map<String, List<EstimationRound>> byPlayer,
    Map<String, String> usernames, {
    String? excludePlayerId,
  }) {
    String? bestId;
    double bestRate = -1;
    int bestHits = -1;

    byPlayer.forEach((pid, rs) {
      if (pid == excludePlayerId) return;
      if (rs.length < _minRoundsForAccuracy) return;
      final hits = rs.where((r) => r.prediction == r.actualTricks).length;
      final rate = hits / rs.length;
      // Skip pure 0% — that's Dead Reckoner territory.
      if (hits == 0) return;
      if (rate > bestRate || (rate == bestRate && hits > bestHits)) {
        bestRate = rate;
        bestHits = hits;
        bestId = pid;
      }
    });

    if (bestId == null) return null;
    return GameAward(
      id: 'best_predictor',
      emoji: '🎯',
      title: 'Καλύτερη Πρόβλεψη',
      description: '${(bestRate * 100).round()}% ακρίβεια ($bestHits hits)',
      playerId: bestId!,
      username: usernames[bestId!] ?? '???',
    );
  }

  /// 🔥 Longest consecutive exact-prediction streak (≥3).
  static GameAward? _hotStreak(
    Map<String, List<EstimationRound>> byPlayer,
    Map<String, String> usernames,
  ) {
    String? bestId;
    int bestStreak = 0;

    byPlayer.forEach((pid, rs) {
      // Iterate in round order, count consecutive hits.
      var current = 0;
      var maxRun = 0;
      for (final r in rs) {
        if (r.prediction == r.actualTricks) {
          current++;
          if (current > maxRun) maxRun = current;
        } else {
          current = 0;
        }
      }
      if (maxRun > bestStreak) {
        bestStreak = maxRun;
        bestId = pid;
      }
    });

    if (bestId == null || bestStreak < _minStreak) return null;
    return GameAward(
      id: 'hot_streak',
      emoji: '🔥',
      title: 'Hot Streak',
      description: '$bestStreak σερί σωστές προβλέψεις',
      playerId: bestId!,
      username: usernames[bestId!] ?? '???',
    );
  }

  /// 💀 Missed every single prediction (0% accuracy, ≥3 rounds played).
  static GameAward? _deadReckoner(
    Map<String, List<EstimationRound>> byPlayer,
    Map<String, String> usernames,
  ) {
    for (final entry in byPlayer.entries) {
      final rs = entry.value;
      if (rs.length < _minRoundsForAccuracy) continue;
      final hits = rs.where((r) => r.prediction == r.actualTricks).length;
      if (hits == 0) {
        return GameAward(
          id: 'dead_reckoner',
          emoji: '💀',
          title: 'Dead Reckoner',
          description: '0/${rs.length} σωστές προβλέψεις',
          playerId: entry.key,
          username: usernames[entry.key] ?? '???',
        );
      }
    }
    return null;
  }

  /// ⚡ 100% prediction accuracy across all rounds the player participated in,
  /// AND played at least half the game's rounds (filters out 1-round flukes).
  static GameAward? _cleanSweep(
    Map<String, List<EstimationRound>> byPlayer,
    Map<String, String> usernames,
  ) {
    if (byPlayer.isEmpty) return null;
    final maxRoundsPlayed =
        byPlayer.values.fold<int>(0, (m, rs) => rs.length > m ? rs.length : m);
    final threshold = (maxRoundsPlayed / 2).ceil();

    for (final entry in byPlayer.entries) {
      final rs = entry.value;
      if (rs.length < threshold || rs.length < _minRoundsForAccuracy) continue;
      final allHits =
          rs.every((r) => r.prediction == r.actualTricks);
      if (allHits) {
        return GameAward(
          id: 'clean_sweep',
          emoji: '⚡',
          title: 'Clean Sweep',
          description: '${rs.length}/${rs.length} τέλεια',
          playerId: entry.key,
          username: usernames[entry.key] ?? '???',
        );
      }
    }
    return null;
  }

  /// 😅 Biggest Upset — winner was last at the midpoint of the game.
  /// 🐢 Slow Starter — last after round 5, finished top-2 (but not winner).
  ///
  /// Mutually exclusive: Biggest Upset takes priority because it's stronger
  /// (same player can't satisfy both — Slow Starter excludes the winner).
  static GameAward? _upsetOrSlowStarter({
    required List<EstimationRound> completed,
    required Map<String, List<EstimationRound>> byPlayer,
    required Map<String, String> usernames,
    required String winnerId,
    required Map<String, int> finalScores,
  }) {
    final maxRound = completed.last.roundNumber;
    if (maxRound < 4) return null; // need a meaningful "mid-game"

    // Cumulative scores keyed by round_number.
    final cumulative = <int, Map<String, int>>{};
    final running = <String, int>{};
    for (var r = 1; r <= maxRound; r++) {
      final inRound = completed.where((e) => e.roundNumber == r);
      for (final entry in inRound) {
        running[entry.playerId] =
            (running[entry.playerId] ?? 0) + (entry.score ?? 0);
      }
      cumulative[r] = Map<String, int>.from(running);
    }

    String? lastAt(int round) {
      final scores = cumulative[round];
      if (scores == null || scores.isEmpty) return null;
      final entries = scores.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      return entries.first.key;
    }

    // Biggest Upset: winner was last at the midpoint round.
    final mid = (maxRound / 2).floor();
    if (mid >= 2) {
      final lastMid = lastAt(mid);
      if (lastMid == winnerId) {
        return GameAward(
          id: 'biggest_upset',
          emoji: '😅',
          title: 'Biggest Upset',
          description: 'Τελευταίος στον γύρο $mid, νίκησε στο τέλος',
          playerId: winnerId,
          username: usernames[winnerId] ?? '???',
        );
      }
    }

    // Slow Starter: last after round 5, finished top 2, not the winner.
    if (maxRound >= 5) {
      final lastAfter5 = lastAt(5);
      if (lastAfter5 != null && lastAfter5 != winnerId) {
        // Final rank check.
        final ranks = finalScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final rank = ranks.indexWhere((e) => e.key == lastAfter5);
        if (rank >= 0 && rank <= 1) {
          return GameAward(
            id: 'slow_starter',
            emoji: '🐢',
            title: 'Slow Starter',
            description: 'Τελευταίος μετά τον γύρο 5, τερμάτισε ${rank + 1}ος',
            playerId: lastAfter5,
            username: usernames[lastAfter5] ?? '???',
          );
        }
      }
    }

    return null;
  }
}
