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

class _TallyRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final nameColor = isMe ? AppTheme.terra : AppTheme.ink;
    final scoreColor = isLeader
        ? AppTheme.goldReserved
        : isMe
            ? AppTheme.terra
            : AppTheme.ink;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          name,
          style: GoogleFonts.caveat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: nameColor,
            height: 1.1,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (isMe) ...[
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
        if (isLeader) ...[
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
        Text(
          '$score',
          style: GoogleFonts.gloock(
            fontSize: 20,
            color: scoreColor,
            height: 1.0,
            letterSpacing: -0.3,
          ),
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
