import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/leaderboard_entry.dart';
import '../../providers/auth_providers.dart';
import '../../providers/leaderboard_providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/meraki_fonts.dart';
import '../../theme/meraki_motion.dart';
import '../../theme/meraki_tokens.dart';
import '../../widgets/virgil_card.dart';
import '../../widgets/virgil_chip.dart';

/// Tournament — leaderboard, restyled per the deck §05 SCREEN 04 pattern.
/// "A tournament, printed in the paper." Linen canvas, pure-typography
/// ranking (Fraunces oldstyle numerals, no badges/trophies), ochre on the
/// top three (the deck's "advancement" colour), coral for the signed-in
/// player. Rank-change ↑↓ chips that shipped earlier are preserved, just
/// restyled — myrtle / danger on a tinted pill.
class LeaderboardTab extends ConsumerStatefulWidget {
  const LeaderboardTab({super.key});

  @override
  ConsumerState<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends ConsumerState<LeaderboardTab> {
  /// Snapshot of `playerId → rank` from the previous visit. Frozen on the
  /// first non-null resolution so subsequent saves don't re-trigger
  /// computation against fresh-just-persisted data.
  Map<String, int>? _previousRanks;

  /// True after we've persisted the current ranks once for this mount.
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(leaderboardProvider);
    final lastSeenAsync = ref.watch(lastSeenLeaderboardRanksProvider);
    if (_previousRanks == null && lastSeenAsync.hasValue) {
      _previousRanks = Map.unmodifiable(lastSeenAsync.value!);
    }
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
      appBar: AppBar(title: Text(loc.leaderboardTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(leaderboardProvider.future),
        color: scheme.primary,
        backgroundColor: scheme.surface,
        child: async.when(
          loading: () => _Loading(color: scheme.primary),
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
  const _Loading({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 200),
        Center(child: CircularProgressIndicator(color: color)),
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
          'error',
          textAlign: TextAlign.center,
          style: GoogleFonts.fraunces(
            fontSize: 28,
            color: AppTheme.danger,
            height: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
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
  final Map<String, int> previousRanks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
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
        const TournamentHeader(),
        const SizedBox(height: AppTheme.space6),
        _SectionEyebrow('§ 01 · ${loc.tournamentYouSection}'),
        const SizedBox(height: AppTheme.space3),
        TournamentMyStatsCard(stats: myStats),
        const SizedBox(height: AppTheme.space6),
        _SectionEyebrow('§ 02 · ${loc.tournamentTopSection}'),
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
                  child: TournamentLeaderRow(
                    rank: i + 1,
                    stats: top[i],
                    isMe: top[i].playerId == myId,
                    previousRank: previousRanks[top[i].playerId],
                  )
                      .animate()
                      .fadeIn(
                        duration: MerakiMotion.normal,
                        delay: (i * 50).ms,
                        curve: MerakiMotion.entrance,
                      )
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        duration: MerakiMotion.normal,
                      ),
                ),
            ],
          ),
        if (myRank != null && myRank > 10) ...[
          const SizedBox(height: AppTheme.space5),
          _YourRankFooter(rank: myRank, stats: myStats!),
        ],
        const SizedBox(height: AppTheme.space6),
        const Center(
          child: Text(
            '— FIN —',
            style: TextStyle(
              fontFamily: MerakiFonts.geistMonoFamily,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.6,
              color: AppTheme.inkFaint,
            ),
          ),
        ),
      ],
    );
  }
}

/// Editorial header — Fraunces title + italic-Fraunces subtitle.
/// Replaces the kafeneio masthead.
class TournamentHeader extends StatelessWidget {
  const TournamentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '§ ${loc.tournamentSection}',
          style: tokens.eyebrow.copyWith(color: scheme.primary),
        ),
        const SizedBox(height: AppTheme.space3),
        Text(
          loc.leaderboardTitle,
          style: GoogleFonts.fraunces(
            fontSize: 44,
            fontWeight: FontWeight.w400,
            color: scheme.onSurface,
            letterSpacing: -0.6,
            height: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          loc.leaderboardSubtitle,
          style: GoogleFonts.fraunces(
            fontSize: 17,
            fontStyle: FontStyle.italic,
            color: AppTheme.inkSoft,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text, style: tokens.eyebrow.copyWith(color: scheme.primary)),
        const SizedBox(width: AppTheme.space2),
        const Expanded(
          child: Divider(thickness: 1, color: AppTheme.border, height: 1),
        ),
      ],
    );
  }
}

class TournamentMyStatsCard extends StatelessWidget {
  const TournamentMyStatsCard({super.key, required this.stats});

