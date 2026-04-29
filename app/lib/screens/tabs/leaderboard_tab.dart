import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/leaderboard_entry.dart';
import '../../providers/auth_providers.dart';
import '../../providers/leaderboard_providers.dart';
import '../../theme/app_theme.dart';

/// Cross-game leaderboard — paper masthead + your-stats receipt + Top 10 list
/// + your-rank footer. Pulls aggregates from the `estimation_stats` view via
/// [leaderboardProvider]; everything is reactive to the signed-in user.
///
/// Stateful so we can hold a snapshot of the previous-visit ranks for the
/// duration of this mount: we want delta chips to compute against ranks
/// from the *previous* visit, not the ranks we just persisted seconds ago.
/// Persistence happens once after the first paint via a post-frame callback.
class LeaderboardTab extends ConsumerStatefulWidget {
  const LeaderboardTab({super.key});

  @override
  ConsumerState<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends ConsumerState<LeaderboardTab> {
  /// Snapshot of `playerId → rank` from the previous visit. Empty until
  /// `lastSeenLeaderboardRanksProvider` resolves; after the first non-null
  /// resolution we freeze it here so subsequent saves don't re-trigger
  /// computation against fresh-just-persisted data.
  Map<String, int>? _previousRanks;

  /// True after we've persisted the current ranks once for this mount.
  /// Prevents re-saving on every rebuild (e.g. when myStatsProvider ticks).
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(leaderboardProvider);
    // Pull the previous-visit snapshot once. ref.watch is fine here — once
    // the FutureProvider resolves we cache into `_previousRanks` and never
    // overwrite, so chip deltas stay stable for this mount even if the
    // provider's value is later invalidated by a save.
    final lastSeenAsync = ref.watch(lastSeenLeaderboardRanksProvider);
    if (_previousRanks == null && lastSeenAsync.hasValue) {
      _previousRanks = Map.unmodifiable(lastSeenAsync.value!);
    }

    // Once both the leaderboard and the previous snapshot are loaded,
    // persist the new ranks for next time. One-shot per mount.
    if (!_saved && async.hasValue && _previousRanks != null) {
      _saved = true;
      final rows = async.value!;
      final newRanks = {
        for (var i = 0; i < rows.length; i++) rows[i].playerId: i + 1,
      };
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(lastSeenLeaderboardServiceProvider).save(newRanks);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Κατάταξη')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(leaderboardProvider.future),
        color: AppTheme.terra,
        backgroundColor: AppTheme.paper,
        child: async.when(
          loading: () => const _Loading(),
          error: (e, _) => _Error(message: '$e'),
          data: (rows) => _Body(
            rows: rows,
            previousRanks: _previousRanks ?? const {},
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 200),
        Center(child: CircularProgressIndicator(color: AppTheme.terra)),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.space5),
      children: [
        const SizedBox(height: 80),
        Text(
          'σφάλμα',
          textAlign: TextAlign.center,
          style: GoogleFonts.gloock(
            fontSize: 28,
            color: AppTheme.danger,
            height: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.kalam(
            fontSize: 13,
            color: AppTheme.inkSoft,
          ),
        ),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.rows, required this.previousRanks});
  final List<LeaderboardEntry> rows;

  /// Snapshot of `playerId → 1-indexed rank` from the previous visit.
  /// Empty for first-ever visits — `_LeaderRow` interprets a missing
  /// entry as "no chip" rather than as a delta.
  final Map<String, int> previousRanks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(currentUserIdProvider);
    final myStats = ref.watch(myStatsProvider);
    final myRank = ref.watch(myRankProvider);
    final top = rows.take(10).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space5,
        AppTheme.space5,
        AppTheme.space5,
        AppTheme.space7,
      ),
      children: [
        const _Masthead(),
        const SizedBox(height: AppTheme.space6),

        // ── Your stats receipt ──
        const _SectionLabel('§ 01 · ΟΙ ΣΤΑΤΙΣΤΙΚΕΣ ΣΟΥ · YOU'),
        const SizedBox(height: AppTheme.space3),
        _MyStatsCard(stats: myStats),

        const SizedBox(height: AppTheme.space6),

        // ── Top 10 ──
        const _SectionLabel('§ 02 · TOP 10 · LEADERS'),
        const SizedBox(height: AppTheme.space3),
        if (top.isEmpty)
          const _EmptyTop()
        else
          Column(
            children: [
              for (var i = 0; i < top.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == top.length - 1 ? 0 : AppTheme.space2,
                  ),
                  child: _LeaderRow(
                    rank: i + 1,
                    stats: top[i],
                    isMe: top[i].playerId == myId,
                    previousRank: previousRanks[top[i].playerId],
                  )
                      .animate()
                      .fadeIn(
                        duration: 280.ms,
                        delay: (i * 50).ms,
                        curve: Curves.easeOut,
                      )
                      .slideY(begin: 0.15, end: 0, duration: 280.ms),
                ),
            ],
          ),

        if (myRank != null && myRank > 10) ...[
          const SizedBox(height: AppTheme.space5),
          _YourRankFooter(rank: myRank, stats: myStats!),
        ],

        const SizedBox(height: AppTheme.space6),
        Center(
          child: Text(
            '— FIN —',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              letterSpacing: 3,
              color: AppTheme.inkFaint,
            ),
          ),
        ),
      ],
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'VOL. I · APR 2026 · KAFENEIO',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              letterSpacing: 3,
              color: AppTheme.inkSoft,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 1.5, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space4),
        Center(
          child: Text(
            'Κατάταξη',
            style: GoogleFonts.gloock(
              fontSize: 44,
              color: AppTheme.ink,
              letterSpacing: -0.6,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'τα σκορ του τραπεζιού',
            style: GoogleFonts.caveat(
              fontSize: 20,
              color: AppTheme.terra,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            color: AppTheme.terra,
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        Expanded(
          child: Container(height: 0.5, color: AppTheme.border),
        ),
      ],
    );
  }
}

