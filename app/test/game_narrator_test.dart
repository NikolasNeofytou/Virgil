import 'package:flutter_test/flutter_test.dart';
import 'package:tichu_cyprus/game/game_narrator.dart';
import 'package:tichu_cyprus/models/estimation_round.dart';

EstimationRound _r({
  required String playerId,
  required int round,
  required int prediction,
  required int actual,
}) {
  return EstimationRound(
    id: 'r-$playerId-$round',
    gameId: 'g',
    playerId: playerId,
    roundNumber: round,
    cardsThisRound: 5,
    prediction: prediction,
    actualTricks: actual,
    score: EstimationRound.calculateScore(prediction, actual),
    validated: true,
  );
}

void main() {
  group('GameNarrator.narrate', () {
    const usernames = {'a': 'Costas', 'b': 'Andrea', 'c': 'Maria'};

    test('returns null with fewer than 2 players', () {
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: [_r(playerId: 'a', round: 1, prediction: 1, actual: 1)],
        usernames: const {'a': 'Costas'},
        finalScores: const {'a': 11},
        winnerId: 'a',
      );
      expect(n, isNull);
    });

    test('returns null with no rounds', () {
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: const [],
        usernames: usernames,
        finalScores: const {'a': 0, 'b': 0},
        winnerId: 'a',
      );
      expect(n, isNull);
    });

    test('returns null when winner is missing from usernames', () {
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: [_r(playerId: 'a', round: 1, prediction: 1, actual: 1)],
        usernames: const {'b': 'Andrea'},
        finalScores: const {'a': 11, 'b': 0},
        winnerId: 'a',
      );
      expect(n, isNull);
    });

    test('close-margin body fires when winner edges runner-up by ≤3', () {
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: [
          _r(playerId: 'a', round: 1, prediction: 1, actual: 1),
          _r(playerId: 'b', round: 1, prediction: 0, actual: 1),
        ],
        usernames: usernames,
        finalScores: const {'a': 30, 'b': 28},
        winnerId: 'a',
      );
      expect(n, isNotNull);
      expect(n, contains('Διαφορά μόλις 2 πόντων από Andrea'));
    });

    test('singular grammar — 1 πόντου, not 1 πόντων', () {
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: [
          _r(playerId: 'a', round: 1, prediction: 1, actual: 1),
          _r(playerId: 'b', round: 1, prediction: 0, actual: 1),
        ],
        usernames: usernames,
        finalScores: const {'a': 30, 'b': 29},
        winnerId: 'a',
      );
      expect(n, contains('1 πόντου'));
      expect(n, isNot(contains('1 πόντων')));
    });

    test('tied scores get the ισόπαλοι body', () {
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: [
          _r(playerId: 'a', round: 1, prediction: 1, actual: 1),
          _r(playerId: 'b', round: 1, prediction: 1, actual: 1),
        ],
        usernames: usernames,
        finalScores: const {'a': 30, 'b': 30},
        winnerId: 'a',
      );
      expect(n, contains('Ισόπαλοι'));
    });

    test('streak body fires when winner has 3+ exact predictions in a row', () {
      // Margin of 10 keeps us out of the close-margin branch.
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: [
          for (var i = 1; i <= 5; i++)
            _r(playerId: 'a', round: i, prediction: 1, actual: 1),
          for (var i = 1; i <= 5; i++)
            _r(playerId: 'b', round: i, prediction: 0, actual: 1),
        ],
        usernames: usernames,
        finalScores: const {'a': 55, 'b': 5},
        winnerId: 'a',
      );
      expect(n, contains('5 γύρους στη σειρά'));
    });

    test('comeback body fires when winner was bottom-half at midpoint', () {
      // 4-round game, winner is dead last after round 2 then wins.
      final rounds = <EstimationRound>[
        // Rounds 1-2: B and C lead
        _r(playerId: 'a', round: 1, prediction: 0, actual: 2), // 2 pts
        _r(playerId: 'b', round: 1, prediction: 2, actual: 2), // 12 pts
        _r(playerId: 'c', round: 1, prediction: 2, actual: 2), // 12 pts
        _r(playerId: 'a', round: 2, prediction: 0, actual: 1), // 1 pt
        _r(playerId: 'b', round: 2, prediction: 1, actual: 1), // 11 pts
        _r(playerId: 'c', round: 2, prediction: 1, actual: 1), // 11 pts
        // Rounds 3-4: A explodes
        _r(playerId: 'a', round: 3, prediction: 4, actual: 4), // 14 pts
        _r(playerId: 'b', round: 3, prediction: 0, actual: 0), // 10 pts
        _r(playerId: 'c', round: 3, prediction: 0, actual: 1), // 1 pt
        _r(playerId: 'a', round: 4, prediction: 5, actual: 5), // 15 pts
        _r(playerId: 'b', round: 4, prediction: 0, actual: 1), // 1 pt
        _r(playerId: 'c', round: 4, prediction: 0, actual: 0), // 10 pts
      ];
      // Final: a = 32, b = 34, c = 34 — but we'll force a as winner with
      // larger final score for the test by giving them an extra:
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: rounds,
        usernames: usernames,
        finalScores: const {'a': 50, 'b': 34, 'c': 34},
        winnerId: 'a',
      );
      expect(n, contains('Από κάτω στη μέση'));
    });

    test('wire-to-wire body fires when winner leads from round ≤3', () {
      // A hits sometimes, misses sometimes (max streak < 3). A always leads.
      // Margin keeps us out of close-margin (≤3) and blowout (≥20).
      final rounds = <EstimationRound>[
        // R1: A:+11 (hit, s=1)   B:+1   → A:11 B:1
        _r(playerId: 'a', round: 1, prediction: 1, actual: 1),
        _r(playerId: 'b', round: 1, prediction: 0, actual: 1),
        // R2: A:+1  (miss, s=0)  B:+10  → A:12 B:11
        _r(playerId: 'a', round: 2, prediction: 2, actual: 1),
        _r(playerId: 'b', round: 2, prediction: 0, actual: 0),
        // R3: A:+11 (hit, s=1)   B:+1   → A:23 B:12
        _r(playerId: 'a', round: 3, prediction: 1, actual: 1),
        _r(playerId: 'b', round: 3, prediction: 0, actual: 1),
        // R4: A:+1  (miss, s=0)  B:+10  → A:24 B:22
        _r(playerId: 'a', round: 4, prediction: 2, actual: 1),
        _r(playerId: 'b', round: 4, prediction: 0, actual: 0),
        // R5: A:+15 (hit, s=1)   B:+0   → A:39 B:22
        _r(playerId: 'a', round: 5, prediction: 5, actual: 5),
        _r(playerId: 'b', round: 5, prediction: 5, actual: 0),
        // R6: A:+1  (miss)       B:+0   → A:40 B:22
        _r(playerId: 'a', round: 6, prediction: 0, actual: 1),
        _r(playerId: 'b', round: 6, prediction: 5, actual: 0),
      ];
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: rounds,
        usernames: usernames,
        finalScores: const {'a': 40, 'b': 22},
        winnerId: 'a',
      );
      // Margin 18 — between close (≤3) and blowout (≥20). Streak max = 1.
      // A leads from round 1 throughout → wire-to-wire.
      expect(n, contains('Πρώτος από νωρίς'));
    });

    test('blowout body fires when none of the higher-priority cases apply', () {
      // 8 rounds. A loses the lead in R2-R3 (kills wire-to-wire), retakes at
      // R4 (kills comeback at midpoint=4 since A leads then), max streak is 2,
      // final margin ≥ 20.
      final rounds = <EstimationRound>[
        // R1: A:+11 (hit, s=1) B:+1   → A:11 B:1   leader=A
        _r(playerId: 'a', round: 1, prediction: 1, actual: 1),
        _r(playerId: 'b', round: 1, prediction: 0, actual: 1),
        // R2: A:+1  (miss, s=0) B:+11 (hit) → A:12 B:12  tied (leader can flip)
        _r(playerId: 'a', round: 2, prediction: 0, actual: 1),
        _r(playerId: 'b', round: 2, prediction: 1, actual: 1),
        // R3: A:+1  (miss)      B:+10 (hit) → A:13 B:22  leader=B (kills w2w)
        _r(playerId: 'a', round: 3, prediction: 2, actual: 1),
        _r(playerId: 'b', round: 3, prediction: 0, actual: 0),
        // R4: A:+15 (hit, s=1)  B:+1  (miss) → A:28 B:23  leader=A again
        _r(playerId: 'a', round: 4, prediction: 5, actual: 5),
        _r(playerId: 'b', round: 4, prediction: 0, actual: 1),
        // Midpoint = round 4 → A in top half → comeback false.
        // R5: A:+10 (hit, s=2)  B:+0  (miss) → A:38 B:23
        _r(playerId: 'a', round: 5, prediction: 0, actual: 0),
        _r(playerId: 'b', round: 5, prediction: 5, actual: 0),
        // R6: A:+4  (miss, s=0) B:+0          → A:42 B:23
        _r(playerId: 'a', round: 6, prediction: 5, actual: 4),
        _r(playerId: 'b', round: 6, prediction: 5, actual: 0),
        // R7: A:+10 (hit, s=1)  B:+0          → A:52 B:23
        _r(playerId: 'a', round: 7, prediction: 0, actual: 0),
        _r(playerId: 'b', round: 7, prediction: 5, actual: 0),
        // R8: A:+3  (miss)      B:+0          → A:55 B:23
        _r(playerId: 'a', round: 8, prediction: 4, actual: 3),
        _r(playerId: 'b', round: 8, prediction: 5, actual: 0),
      ];
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: rounds,
        usernames: usernames,
        finalScores: const {'a': 55, 'b': 23},
        winnerId: 'a',
      );
      // Margin 32. Max streak = 2. Not wire-to-wire (B led at R3).
      // A leader at midpoint (R4) → not comeback. → falls through to blowout.
      expect(n, contains('Άνετη νίκη με διαφορά'));
    });

    test('determinism — same gameId always produces the same narration', () {
      final inputs = {
        'gameId': 'stable-id-123',
        'rounds': [
          _r(playerId: 'a', round: 1, prediction: 1, actual: 1),
          _r(playerId: 'b', round: 1, prediction: 0, actual: 1),
        ],
        'finalScores': const {'a': 30, 'b': 28},
      };
      final first = GameNarrator.narrate(
        gameId: inputs['gameId']! as String,
        rounds: inputs['rounds']! as List<EstimationRound>,
        usernames: usernames,
        finalScores: inputs['finalScores']! as Map<String, int>,
        winnerId: 'a',
      );
      final second = GameNarrator.narrate(
        gameId: inputs['gameId']! as String,
        rounds: inputs['rounds']! as List<EstimationRound>,
        usernames: usernames,
        finalScores: inputs['finalScores']! as Map<String, int>,
        winnerId: 'a',
      );
      expect(first, equals(second));
    });

    test('different gameIds can pick different opener/closer variants', () {
      final aOuts = <String>{};
      for (final id in [
        'game-a',
        'game-b',
        'game-c',
        'game-d',
        'game-e',
        'game-f',
      ]) {
        final n = GameNarrator.narrate(
          gameId: id,
          rounds: [
            _r(playerId: 'a', round: 1, prediction: 1, actual: 1),
            _r(playerId: 'b', round: 1, prediction: 0, actual: 1),
          ],
          usernames: usernames,
          finalScores: const {'a': 30, 'b': 28},
          winnerId: 'a',
        );
        aOuts.add(n!);
      }
      // Across 6 different ids we expect at least 2 distinct strings,
      // proving the seed is actually steering variant choice.
      expect(aOuts.length, greaterThan(1));
    });

    test('every narration ends with a closer line', () {
      final n = GameNarrator.narrate(
        gameId: 'g',
        rounds: [
          _r(playerId: 'a', round: 1, prediction: 1, actual: 1),
          _r(playerId: 'b', round: 1, prediction: 0, actual: 1),
        ],
        usernames: usernames,
        finalScores: const {'a': 30, 'b': 28},
        winnerId: 'a',
      );
      const closers = [
        'Καλό ξενύχτι.',
        'Μέχρι την επόμενη.',
        'Καλή σας νύχτα.',
        'Τα ξαναλέμε.',
        'Φύγε κοιμήσου.',
      ];
      expect(closers.any((c) => n!.endsWith(c)), isTrue);
    });
  });
}
