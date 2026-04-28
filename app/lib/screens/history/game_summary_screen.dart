import 'package:flutter/material.dart';

import '../../theme/app_background.dart';
import '../estimation/widgets/game_over_panel.dart';

/// Standalone screen wrapping [GameOverPanel] in `isHistorical: true` mode.
/// Reached from the Profile → "Τα παιχνίδια μου" history list — lets the
/// user revisit a finished game's standings, narration, awards, and
/// re-share the PNG without firing confetti or offering rematch.
class GameSummaryScreen extends StatelessWidget {
  const GameSummaryScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Σύνοψη')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: GameOverPanel(gameId: gameId, isHistorical: true),
            ),
          ),
        ),
      ),
    );
  }
}
