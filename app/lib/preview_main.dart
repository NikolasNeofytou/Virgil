import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/generated/app_localizations.dart';
import 'models/leaderboard_entry.dart';
import 'providers/active_game_provider.dart';
import 'screens/estimation/widgets/number_picker.dart';
import 'screens/estimation/widgets/player_score_row.dart';
import 'screens/estimation/widgets/round_header.dart';
import 'screens/tabs/leaderboard_tab.dart';
import 'screens/tabs/play_tab.dart';
import 'theme/app_background.dart';
import 'theme/app_theme.dart';
import 'theme/meraki_fonts.dart';
import 'theme/virgil_icons.dart';
import 'widgets/virgil_button.dart';
import 'widgets/virgil_card.dart';
import 'widgets/virgil_chip.dart';
import 'widgets/virgil_ornament.dart';
import 'widgets/virgil_score.dart';

/// Design-preview entry point. Renders a scrollable gallery of Virgil
/// identity surfaces without needing Supabase or any backend. Run with:
///
///   flutter run -d web-server --target lib/preview_main.dart --web-port 8787
void main() {
  runApp(const _PreviewApp());
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virgil Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _Gallery(),
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery();

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _predictionValue = 3;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.space5),
                children: [
                  const SizedBox(height: AppTheme.space3),
                  const _MastheadBlock(),
                  const _Rule(),
                  const AppSectionLabel('§ 01 · TAB ICONS', showRule: true),
                  const SizedBox(height: AppTheme.space3),
                  const _TabIconsRow(),
                  const _Rule(),
                  const AppSectionLabel('§ 02 · ROUND HEADER', showRule: true),
                  const SizedBox(height: AppTheme.space3),
                  const RoundHeader(
                    currentRound: 7,
                    totalRounds: 25,
                    cardsThisRound: 5,
                    dealerName: 'Elena',
                  ),
                  const _Rule(),
                  const AppSectionLabel('§ 03 · LOCK-IN', showRule: true),
                  const SizedBox(height: AppTheme.space3),
                  Text(
                    'Πόσες μπάζες θα πάρεις;',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.space3),
                  NumberPicker(
                    value: _predictionValue,
                    max: 7,
                    onChanged: (v) => setState(() => _predictionValue = v),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Κλείδωμα'),
                  ),
                  const _Rule(),
                  const AppSectionLabel('§ 04 · LOCKED STAMP', showRule: true),
                  const SizedBox(height: AppTheme.space3),
                  _StampedCard(
                    eyebrow: 'Η ΠΡΟΒΛΕΨΗ ΣΟΥ',
                    value: _predictionValue,
                    caption: 'περιμένοντας 2 παίκτες…',
                    accent: AppTheme.terra,
                  ),
                  const SizedBox(height: AppTheme.space3),
                  const _StampedCard(
                    eyebrow: 'ΟΙ ΜΠΑΖΕΣ ΣΟΥ',
                    value: 3,
                    caption: null,
                    accent: AppTheme.olive,
                  ),
                  const _Rule(),
                  const AppSectionLabel('§ 05 · PLAYERS', showRule: true),
                  const SizedBox(height: AppTheme.space3),
                  const PlayerScoreRow(
                    username: 'Nikolas',
                    isMe: true,
                    statusIcon: Icons.check_circle,
                    statusText: 'Κλειδωμένο',
                  ),
                  const PlayerScoreRow(
                    username: 'Elena',
                    isMe: false,
                    statusIcon: Icons.hourglass_empty,
                    statusText: 'Περιμένω…',
                  ),
                  const PlayerScoreRow(
                    username: 'Andreas',
                    isMe: false,
                    predicted: 3,
                    actual: 3,
                    score: 13,
                    highlightBonus: true,
                  ),
                  const _Rule(),
                  const AppSectionLabel('§ 06 · REVEAL', showRule: true),
                  const SizedBox(height: AppTheme.space3),
                  const _RevealRow(
                    name: 'Nikolas',
                    predicted: 3,
                    actual: 3,
                    score: 13,
                    match: true,
                    isMe: true,
                  ),
                  const _RevealRow(
                    name: 'Elena',
                    predicted: 2,
                    actual: 1,
                    score: 1,
                    match: false,
                    isMe: false,
                  ),
                  const _Rule(),
                  const AppSectionLabel('§ 07 · WINNER', showRule: true),
                  const SizedBox(height: AppTheme.space4),
                  const _WinnerBlock(name: 'Nikolas', score: 247),
                  const _Rule(),
                  const AppSectionLabel('§ 08 · ROOM CODE', showRule: true),
                  const SizedBox(height: AppTheme.space3),
                  const _RoomCodeBlock(code: '4F7B'),
                  const _Rule(),
                  const AppSectionLabel('§ 09 · PALETTE', showRule: true),
                  const SizedBox(height: AppTheme.space3),
                  const _PaletteBlock(),
                  const _Rule(),
                  const AppSectionLabel('§ 10 · COMPONENTS', showRule: true),
                  const SizedBox(height: AppTheme.space4),
                  const _ComponentsBlock(),
                  const _Rule(),
                  const AppSectionLabel('§ 11 · LOBBY', showRule: true),
                  const SizedBox(height: AppTheme.space4),
                  const _LobbyPreview(),
                  const _Rule(),
                  const AppSectionLabel('§ 12 · TOURNAMENT', showRule: true),
                  const SizedBox(height: AppTheme.space4),
                  const _TournamentPreview(),
                  const SizedBox(height: AppTheme.space6),
                  Text(
                    '— FIN —',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      letterSpacing: 3,
                      color: AppTheme.inkSoft,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.space6),
        child: _SectionRule(),
      );
}

