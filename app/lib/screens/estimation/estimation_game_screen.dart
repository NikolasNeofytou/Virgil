import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/estimation_game.dart';
import '../../providers/estimation_providers.dart';
import '../../theme/app_background.dart';
import '../../theme/app_theme.dart';
import 'widgets/game_over_panel.dart';
import 'widgets/live_scoreboard_sheet.dart';
import 'widgets/playing_phase.dart';
import 'widgets/prediction_phase.dart';
import 'widgets/short_straw_draw.dart';
import 'widgets/validating_phase.dart';

/// Main game screen. Swaps body widget based on `game.phase`.
class EstimationGameScreen extends ConsumerWidget {
  const EstimationGameScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(estimationGameStreamProvider(gameId));
    final players =
        ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull ?? [];
    final usernames =
        ref.watch(playerUsernamesProvider(gameId)).valueOrNull ?? {};
    final revealDismissed =
        ref.watch(dealerRevealDismissedProvider(gameId));

    return AppBackground(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _showExitDialog(context);
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Παιχνίδι'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _showExitDialog(context),
            ),
            actions: [
              IconButton(
                tooltip: 'Ζωντανή κατάταξη',
                icon: const Icon(Icons.leaderboard_outlined),
                onPressed: () =>
                    showLiveScoreboardSheet(context, gameId: gameId),
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: gameAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text(
                          'Σφάλμα: $e',
                          style: const TextStyle(color: AppTheme.danger),
                        ),
                      ),
                      data: (game) {
                        if (game == null) {
                          return const Center(
                            child: Text(
                              'Το παιχνίδι δεν βρέθηκε',
                              style:
                                  TextStyle(color: AppTheme.textSecondary),
                            ),
                          );
                        }
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: KeyedSubtree(
                            key: ValueKey(
                              '${game.phase}-${game.currentRound}-${game.status}',
                            ),
                            child: _buildPhaseBody(game),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!revealDismissed)
                  gameAsync.maybeWhen(
                    data: (game) {
                      if (game == null ||
                          game.currentRound != 1 ||
                          game.phase != 'predicting' ||
                          players.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final seats =
                          players.map((p) => p.seat).toList()..sort();
                      final dealerName = _seatName(
                        players,
                        usernames,
                        game.dealerSeat,
                      );
                      return Positioned.fill(
                        child: ShortStrawDraw(
                          seats: seats,
                          dealerSeat: game.dealerSeat,
                          dealerName: dealerName ?? '…',
                          onDone: () => ref
                              .read(dealerRevealDismissedProvider(gameId)
                                  .notifier,)
                              .state = true,
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _seatName(
    List<dynamic> players,
    Map<String, String> usernames,
    int seat,
  ) {
    final match = players.where((p) => p.seat == seat);
    if (match.isEmpty) return null;
    return usernames[match.first.playerId as String];
  }

  Widget _buildPhaseBody(EstimationGame game) {
    if (game.isFinished) return GameOverPanel(gameId: gameId);
    switch (game.phase) {
      case 'predicting':
        return PredictionPhase(gameId: gameId);
      case 'playing':
      // Legacy 'submitting' games still get routed through playing; actual
      // tricks are now tracked in estimation_tricks.
      case 'submitting':
        return PlayingPhase(gameId: gameId);
      case 'validating':
        return ValidatingPhase(gameId: gameId);
      default:
        return Center(child: Text('Άγνωστη φάση: ${game.phase}'));
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Αποχώρηση;'),
        content: const Text('Θα βγεις από το παιχνίδι.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Άκυρο'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Βγες'),
          ),
        ],
      ),
    );
  }
}
