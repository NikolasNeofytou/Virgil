import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/game_award.dart';
import '../../../providers/active_game_provider.dart';
import '../../../providers/estimation_providers.dart';
import '../../../services/estimation_service.dart';
import '../../../theme/app_route.dart';
import '../../../theme/app_theme.dart';
import '../room_lobby_screen.dart';

/// Final standings — the Virgil winner moment. A laurel wreath cradles the
/// winner's name; a terracotta ribbon unfurls below with "ΝΙΚΗΤΗΣ · WINNER".
class GameOverPanel extends ConsumerStatefulWidget {
  const GameOverPanel({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<GameOverPanel> createState() => _GameOverPanelState();
}

class _GameOverPanelState extends ConsumerState<GameOverPanel> {
  final _service = EstimationService();
  bool _starting = false;

  Future<void> _rematch() async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final newGameId = await _service.rematchOrJoin(widget.gameId);
      if (!mounted) return;
      ref.invalidate(activeEstimationGameProvider);
      Navigator.of(context).pushReplacement<void, void>(
        AppRoute.build((_) => RoomLobbyScreen(gameId: newGameId)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _starting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Σφάλμα: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = ref
            .watch(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    final usernames =
        ref.watch(playerUsernamesProvider(widget.gameId)).valueOrNull ?? {};
    final game =
        ref.watch(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final awards = ref.watch(gameAwardsProvider(widget.gameId));

    if (players.isEmpty || game == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final sorted = [...players]
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final winner = sorted.first;
    final winnerName = usernames[winner.playerId] ?? '???';

    final sessionLabel = (game.sessionName?.trim().isNotEmpty ?? false)
        ? game.sessionName!
        : 'παιχνίδι ${DateFormat('d MMM').format(game.createdAt.toLocal())}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space6,
        AppTheme.space5,
        AppTheme.space6,
        AppTheme.space7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Session label header ──
          Center(
            child: Text(
              sessionLabel,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.5,
                color: AppTheme.inkSoft,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space5),
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

          if (awards.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space6),
            const AppSectionLabelMono('ΒΡΑΒΕΙΑ · AWARDS'),
            const SizedBox(height: AppTheme.space3),
            for (var i = 0; i < awards.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == awards.length - 1 ? 0 : AppTheme.space2,
                ),
                child: _AwardCard(award: awards[i])
                    .animate()
                    .fadeIn(
                      // Stagger after the WinnerCertificate has settled
                      // (~4.2s) so awards don't fight the laurel reveal.
                      duration: 320.ms,
                      delay: (4400 + i * 140).ms,
                      curve: Curves.easeOut,
                    )
                    .slideY(begin: 0.2, end: 0, duration: 320.ms),
              ),
          ],

          const SizedBox(height: AppTheme.space7),
          FilledButton(
            onPressed: _starting ? null : _rematch,
            child: _starting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Νέο παιχνίδι'),
          ),
          const SizedBox(height: AppTheme.space2),
          OutlinedButton(
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

/// One award row, paper-and-ink: emoji on the left, ink title + caveat
/// description, terra username chip on the right.
class _AwardCard extends StatelessWidget {
  const _AwardCard({required this.award});

  final GameAward award;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              award.emoji,
              style: const TextStyle(fontSize: 22, height: 1),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  award.title,
                  style: GoogleFonts.gloock(
                    fontSize: 17,
                    color: AppTheme.ink,
                    height: 1.0,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  award.description,
                  style: GoogleFonts.kalam(
                    fontSize: 13,
                    color: AppTheme.inkSoft,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Text(
            award.username,
            style: GoogleFonts.caveat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.terra,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The winner card — laurel wreath + name + ribbon, animated in over
/// ~4.2s per the design's SceneWinner spec:
///
///   0.00 → 0.30  name fades in letter-by-letter (typewriter feel)
///   0.20 → 0.70  laurel leaves grow, both sides staggered
///   0.60 → 0.90  ribbon body unfurls from the center outward
///   0.70 → 1.00  "ΝΙΚΗΤΗΣ · WINNER" text fades in on the ribbon;
///                `X πόντοι` line fades in below
class _WinnerCertificate extends StatefulWidget {
  const _WinnerCertificate({required this.name, required this.score});

  final String name;
  final int score;

  @override
  State<_WinnerCertificate> createState() => _WinnerCertificateState();
}

class _WinnerCertificateState extends State<_WinnerCertificate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final laurelT = ((t - 0.20) / 0.50).clamp(0.0, 1.0);
        final ribbonT = ((t - 0.60) / 0.30).clamp(0.0, 1.0);
        final captionT = ((t - 0.70) / 0.30).clamp(0.0, 1.0);

        return Column(
          children: [
            SizedBox(
              width: 280,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(280, 170),
                    painter: _LaurelPainter(progress: laurelT),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TypewriterName(name: widget.name, progress: t),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space3),
            SizedBox(
              width: 220,
              height: 38,
              child: CustomPaint(
                painter: _RibbonPainter(progress: ribbonT),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Opacity(
                      opacity: captionT,
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
            ),
            const SizedBox(height: AppTheme.space4),
            Opacity(
              opacity: captionT,
              child: Text(
                '${widget.score} πόντοι',
                style: GoogleFonts.caveat(
                  fontSize: 22,
                  color: AppTheme.inkSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Types the name in character by character over the first 0.30 of the
/// controller. Each letter fades + rises into position.
class _TypewriterName extends StatelessWidget {
  const _TypewriterName({required this.name, required this.progress});

  final String name;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final letters = name.characters.toList();
    final perLetter = 0.30 / letters.length.clamp(1, 99);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < letters.length; i++)
          _Letter(
            char: letters[i],
            t: ((progress - i * perLetter * 0.6) / (perLetter * 2))
                .clamp(0.0, 1.0),
          ),
      ],
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter({required this.char, required this.t});

  final String char;
  final double t;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, 8 * (1 - Curves.easeOutCubic.transform(t))),
      child: Opacity(
        opacity: t,
        child: Text(
          char,
          style: GoogleFonts.gloock(
            fontSize: 40,
            color: AppTheme.ink,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class _LaurelPainter extends CustomPainter {
  const _LaurelPainter({this.progress = 1.0});

  /// 0 = no leaves drawn, 1 = fully drawn. Left side leads by 10% of the
  /// window so the two arcs grow at slightly different cadences.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.62);
    final rx = size.width * 0.38;
    final ry = size.height * 0.42;

    final leafFill = Paint()
      ..color = AppTheme.olive
      ..style = PaintingStyle.fill;
    final veinStroke = Paint()
      ..color = const Color(0xFF3D5218).withValues(alpha: 0.4)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Slight side offset for personality.
    final leftT = (progress / 0.9).clamp(0.0, 1.0);
    final rightT = ((progress - 0.1) / 0.9).clamp(0.0, 1.0);

    _paintSide(canvas, center, rx, ry, -1, leftT, leafFill, veinStroke);
    _paintSide(canvas, center, rx, ry, 1, rightT, leafFill, veinStroke);
  }

  void _paintSide(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    int dir,
    double sideProgress,
    Paint leafFill,
    Paint veinStroke,
  ) {
    const startFrac = 0.12;
    const endFrac = 0.95;
    const leafCount = 9;
    const perLeaf = 1 / leafCount;

    for (var i = 0; i < leafCount; i++) {
      final leafT =
          ((sideProgress - i * perLeaf * 0.5) / (perLeaf * 2)).clamp(0.0, 1.0);
      if (leafT <= 0) continue;

      final a = math.pi / 2 +
          dir *
              math.pi *
              (startFrac + (endFrac - startFrac) * (i / (leafCount - 1)));
      final cx = center.dx + math.cos(a) * rx;
      final cy = center.dy + math.sin(a) * ry;
      final stemAngle = math.atan2(math.cos(a) * ry, -math.sin(a) * rx);
      final scale = Curves.easeOutCubic.transform(leafT);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(stemAngle);
      canvas.scale(scale);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 10, height: 22),
        leafFill,
      );
      canvas.drawLine(const Offset(-5, 0), const Offset(5, 0), veinStroke);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LaurelPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter({this.progress = 1.0});

  /// 0 = nothing drawn, 1 = full ribbon. The ribbon unfurls from center
  /// outward, so at small progress values the body is clipped around
  /// `w / 2`.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final body = Paint()..color = AppTheme.terra;
    final fold = Paint()..color = const Color(0xFF7A3F22); // deeper terra

    final w = size.width;
    final h = size.height;
    const tail = 12.0;
    const cut = 6.0;
    final t = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final half = (w / 2) * t;
    final cx = w / 2;

    // Main body — width grows from 0 to (w - 2·tail).
    final bodyPath = Path()
      ..moveTo(cx - (half - tail).clamp(0.0, w), 0)
      ..lineTo(cx + (half - tail).clamp(0.0, w), 0)
      ..lineTo(cx + (half - tail).clamp(0.0, w), h)
      ..lineTo(cx - (half - tail).clamp(0.0, w), h)
      ..close();
    canvas.drawPath(bodyPath, body);

    // Tails only show once the body has unfurled past the tail width.
    if (half <= tail) return;

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
  bool shouldRepaint(covariant _RibbonPainter oldDelegate) =>
      oldDelegate.progress != progress;
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