class _SectionRule extends StatelessWidget {
  const _SectionRule();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 1,
          color: AppTheme.ink.withValues(alpha: 0.2),
        ),
        Container(
          color: AppTheme.pageBg,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '§',
            style: GoogleFonts.gloock(fontSize: 18, color: AppTheme.terra),
          ),
        ),
      ],
    );
  }
}

class _MastheadBlock extends StatelessWidget {
  const _MastheadBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VOL. I · APR 2026',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
            Text(
              'KAFENEIO SERIES',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 2, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space3),
        Center(
          child: Text(
            'Virgil',
            style: GoogleFonts.gloock(
              fontSize: 88,
              color: AppTheme.ink,
              letterSpacing: -2.0,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: Text(
            'a guide for the table',
            style: GoogleFonts.caveat(fontSize: 22, color: AppTheme.terra),
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 2, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space3),
        Center(
          child: Text(
            'ένας οδηγός για το τραπέζι',
            style: GoogleFonts.kalam(fontSize: 14, color: AppTheme.inkSoft),
          ),
        ),
      ],
    );
  }
}

class _TabIconsRow extends StatelessWidget {
  const _TabIconsRow();

  @override
  Widget build(BuildContext context) {
    final icons = [
      (VirgilIconName.home, 'home'),
      (VirgilIconName.rooms, 'rooms'),
      (VirgilIconName.stats, 'stats'),
      (VirgilIconName.profile, 'profile'),
    ];
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final (name, label) in icons)
            Column(
              children: [
                VirgilIcon(name, size: 28, color: AppTheme.ink),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: AppTheme.inkSoft,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StampedCard extends StatelessWidget {
  const _StampedCard({
    required this.eyebrow,
    required this.value,
    required this.caption,
    required this.accent,
  });

  final String eyebrow;
  final int value;
  final String? caption;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.space5,
        horizontal: AppTheme.space5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Text(
            eyebrow,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
              color: accent,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.5),
                      width: 1.6,
                    ),
                  ),
                ),
                Text(
                  '$value',
                  style: GoogleFonts.gloock(
                    fontSize: 80,
                    color: accent,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppTheme.space3),
            Text(
              caption!,
              style: GoogleFonts.caveat(fontSize: 18, color: AppTheme.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevealRow extends StatelessWidget {
  const _RevealRow({
    required this.name,
    required this.predicted,
    required this.actual,
    required this.score,
    required this.match,
    required this.isMe,
  });

  final String name;
  final int predicted;
  final int actual;
  final int score;
  final bool match;
  final bool isMe;

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
          color: isMe
              ? AppTheme.terra.withValues(alpha: 0.55)
              : AppTheme.border,
          width: isMe ? 1.2 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: GoogleFonts.caveat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isMe ? AppTheme.terra : AppTheme.ink,
              ),
            ),
          ),
          _RevealNumeral(value: predicted, highlight: false),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '→',
              style: GoogleFonts.gloock(fontSize: 18, color: AppTheme.inkFaint),
            ),
          ),
          _RevealNumeral(value: actual, highlight: match),
          const SizedBox(width: AppTheme.space2),
          SizedBox(
            width: 56,
            child: Text(
              match ? '★ +$score' : '+$score',
              textAlign: TextAlign.center,
              style: GoogleFonts.caveat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: match ? AppTheme.olive : AppTheme.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealNumeral extends StatelessWidget {
  const _RevealNumeral({required this.value, required this.highlight});

  final int value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppTheme.olive : AppTheme.ink;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: GoogleFonts.gloock(
            fontSize: 26,
            color: color,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 1,
          width: 20,
          color: highlight
              ? AppTheme.olive.withValues(alpha: 0.6)
              : AppTheme.terra.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

class _WinnerBlock extends StatelessWidget {
  const _WinnerBlock({required this.name, required this.score});

  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const CustomPaint(
                size: Size(300, 180),
                painter: _LaurelPainter(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  name,
                  style: GoogleFonts.gloock(
                    fontSize: 44,
                    color: AppTheme.ink,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
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
        const SizedBox(height: AppTheme.space3),
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
    final rx = size.width * 0.38;
    final ry = size.height * 0.42;

    final leafFill = Paint()..color = AppTheme.olive;
    final veinStroke = Paint()
      ..color = const Color(0xFF3D5218).withValues(alpha: 0.4)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (final dir in [-1, 1]) {
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
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 10, height: 22),
          leafFill,
        );
        canvas.drawLine(const Offset(-5, 0), const Offset(5, 0), veinStroke);
        canvas.restore();
      }
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
    final fold = Paint()..color = const Color(0xFF7A3F22);

    final w = size.width;
    final h = size.height;
    const tail = 12.0;
    const cut = 6.0;

    final bodyPath = Path()
      ..moveTo(tail, 0)
      ..lineTo(w - tail, 0)
      ..lineTo(w - tail, h)
      ..lineTo(tail, h)
      ..close();
    canvas.drawPath(bodyPath, body);

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

class _RoomCodeBlock extends StatelessWidget {
  const _RoomCodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          Text(
            'ROOM · ΚΩΔΙΚΟΣ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
              color: AppTheme.terra,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            code,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 44,
              fontWeight: FontWeight.w500,
              letterSpacing: 10,
              color: AppTheme.ink,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Container(
            height: 1,
            width: 60,
            color: AppTheme.terra.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            'μοιράσου με τους παίκτες',
            style: GoogleFonts.caveat(fontSize: 18, color: AppTheme.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _PaletteBlock extends StatelessWidget {
  const _PaletteBlock();

  @override
  Widget build(BuildContext context) {
    final swatches = [
      ('linen', AppTheme.linen, '#F6EFE6'),
      ('bone', AppTheme.bone, '#EBE2D3'),
      ('ink', AppTheme.ink, '#14193F'),
      ('aegean', AppTheme.aegean, '#1F2A5C'),
      ('coral', AppTheme.coral, '#D9573F'),
      ('myrtle', AppTheme.myrtle, '#4F6B5C'),
      ('ochre', AppTheme.ochre, '#C39448'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (name, color, hex) in swatches)
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: AppTheme.ink.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                    ),
                    Text(
                      hex,
                      style: const TextStyle(
                        fontFamily: MerakiFonts.geistMonoFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: AppTheme.inkSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// §10 — Showcase the Meraki component library introduced in PR 3.
class _ComponentsBlock extends StatelessWidget {
  const _ComponentsBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Buttons
        Wrap(
          spacing: AppTheme.space3,
          runSpacing: AppTheme.space3,
          alignment: WrapAlignment.center,
          children: [
            VirgilButton(
              label: 'Take your seat',
              onPressed: () {},
              trailingArrow: true,
            ),
            VirgilButton(
              label: 'Sit',
              onPressed: () {},
              variant: VirgilButtonVariant.ghost,
              trailingArrow: true,
            ),
            const VirgilButton(label: 'Locked', onPressed: null),
          ],
        ),
        const SizedBox(height: AppTheme.space4),
        // Chips
        const Wrap(
          spacing: AppTheme.space2,
          runSpacing: AppTheme.space2,
          alignment: WrapAlignment.center,
          children: [
            VirgilChip(
              label: 'online',
              variant: VirgilChipVariant.success,
              dot: true,
            ),
            VirgilChip(label: 'live', variant: VirgilChipVariant.accent),
            VirgilChip(label: 'ezy', variant: VirgilChipVariant.reward),
            VirgilChip(label: 'soon', variant: VirgilChipVariant.neutral),
          ],
        ),
        const SizedBox(height: AppTheme.space4),
        // Cards (standard + hero)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: VirgilCard(
                child: Text(
                  'standard',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: VirgilCard(
                variant: VirgilCardVariant.hero,
                child: Text(
                  'hero',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space4),
        // Ornament
        const VirgilOrnament(glyph: '·'),
        // Score (oldstyle figures, fraction display)
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            VirgilScore(value: 247, fontSize: 48),
            VirgilScore(
              value: 21,
              outOf: 14,
              fontSize: 48,
              color: AppTheme.coral,
            ),
          ],
        ),
      ],
    );
  }
}

/// §11 — Lobby preview. Shows the four Play-tab sections (header, daily-
/// moment hero, continue card, games tiles) with mock data — the production
/// PlayTab reads username and active-game state from Riverpod providers.
class _LobbyPreview extends StatelessWidget {
  const _LobbyPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LobbyHeader(username: 'nikolas'),
        const SizedBox(height: AppTheme.space5),
        DailyMomentCard(onCreate: () {}, onJoin: () {}),
        const SizedBox(height: AppTheme.space5),
        ContinueCard(
          active: const ActiveGameSummary(
            gameId: 'preview-id',
            roomCode: '4F7B',
            status: 'active',
            currentRound: 3,
            totalRounds: 14,
          ),
          onTap: () {},
        ),
        const SizedBox(height: AppTheme.space5),
        GamesSection(onEstimationTap: () {}),
      ],
    );
  }
}

/// §12 — Tournament preview. Shows the editorial header, my-stats hero card,
/// and four leaderboard rows including a top-3 ochre advancement, the signed-
/// in player highlight, and a rank-change ↑ chip.
class _TournamentPreview extends StatelessWidget {
  const _TournamentPreview();

  @override
  Widget build(BuildContext context) {
    const mine = LeaderboardEntry(
      playerId: 'me',
      username: 'nikolas',
      gamesPlayed: 14,
      wins: 6,
      lifetimePoints: 247,
      avgScorePerGame: 17.6,
      accuracy: 0.62,
    );
    final rows = <LeaderboardEntry>[
      const LeaderboardEntry(
        playerId: 'caesar',
        username: 'caesar',
        gamesPlayed: 28,
        wins: 18,
        lifetimePoints: 612,
        avgScorePerGame: 21.8,
        accuracy: 0.74,
      ),
      const LeaderboardEntry(
        playerId: 'marios',
        username: 'marios.k',
        gamesPlayed: 24,
        wins: 12,
        lifetimePoints: 488,
        avgScorePerGame: 20.3,
        accuracy: 0.66,
      ),
      mine,
      const LeaderboardEntry(
        playerId: 'anna',
        username: 'anna_g',
        gamesPlayed: 19,
        wins: 5,
        lifetimePoints: 213,
        avgScorePerGame: 11.2,
        accuracy: 0.55,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TournamentHeader(),
        const SizedBox(height: AppTheme.space5),
        const TournamentMyStatsCard(stats: mine),
        const SizedBox(height: AppTheme.space5),
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == rows.length - 1 ? 0 : AppTheme.space2,
            ),
            child: TournamentLeaderRow(
              rank: i + 1,
              stats: rows[i],
              isMe: rows[i].playerId == 'me',
              previousRank: rows[i].playerId == 'me' ? 5 : null,
            ),
          ),
      ],
    );
  }
}
