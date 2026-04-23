import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/estimation_providers.dart';
import '../../../theme/app_theme.dart';

/// Final standings — the Virgil winner moment. A laurel wreath cradles the
/// winner's name; a terracotta ribbon unfurls below with "ΝΙΚΗΤΗΣ · WINNER".
class GameOverPanel extends ConsumerWidget {
  const GameOverPanel({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players =
        ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull ?? [];
    final usernames =
        ref.watch(playerUsernamesProvider(gameId)).valueOrNull ?? {};
    final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;

    if (players.isEmpty || game == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final sorted = [...players]
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final winner = sorted.first;
    final winnerName = usernames[winner.playerId] ?? '???';

    return Padding(
      padding: const EdgeInsets.all(AppTheme.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          _WinnerCertificate(name: winnerName, score: winner.totalScore),
          const SizedBox(height: AppTheme.space6),
          const AppSectionLabelMono('ΚΑΤΑΤΑΞΗ · FINAL'),
          const SizedBox(height: AppTheme.space3),
          ...List.generate(sorted.length, (i) {
            final p = sorted[i];
            final name = usernames[p.playerId] ?? '???';
            return _StandingRow(
              rank: i + 1,
              name: name,
              score: p.totalScore,
              isWinner: i == 0,
            );
          }),
          const Spacer(),
          FilledButton(
            onPressed: () => Navigator.of(context).popUntil(
              (route) => route.isFirst,
            ),
            child: const Text('Πίσω στο μενού'),
          ),
        ],
      ),
    );
  }
}

/// The winner card — laurel wreath + name + ribbon.
class _WinnerCertificate extends StatelessWidget {
  const _WinnerCertificate({required this.name, required this.score});

  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 280,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const CustomPaint(
                size: Size(280, 170),
                painter: _LaurelPainter(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.gloock(
                    fontSize: 40,
                    color: AppTheme.ink,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        SizedBox(
          width: 220,
          height: 38,
          child: CustomPaint(
            painter: const _RibbonPainter(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'ΝΙΚΗΤΗΣ · WINNER',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3,
                    color: AppTheme.paper,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        Text(
          '$score πόντοι',
          style: GoogleFonts.caveat(
            fontSize: 22,
            color: AppTheme.inkSoft,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LaurelPainter extends CustomPainter {
  const _LaurelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.62);
    final rx = size.width * 0.38; // horizontal radius — hugs the name
    final ry = size.height * 0.42; // vertical — tighter, ellipse shape

    final leafFill = Paint()
      ..color = AppTheme.olive
      ..style = PaintingStyle.fill;
    final veinStroke = Paint()
      ..color = const Color(0xFF3D5218).withValues(alpha: 0.4)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (final dir in [-1, 1]) {
      _paintSide(canvas, center, rx, ry, dir, leafFill, veinStroke);
    }
  }

  void _paintSide(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    int dir,
    Paint leafFill,
    Paint veinStroke,
  ) {
    // Arc: start near bottom (slight gap), sweep up to near top.
    const startFrac = 0.12;
    const endFrac = 0.95;
    const leafCount = 9;

    for (var i = 0; i < leafCount; i++) {
      final a = math.pi / 2 +
          dir *
              math.pi *
              (startFrac + (endFrac - startFrac) * (i / (leafCount - 1)));
      final cx = center.dx + math.cos(a) * rx;
      final cy = center.dy + math.sin(a) * ry;
      final stemAngle = math.atan2(math.cos(a) * ry, -math.sin(a) * rx);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(stemAngle);
      // Leaf: 5 × 11 ellipse
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 10, height: 22),
        leafFill,
      );
      // Central vein
      canvas.drawLine(const Offset(-5, 0), const Offset(5, 0), veinStroke);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LaurelPainter oldDelegate) => false;
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = AppTheme.terra;
    final fold = Paint()..color = const Color(0xFF7A3F22); // deeper terra

    final w = size.width;
    final h = size.height;
    const tail = 12.0; // tail width
    const cut = 6.0; // V-cut depth

    // Main body
    final bodyPath = Path()
      ..moveTo(tail, 0)
      ..lineTo(w - tail, 0)
      ..lineTo(w - tail, h)
      ..lineTo(tail, h)
      ..close();
    canvas.drawPath(bodyPath, body);

    // Left tail fold
    final leftTail = Path()
      ..moveTo(tail, 0)
      ..lineTo(0, h / 2)
      ..lineTo(tail + cut, h / 2)
      ..close();
    final leftTailBottom = Path()
      ..moveTo(tail, h)
      ..lineTo(0, h / 2)
      ..lineTo(tail + cut, h / 2)
      ..close();
    canvas.drawPath(leftTail, fold);
    canvas.drawPath(leftTailBottom, fold);

    // Right tail fold (mirror)
    final rightTail = Path()
      ..moveTo(w - tail, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w - tail - cut, h / 2)
      ..close();
    final rightTailBottom = Path()
      ..moveTo(w - tail, h)
      ..lineTo(w, h / 2)
      ..lineTo(w - tail - cut, h / 2)
      ..close();
    canvas.drawPath(rightTail, fold);
    canvas.drawPath(rightTailBottom, fold);
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter oldDelegate) => false;
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.rank,
    required this.name,
    required this.score,
    required this.isWinner,
  });

  final int rank;
  final String name;
  final int score;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isWinner
              ? AppTheme.terra.withValues(alpha: 0.55)
              : AppTheme.border,
          width: isWinner ? 1.2 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: GoogleFonts.gloock(
                fontSize: 20,
                color: isWinner ? AppTheme.terra : AppTheme.inkFaint,
                height: 1.0,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.caveat(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isWinner ? AppTheme.terra : AppTheme.ink,
                height: 1.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$score',
            style: GoogleFonts.gloock(
              fontSize: 22,
              color: isWinner ? AppTheme.terra : AppTheme.ink,
              height: 1.0,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small convenience — a terracotta JetBrains Mono eyebrow. Defined here so
/// the game-over panel isn't coupled to the app-wide `AppSectionLabel`.
class AppSectionLabelMono extends StatelessWidget {
  const AppSectionLabelMono(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 3,
        color: AppTheme.terra,
      ),
    );
  }
}
