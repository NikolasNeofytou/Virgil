import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/estimation_game.dart';
import '../../providers/estimation_providers.dart';
import '../../theme/app_background.dart';
import '../../theme/app_theme.dart';
import 'widgets/game_over_panel.dart';
import 'widgets/playing_phase.dart';
import 'widgets/prediction_phase.dart';
import 'widgets/submitting_phase.dart';
import 'widgets/validating_phase.dart';

/// Main game screen. Swaps body widget based on `game.phase`.
class EstimationGameScreen extends ConsumerWidget {
  const EstimationGameScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(estimationGameStreamProvider(gameId));

    return AppBackground(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _showExitDialog(context);
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Estimation'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _showExitDialog(context),
            ),
          ),
          body: SafeArea(
            child: Center(
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
                          style: TextStyle(color: AppTheme.textSecondary),
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
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseBody(EstimationGame game) {
    if (game.isFinished) return GameOverPanel(gameId: gameId);
    switch (game.phase) {
      case 'predicting':
        return PredictionPhase(gameId: gameId);
      case 'playing':
        return PlayingPhase(gameId: gameId);
      case 'submitting':
        return SubmittingPhase(gameId: gameId);
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
