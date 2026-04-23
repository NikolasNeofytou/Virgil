import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../theme/app_theme.dart';

/// Running totals for every seat. A compact kafeneio-receipt strip showing
/// `@username ········· N` for each player, leader first. Meant to sit just
/// below the `RoundHeader` during the predicting and playing phases so the
/// table always knows the state of play.
class ScoreTally extends ConsumerWidget {
  const ScoreTally({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players =
        ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull ?? [];
    final usernames =
        ref.watch(playerUsernamesProvider(gameId)).valueOrNull ?? {};
    final userId = ref.watch(currentUserIdProvider);

    if (players.isEmpty) return const SizedBox.shrink();

    // Sort descending by total so the leader is always at the top.
    final sorted = [...players]
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space4,
        AppTheme.space3,
        AppTheme.space4,
        AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ΣΚΟΡ · SCORE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              letterSpacing: 3,
              color: AppTheme.terra,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          for (var i = 0; i < sorted.length; i++)
            Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 0 : 2,
              ),
              child: _TallyRow(
                name: usernames[sorted[i].playerId] ?? '…',
                score: sorted[i].totalScore,
                isMe: sorted[i].playerId == userId,
                isLeader: i == 0 && sorted[i].totalScore > 0,
              ),
            ),
        ],
      ),
    );
  }
}

/// Per-seat row. Tweens the score integer when it changes and floats a
/// Caveat "+N" stamp above the new value for ~900ms, matching the design's
/// SceneScoreTick motion.
class _TallyRow extends StatefulWidget {
  const _TallyRow({
    required this.name,
    required this.score,
    required this.isMe,
    required this.isLeader,
  });

  final String name;
  final int score;
  final bool isMe;
  final bool isLeader;

  @override
  State<_TallyRow> createState() => _TallyRowState();
}

class _TallyRowState extends State<_TallyRow>
    with SingleTickerProviderStateMixin {
  late int _displayedScore = widget.score;
  int? _pendingFloater; // +N to float when we see a delta

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant _TallyRow old) {
    super.didUpdateWidget(old);
    if (widget.score != old.score) {
      final delta = widget.score - old.score;
      _pendingFloater = delta;
      _ctrl.forward(from: 0).then((_) {
        if (mounted) setState(() => _pendingFloater = null);
      });
      _tweenScore(from: old.score, to: widget.score);
    }
  }

  Future<void> _tweenScore({required int from, required int to}) async {
    const steps = 20;
    for (var i = 1; i <= steps; i++) {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 25));
      setState(() {
        _displayedScore = from + ((to - from) * i / steps).round();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameColor = widget.isMe ? AppTheme.terra : AppTheme.ink;
    final scoreColor = widget.isLeader
        ? AppTheme.goldReserved
        : widget.isMe
            ? AppTheme.terra
            : AppTheme.ink;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          widget.name,
          style: GoogleFonts.caveat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: nameColor,
            height: 1.1,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.isMe) ...[
          const SizedBox(width: 6),
          Text(
            'ΕΣΥ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: AppTheme.terra,
            ),
          ),
        ],
        if (widget.isLeader) ...[
          const SizedBox(width: 6),
          const Text(
            '★',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.goldReserved,
              height: 1.1,
            ),
          ),
        ],
        const SizedBox(width: AppTheme.space2),
        // Receipt-style dotted leader
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DottedLine(
                color: AppTheme.ink.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        // Score numeral + optional floater stacked above.
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              '$_displayedScore',
              style: GoogleFonts.gloock(
                fontSize: 20,
                color: scoreColor,
                height: 1.0,
                letterSpacing: -0.3,
              ),
            ),
            if (_pendingFloater != null)
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  final t = _ctrl.value;
                  // Rise from 0 → -22, fade in quickly then out slowly.
                  final translateY = -22 * Curves.easeOutCubic.transform(t);
                  final opacity = t < 0.1
                      ? t * 10
                      : (1 - ((t - 0.1) / 0.9)).clamp(0.0, 1.0);
                  return Positioned(
                    top: translateY,
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        '+${_pendingFloater!}',
                        style: GoogleFonts.caveat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.terra,
                          height: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _DottedLine extends CustomPainter {
  const _DottedLine({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dotRadius = 0.8;
    const gap = 4.0;
    final paint = Paint()..color = color;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawCircle(Offset(x, size.height / 2), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLine oldDelegate) =>
      oldDelegate.color != color;
}
