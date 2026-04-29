import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/estimation_round.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../services/estimation_service.dart';
import '../../../theme/app_background.dart';
import '../../../theme/app_theme.dart';
import 'round_header.dart';
import '../../../theme/meraki_fonts.dart';

class ValidatingPhase extends ConsumerStatefulWidget {
  const ValidatingPhase({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<ValidatingPhase> createState() => _ValidatingPhaseState();
}

class _ValidatingPhaseState extends ConsumerState<ValidatingPhase> {
  bool _confirming = false;
  bool _disputing = false;
  bool _finalizing = false;
  final _service = EstimationService();

  Future<void> _confirm(int roundNumber) async {
    setState(() => _confirming = true);
    try {
      await _service.confirmRound(
        gameId: widget.gameId,
        roundNumber: roundNumber,
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _tryFinalize() async {
    if (_finalizing) return;
    _finalizing = true;
    try {
      final game =
          ref.read(estimationGameStreamProvider(widget.gameId)).valueOrNull;
      if (game == null || game.phase != 'validating') return;
      await _finalize(game.currentRound);
    } catch (_) {
      // Ignore races.
    } finally {
      _finalizing = false;
    }
  }

  Future<void> _dispute(int roundNumber, String playerId) async {
    setState(() => _disputing = true);
    try {
      await _service.disputeResult(
        gameId: widget.gameId,
        roundNumber: roundNumber,
        disputedPlayerId: playerId,
      );
    } finally {
      if (mounted) setState(() => _disputing = false);
    }
  }

  Future<void> _finalize(int roundNumber) async {
    final game =
        ref.read(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final entries = ref.read(activeRoundEntriesProvider(widget.gameId));
    if (game == null || entries.isEmpty) return;

    final rawEntries = entries
        .map((e) => {
              'id': e.id,
              'player_id': e.playerId,
              'prediction': e.prediction,
              'actual_tricks': e.actualTricks,
            },)
        .toList();

    await _service.finalizeRound(
      gameId: widget.gameId,
      currentRound: game.currentRound,
      totalRounds: game.totalRounds,
      maxCards: game.maxCards,
      playerCount: game.playerCount,
      dealerSeat: game.dealerSeat,
      roundStarterSeat: game.roundStarterSeat ?? game.dealerSeat,
      entries: rawEntries,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      validationCountProvider(widget.gameId),
      (prev, next) {
        final threshold =
            ref.read(validationThresholdProvider(widget.gameId));
        if (next >= threshold && (prev ?? 0) < threshold) {
          _tryFinalize();
        }
      },
    );

    final game =
        ref.watch(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final entries = ref.watch(activeRoundEntriesProvider(widget.gameId));
    final players = ref
            .watch(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    final usernames =
        ref.watch(playerUsernamesProvider(widget.gameId)).valueOrNull ?? {};
    final userId = ref.watch(currentUserIdProvider);
    final validationCount = ref.watch(validationCountProvider(widget.gameId));
    final threshold = ref.watch(validationThresholdProvider(widget.gameId));
    final myEntry = ref.watch(myRoundEntryProvider(widget.gameId));

    if (game == null) return const Center(child: CircularProgressIndicator());

    final iConfirmed = myEntry?.validated ?? false;

    final dealerPlayer = players.where((p) => p.seat == game.dealerSeat);
    final dealerName = dealerPlayer.isNotEmpty
        ? usernames[dealerPlayer.first.playerId]
        : null;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoundHeader(
            currentRound: game.currentRound,
            totalRounds: game.totalRounds,
            cardsThisRound: game.cardsThisRound,
            dealerName: dealerName,
          ),
          const SizedBox(height: AppTheme.space4),

          // Validation counter
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space4,
              vertical: AppTheme.space3,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.how_to_vote_outlined,
                  color: AppTheme.gold,
                  size: 18,
                ),
                const SizedBox(width: AppTheme.space2),
                const Expanded(
                  child: Text(
                    'Επιβεβαίωση',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '$validationCount / $threshold',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space5),

          const AppSectionLabel('Αποτελέσματα'),
          const SizedBox(height: AppTheme.space2),

          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (_, i) {
                final player = players[i];
                final pid = player.playerId;
                final name = usernames[pid] ?? '…';
                final isMe = pid == userId;
                final entry = _findEntry(entries, pid);
                if (entry == null) return const SizedBox.shrink();

                final predicted = entry.prediction ?? 0;
                final actual = entry.actualTricks ?? 0;
                final score =
                    EstimationRound.calculateScore(predicted, actual);
                final isBonus = predicted == actual;

                return _ResultRow(
                  key: ValueKey('reveal-${game.currentRound}-$pid'),
                  username: name,
                  isMe: isMe,
                  predicted: predicted,
                  actual: actual,
                  score: score,
                  isBonus: isBonus,
                  validated: entry.validated,
                  revealDelay: Duration(milliseconds: i * 180),
                  onDispute: !isMe && !_disputing
                      ? () => _dispute(game.currentRound, pid)
                      : null,
                );
              },
            ),
          ),

          const SizedBox(height: AppTheme.space3),

          if (iConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                  SizedBox(width: AppTheme.space2),
                  Text(
                    'Επιβεβαιώθηκε',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton(
              onPressed:
                  _confirming ? null : () => _confirm(game.currentRound),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
              child: _confirming
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Επιβεβαίωση αποτελεσμάτων'),
            ),
        ],
      ),
    );
  }

  EstimationRound? _findEntry(List<EstimationRound> entries, String playerId) {
    try {
      return entries.firstWhere((e) => e.playerId == playerId);
    } catch (_) {
      return null;
    }
  }
}

/// Reveal row — prediction vs actual as Gloock numerals, terracotta
/// underline beneath, Caveat "★ match · +N" floater when bonus.
///
/// Animation timeline (driven by a single 1100ms controller that starts
/// after [revealDelay]):
///
///   0.00 → 0.25  prediction numeral fades + slides in
///   0.25 → 0.55  actual numeral stamps in (2.4× → 1.0× overshoot)
///   0.45 → 0.75  underline sweeps out from the center of each numeral
///   0.65 → 1.00  "★ +N" floater slides up + fades in (bonus rows only)
class _ResultRow extends StatefulWidget {
  const _ResultRow({
    super.key,
    required this.username,
    required this.isMe,
    required this.predicted,
    required this.actual,
    required this.score,
    required this.isBonus,
    required this.validated,
    required this.revealDelay,
    this.onDispute,
  });

  final String username;
  final bool isMe;
  final int predicted;
  final int actual;
  final int score;
  final bool isBonus;
  final bool validated;
  final Duration revealDelay;
  final VoidCallback? onDispute;

  @override
  State<_ResultRow> createState() => _ResultRowState();
}

class _ResultRowState extends State<_ResultRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    Future<void>.delayed(widget.revealDelay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: widget.isMe
              ? AppTheme.terra.withValues(alpha: 0.55)
              : AppTheme.border,
          width: widget.isMe ? 1.2 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          // Phase timings inside the 0..1 controller.
          final predT = (t / 0.25).clamp(0.0, 1.0);
          final actT = ((t - 0.25) / 0.30).clamp(0.0, 1.0);
          final underT = ((t - 0.45) / 0.30).clamp(0.0, 1.0);
          final floatT = ((t - 0.65) / 0.35).clamp(0.0, 1.0);

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.username,
                        style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: widget.isMe
                              ? AppTheme.terra
                              : AppTheme.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.terraMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'ΕΣΥ',
                          style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            color: AppTheme.terra,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _RevealNumeral(
                value: widget.predicted,
                highlight: false,
                opacity: predT,
                scale: 0.6 + 0.4 * Curves.easeOutCubic.transform(predT),
                underlineT: underT,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Opacity(
                  opacity: predT,
                  child: Text(
                    '→',
                    style: GoogleFonts.fraunces(
                      fontSize: 18,
                      color: AppTheme.inkFaint,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              _RevealNumeral(
                value: widget.actual,
                highlight: widget.isBonus,
                opacity: actT,
                // Stamp overshoot 2.4 → 1.0
                scale: actT == 0 ? 0.0 : 2.4 - 1.4 * Curves.easeOutCubic.transform(actT),
                underlineT: underT,
              ),
              const SizedBox(width: AppTheme.space2),
              SizedBox(
                width: 56,
                child: widget.isBonus
                    ? Transform.translate(
                        offset: Offset(0, -6 * (1 - floatT)),
                        child: Opacity(
                          opacity: floatT,
                          child: Text(
                            '★ +${widget.score}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.olive,
                            ),
                          ),
                        ),
                      )
                    : Opacity(
                        opacity: underT,
                        child: Text(
                          '+${widget.score}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.inkSoft,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: AppTheme.space2),
              SizedBox(
                width: 24,
                child: widget.validated
                    ? const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.olive,
                      )
                    : widget.onDispute != null
                        ? IconButton(
                            onPressed: widget.onDispute,
                            icon: const Icon(Icons.flag_outlined),
                            iconSize: 14,
                            color: AppTheme.inkFaint,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Αμφισβήτηση',
                          )
                        : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Single Gloock numeral with a hairline underline — the "reveal" mark.
/// Pass animation params so the parent [_ResultRow] can drive the reveal.
class _RevealNumeral extends StatelessWidget {
  const _RevealNumeral({
    required this.value,
    required this.highlight,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.underlineT = 1.0,
  });

  final int value;
  final bool highlight;
  final double opacity;
  final double scale;
  final double underlineT;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppTheme.olive : AppTheme.ink;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Text(
              '$value',
              style: GoogleFonts.fraunces(
                fontSize: 26,
                color: color,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Underline sweeps out from the center.
        Container(
          height: 1,
          width: 20 * Curves.easeOutCubic.transform(underlineT.clamp(0.0, 1.0)),
          color: highlight
              ? AppTheme.olive.withValues(alpha: 0.6)
              : AppTheme.terra.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
