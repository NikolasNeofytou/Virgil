import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../providers/game_history_provider.dart';
import '../../theme/app_background.dart';
import '../../theme/app_route.dart';
import '../../theme/app_theme.dart';
import 'game_summary_screen.dart';

/// Profile → "Τα παιχνίδια μου". Paper-and-ink list of every finished
/// estimation game the signed-in user took part in, newest first. Tapping
/// a row re-opens the game-over summary panel in historical mode.
class GameHistoryScreen extends ConsumerWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pastEstimationGamesProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Τα παιχνίδια μου')),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(pastEstimationGamesProvider.future),
            color: AppTheme.terra,
            backgroundColor: AppTheme.paper,
            child: async.when(
              loading: () => const _Loading(),
              error: (e, _) => _Error(message: '$e'),
              data: (games) =>
                  games.isEmpty ? const _Empty() : _List(games: games),
            ),
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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.space5),
      children: [
        const SizedBox(height: 80),
        Text(
          'κενό φύλλο',
          textAlign: TextAlign.center,
          style: GoogleFonts.gloock(
            fontSize: 28,
            color: AppTheme.ink,
            height: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        Text(
          'δεν έχεις τελειώσει κανένα παιχνίδι ακόμη.\n'
          'το πρώτο σου σύνολο θα φανεί εδώ.',
          textAlign: TextAlign.center,
          style: GoogleFonts.kalam(
            fontSize: 14,
            color: AppTheme.inkSoft,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.games});

  final List<PastGameSummary> games;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space5,
        AppTheme.space5,
        AppTheme.space5,
        AppTheme.space7,
      ),
      itemCount: games.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.space2),
      itemBuilder: (context, i) {
        final g = games[i];
        return _HistoryRow(summary: g)
            .animate()
            .fadeIn(
              duration: 280.ms,
              delay: (i * 40).ms,
              curve: Curves.easeOut,
            )
            .slideY(begin: 0.15, end: 0, duration: 280.ms);
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.summary});

  final PastGameSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final title = (s.sessionName?.trim().isNotEmpty ?? false)
        ? s.sessionName!
        : 'παιχνίδι ${DateFormat('d MMM').format(s.sortDate.toLocal())}';
    final dateLabel =
        DateFormat('d MMM yyyy').format(s.sortDate.toLocal()).toUpperCase();
    final winnerLabel = s.isWin
        ? 'νίκη'
        : 'νικητής · ${s.winnerUsername}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        splashColor: AppTheme.terraMuted,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).push<void>(
            AppRoute.build((_) => GameSummaryScreen(gameId: s.gameId)),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space4,
            vertical: AppTheme.space3,
          ),
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: s.isWin
                  ? AppTheme.terra.withValues(alpha: 0.55)
                  : AppTheme.border,
              width: s.isWin ? 1.2 : 1,
            ),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.gloock(
                        fontSize: 20,
                        color: AppTheme.ink,
                        height: 1.0,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateLabel · ${s.playerCount} ΠΑΙΚΤΕΣ',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: AppTheme.inkFaint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      winnerLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.caveat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: s.isWin ? AppTheme.terra : AppTheme.inkSoft,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${s.myScore}',
                    style: GoogleFonts.gloock(
                      fontSize: 28,
                      color: s.isWin ? AppTheme.terra : AppTheme.ink,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${s.myRank}/${s.playerCount}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: AppTheme.inkFaint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