class _MyStatsCard extends StatelessWidget {
  const _MyStatsCard({required this.stats});

  final LeaderboardEntry? stats;

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.space4),
        decoration: BoxDecoration(
          color: AppTheme.paper,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.bar_chart_outlined,
              color: AppTheme.inkFaint,
              size: 22,
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Text(
                'κανένα κλειστό παιχνίδι ακόμη.\nξεκίνα ένα για να μπεις στην κατάταξη.',
                style: GoogleFonts.kalam(
                  fontSize: 14,
                  color: AppTheme.inkSoft,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final s = stats!;
    final accuracyPct =
        s.accuracy == null ? '—' : '${(s.accuracy! * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          _StatCell(label: 'GAMES', value: '${s.gamesPlayed}'),
          _StatCell(label: 'WINS', value: '${s.wins}', highlight: true),
          _StatCell(label: 'ACCURACY', value: accuracyPct),
          _StatCell(label: 'POINTS', value: '${s.lifetimePoints}'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.gloock(
              fontSize: 26,
              color: highlight ? AppTheme.terra : AppTheme.ink,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: AppTheme.inkFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({
    required this.rank,
    required this.stats,
    required this.isMe,
    this.previousRank,
  });

  final int rank;
  final LeaderboardEntry stats;
  final bool isMe;

  /// 1-indexed rank from the previous visit, or null if this player wasn't
  /// in the snapshot we last persisted (new entrant, or first-ever visit).
  final int? previousRank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isMe
              ? AppTheme.terra.withValues(alpha: 0.55)
              : AppTheme.border,
          width: isMe ? 1.4 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          // Rank — Gloock numeral
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: GoogleFonts.gloock(
                fontSize: 22,
                color: rank == 1
                    ? AppTheme.terra
                    : rank <= 3
                        ? AppTheme.ink
                        : AppTheme.inkFaint,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        stats.username,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.caveat(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isMe ? AppTheme.terra : AppTheme.ink,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: AppTheme.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.terraMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          'ΕΣΥ',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            color: AppTheme.terra,
                          ),
                        ),
                      ),
                    ],
                    if (_RankDeltaChip.shouldShow(previousRank, rank)) ...[
                      const SizedBox(width: AppTheme.space2),
                      _RankDeltaChip(
                        previousRank: previousRank!,
                        currentRank: rank,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${stats.gamesPlayed} παιχνίδια · ${stats.lifetimePoints} π.',
                  style: GoogleFonts.kalam(
                    fontSize: 12,
                    color: AppTheme.inkFaint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          // Wins block — Gloock numeral
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.wins}',
                style: GoogleFonts.gloock(
                  fontSize: 24,
                  color: AppTheme.terra,
                  height: 1.0,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'WINS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: AppTheme.inkFaint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyTop extends StatelessWidget {
  const _EmptyTop();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space5),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Text(
            'κενό φύλλο',
            style: GoogleFonts.gloock(
              fontSize: 24,
              color: AppTheme.ink,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            'γίνε ο πρώτος που θα μπει στην κατάταξη.\nένα κλειστό παιχνίδι αρκεί.',
            textAlign: TextAlign.center,
            style: GoogleFonts.kalam(
              fontSize: 14,
              color: AppTheme.inkSoft,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline ↑N / ↓N pill showing how a player's rank moved since the
/// previous visit. Olive for "moved up", danger for "moved down". Hidden
/// when there's no previous data or the rank hasn't moved — silence is the
/// right signal in those cases.
class _RankDeltaChip extends StatelessWidget {
  const _RankDeltaChip({
    required this.previousRank,
    required this.currentRank,
  });

  final int previousRank;
  final int currentRank;

  /// Static gate: callers use this to decide whether to mount the chip at
  /// all (avoids constructing a hidden widget every paint).
  static bool shouldShow(int? previousRank, int currentRank) {
    return previousRank != null && previousRank != currentRank;
  }

  @override
  Widget build(BuildContext context) {
    // Lower rank number = better. Up arrow when moved up the leaderboard.
    final movedUp = currentRank < previousRank;
    final magnitude = (previousRank - currentRank).abs();
    final color = movedUp ? AppTheme.olive : AppTheme.danger;
    final glyph = movedUp ? '↑' : '↓';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        '$glyph$magnitude',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: color,
        ),
      ),
    );
  }
}

class _YourRankFooter extends StatelessWidget {
  const _YourRankFooter({required this.rank, required this.stats});

  final int rank;
  final LeaderboardEntry stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.terra, width: 1.2),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bookmark_outline,
            color: AppTheme.terra,
            size: 22,
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'η θέση σου',
                  style: GoogleFonts.kalam(
                    fontSize: 12,
                    color: AppTheme.inkFaint,
                  ),
                ),
                Text(
                  '#$rank',
                  style: GoogleFonts.gloock(
                    fontSize: 28,
                    color: AppTheme.terra,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${stats.wins} WINS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: AppTheme.terra,
            ),
          ),
        ],
      ),
    );
  }
}