  final LeaderboardEntry? stats;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (stats == null) {
      return VirgilCard(
        variant: VirgilCardVariant.hero,
        padding: const EdgeInsets.all(AppTheme.space4),
        child: Row(
          children: [
            const Icon(
              Icons.bar_chart_outlined,
              color: AppTheme.inkFaint,
              size: 22,
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.tournamentNoGamesTitle,
                    style: GoogleFonts.fraunces(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.tournamentNoGamesBody,
                    style: GoogleFonts.fraunces(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.inkSoft,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final s = stats!;
    final accuracyPct =
        s.accuracy == null ? '—' : '${(s.accuracy! * 100).round()}%';

    return VirgilCard(
      variant: VirgilCardVariant.hero,
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Row(
        children: [
          _StatCell(label: loc.tournamentStatGames, value: '${s.gamesPlayed}'),
          _StatCell(
            label: loc.tournamentStatWins,
            value: '${s.wins}',
            highlight: true,
          ),
          _StatCell(label: loc.tournamentStatAccuracy, value: accuracyPct),
          _StatCell(label: loc.tournamentStatPoints, value: '${s.lifetimePoints}'),
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
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: highlight ? scheme.primary : scheme.onSurface,
              letterSpacing: -0.5,
              height: 1.0,
              fontFeatures: const [FontFeature.oldstyleFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: tokens.eyebrow.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

class TournamentLeaderRow extends StatelessWidget {
  const TournamentLeaderRow({
    super.key,
    required this.rank,
    required this.stats,
    required this.isMe,
    this.previousRank,
  });

  final int rank;
  final LeaderboardEntry stats;
  final bool isMe;
  final int? previousRank;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    // Top three get the deck's "ochre advancement" colour. Below that, ranks
    // sit on a faint ink — pure typography, no medals.
    final isTopThree = rank <= 3;
    final rankColor = isTopThree ? tokens.ochre : AppTheme.inkFaint;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: tokens.bone,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isMe ? scheme.primary : AppTheme.border,
          width: isMe ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank — Fraunces oldstyle numeral. The deck shows ranking as
          // pure typography; no medals, no badges.
          SizedBox(
            width: 36,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: rankColor,
                height: 1.0,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.oldstyleFigures()],
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
                        style: GoogleFonts.fraunces(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: isMe ? scheme.primary : scheme.onSurface,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: AppTheme.space2),
                      VirgilChip(
                        label: loc.leaderboardYouBadge,
                        variant: VirgilChipVariant.accent,
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
                  loc.tournamentGamesPointsLabel(
                    stats.gamesPlayed,
                    stats.lifetimePoints,
                  ),
                  style: const TextStyle(
                    fontFamily: MerakiFonts.geistMonoFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.4,
                    color: AppTheme.inkFaint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          // Wins block — Fraunces oldstyle.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.wins}',
                style: GoogleFonts.fraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: isTopThree ? tokens.ochre : scheme.primary,
                  height: 1.0,
                  letterSpacing: -0.4,
                  fontFeatures: const [FontFeature.oldstyleFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                loc.tournamentStatWins,
                style: tokens.eyebrow.copyWith(fontSize: 8),
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
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return VirgilCard(
      variant: VirgilCardVariant.hero,
      padding: const EdgeInsets.all(AppTheme.space5),
      child: Column(
        children: [
          Text(
            loc.tournamentEmptyTitle,
            style: GoogleFonts.fraunces(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: scheme.onSurface,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            loc.tournamentEmptyBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.inkSoft,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline ↑N / ↓N pill showing how a player's rank moved since the previous
/// visit. Myrtle for "moved up", danger for "moved down". Hidden when there's
/// no previous data or the rank hasn't moved.
class _RankDeltaChip extends StatelessWidget {
  const _RankDeltaChip({
    required this.previousRank,
    required this.currentRank,
  });

  final int previousRank;
  final int currentRank;

  static bool shouldShow(int? previousRank, int currentRank) {
    return previousRank != null && previousRank != currentRank;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final movedUp = currentRank < previousRank;
    final magnitude = (previousRank - currentRank).abs();
    final color = movedUp ? scheme.secondary : AppTheme.danger;
    final glyph = movedUp ? '↑' : '↓';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        '$glyph$magnitude',
        style: TextStyle(
          fontFamily: MerakiFonts.geistMonoFamily,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
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
    final loc = AppLocalizations.of(context)!;
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: scheme.primary, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark_outline, color: scheme.primary, size: 22),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.tournamentYouAreHere,
                  style: tokens.eyebrow,
                ),
                Text(
                  '#$rank',
                  style: GoogleFonts.fraunces(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: scheme.primary,
                    height: 1.0,
                    letterSpacing: -0.5,
                    fontFeatures: const [FontFeature.oldstyleFigures()],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${stats.wins} ${loc.tournamentStatWins}',
            style: tokens.eyebrow.copyWith(color: scheme.primary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
