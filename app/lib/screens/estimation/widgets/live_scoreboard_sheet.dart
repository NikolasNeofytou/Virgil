import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/live_player_stats.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../theme/app_theme.dart';

/// Pull-up sheet showing live per-player rankings, prediction accuracy, and
/// a round-by-round score-progression line chart. Open from the game screen
/// app bar via [showLiveScoreboardSheet]. Paper-and-ink visual identity
/// matches the rest of Virgil.
Future<void> showLiveScoreboardSheet(
  BuildContext context, {
  required String gameId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LiveScoreboardSheet(gameId: gameId),
  );
}

/// One distinct line colour per player. First place inherits terra; the
/// remainder use the Virgil palette's other accents — olive, info, gold.
const _playerLineColors = <Color>[
  AppTheme.terra,
  AppTheme.olive,
  AppTheme.info,
  AppTheme.goldReserved,
];

class _LiveScoreboardSheet extends ConsumerWidget {
  const _LiveScoreboardSheet({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(liveScoreboardProvider(gameId));
    final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
    final myId = ref.watch(currentUserIdProvider);

    final maxRound = game?.totalRounds ?? 1;
    final anyScored = stats.any((s) => s.cumulativeByRound.isNotEmpty);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
            border: Border(
              top: BorderSide(color: AppTheme.border),
              left: BorderSide(color: AppTheme.border),
              right: BorderSide(color: AppTheme.border),
            ),
            boxShadow: AppTheme.shadowMd,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.space2),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.space3),
              // Masthead-ish header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        'ΖΩΝΤΑΝΗ ΚΑΤΑΤΑΞΗ · LIVE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          letterSpacing: 3,
                          color: AppTheme.terra,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(height: 1, color: AppTheme.ink),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.space3),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.space5,
                    AppTheme.space3,
                    AppTheme.space5,
                    AppTheme.space6,
                  ),
                  children: [
                    if (stats.isEmpty)
                      const _EmptyState()
                    else ...[
                      for (var i = 0; i < stats.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == stats.length - 1
                                ? 0
                                : AppTheme.space2,
                          ),
                          child: _RankRow(
                            rank: i + 1,
                            stats: stats[i],
                            color: _playerLineColors[
                                i % _playerLineColors.length],
                            isMe: stats[i].playerId == myId,
                          ),
                        ),
                      if (anyScored) ...[
                        const SizedBox(height: AppTheme.space5),
                        Text(
                          'ΕΞΕΛΙΞΗ ΣΚΟΡ · CHART',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 3,
                            color: AppTheme.inkFaint,
                          ),
                        ),
                        const SizedBox(height: AppTheme.space3),
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _ScoreLineChart(
                            stats: stats,
                            colors: _playerLineColors,
                            totalRounds: maxRound,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space7),
      child: Column(
        children: [
          const Icon(
            Icons.timelapse_outlined,
            size: 28,
            color: AppTheme.inkFaint,
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            'περιμένουμε δεδομένα…',
            style: GoogleFonts.kalam(
              fontSize: 14,
              color: AppTheme.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.stats,
    required this.color,
    required this.isMe,
  });

  final int rank;
  final LivePlayerStats stats;
  final Color color;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final acc = stats.accuracy;
    final accLabel = acc == null ? '—' : '${(acc * 100).round()}%';
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
          // Rank badge — Gloock numeral
          SizedBox(
            width: 22,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: GoogleFonts.gloock(
                fontSize: 18,
                color: rank == 1 ? AppTheme.terra : AppTheme.inkFaint,
                height: 1.0,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          // Color swatch — line legend
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    stats.username,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.caveat(
                      fontSize: 20,
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
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          // Accuracy
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                accLabel,
                style: GoogleFonts.gloock(
                  fontSize: 16,
                  color: AppTheme.ink,
                  height: 1.0,
                ),
              ),
              Text(
                'ΑΚΡ.',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: AppTheme.inkFaint,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppTheme.space3),
          // Total score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.totalScore}',
                style: GoogleFonts.gloock(
                  fontSize: 22,
                  color: AppTheme.terra,
                  height: 1.0,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'ΠΟΝΤΟΙ',
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

/// Round-by-round cumulative-score chart. CustomPainter-based so we don't
/// pull in fl_chart for a single use. One polyline per player, paper-toned
/// gridlines at quartiles, terra/olive/info/gold dots at each scored round.
class _ScoreLineChart extends StatelessWidget {
  const _ScoreLineChart({
    required this.stats,
    required this.colors,
    required this.totalRounds,
  });

  final List<LivePlayerStats> stats;
  final List<Color> colors;
  final int totalRounds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space2,
        AppTheme.space3,
        AppTheme.space2,
        AppTheme.space2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: CustomPaint(
        painter: _ScoreLinePainter(
          stats: stats,
          colors: colors,
          totalRounds: totalRounds,
        ),
      ),
    );
  }
}

class _ScoreLinePainter extends CustomPainter {
  _ScoreLinePainter({
    required this.stats,
    required this.colors,
    required this.totalRounds,
  });

  final List<LivePlayerStats> stats;
  final List<Color> colors;
  final int totalRounds;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalRounds < 2) return;

    var maxScore = 1;
    for (final s in stats) {
      for (final v in s.cumulativeByRound.values) {
        if (v > maxScore) maxScore = v;
      }
    }
    const minScore = 0;
    final scoreRange = (maxScore - minScore).clamp(1, double.infinity);

    const left = 0.0;
    final right = size.width;
    const top = 0.0;
    final bottom = size.height;

    double xFor(int round) =>
        left + (round - 1) / (totalRounds - 1) * (right - left);
    double yFor(int score) =>
        bottom - (score - minScore) / scoreRange * (bottom - top);

    // Subtle ink gridlines at quartiles.
    final gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 0.5;
    for (var i = 1; i < 4; i++) {
      final y = top + (bottom - top) * i / 4;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }

    for (var i = 0; i < stats.length; i++) {
      final s = stats[i];
      final color = colors[i % colors.length];
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final rounds = s.cumulativeByRound.keys.toList()..sort();
      if (rounds.isEmpty) continue;

      final points = <Offset>[
        Offset(xFor(1), yFor(0)),
        ...rounds.map((r) => Offset(xFor(r), yFor(s.cumulativeByRound[r]!))),
      ];

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);

      for (final p in points.skip(1)) {
        canvas.drawCircle(p, 2.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreLinePainter old) =>
      old.stats != stats ||
      old.totalRounds != totalRounds ||
      old.colors != colors;
}
