import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/meraki_fonts.dart';

/// The kafeneio ceremony for picking who deals round 1.
///
/// Deterministic: both devices render the same outcome because [dealerSeat]
/// comes from the `estimation_games` row (written by the host when they tap
/// "start game"). The widget just plays the reveal animation.
///
/// Timeline (driven by a single 2.5s controller):
///   0.00 → 0.28  jiggle phase — all strips wiggle under the fist.
///   0.28 → 0.55  settle + draw — jiggle stops, the chosen strip retracts
///                (visible length shrinks), revealing the short straw.
///   0.55 → 1.00  label phase — Caveat "μοιράζει @X" fades in.
///
/// Dismisses on tap or after [holdDuration] once the animation finishes.
class ShortStrawDraw extends StatefulWidget {
  const ShortStrawDraw({
    super.key,
    required this.seats,
    required this.dealerSeat,
    required this.dealerName,
    required this.onDone,
    this.holdDuration = const Duration(milliseconds: 1600),
  });

  /// Seats participating, in seat order. e.g. `[0, 1, 2, 3]` for a 4p game.
  final List<int> seats;

  /// Which seat drew the short straw (i.e. who deals).
  final int dealerSeat;

  /// Display name for the dealer. Used in the reveal label.
  final String dealerName;

  final VoidCallback onDone;

  /// How long to hold the reveal before auto-dismissing.
  final Duration holdDuration;

  @override
  State<ShortStrawDraw> createState() => _ShortStrawDrawState();
}

class _ShortStrawDrawState extends State<ShortStrawDraw>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _dismissing = false;

  // Per-strip jitter seeds keep each paper strip feeling like a distinct
  // piece of paper rather than a copy. Seeded per seat so animations are
  // stable across rebuilds.
  late final List<double> _jitterPhases;

  @override
  void initState() {
    super.initState();
    _jitterPhases = [
      for (final s in widget.seats) (s * 1.7) % math.pi,
    ];
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
    _ctrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed && !_dismissing) {
        await Future<void>.delayed(widget.holdDuration);
        if (!mounted || _dismissing) return;
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissing) return;
    _dismissing = true;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: AppTheme.pageBg.withValues(alpha: 0.92),
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;
            return _Reveal(
              t: t,
              seats: widget.seats,
              dealerSeat: widget.dealerSeat,
              dealerName: widget.dealerName,
              jitterPhases: _jitterPhases,
            );
          },
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.t,
    required this.seats,
    required this.dealerSeat,
    required this.dealerName,
    required this.jitterPhases,
  });

  final double t;
  final List<int> seats;
  final int dealerSeat;
  final String dealerName;
  final List<double> jitterPhases;

  // Phase boundaries inside the 0..1 controller range.
  static const _jiggleEnd = 0.28;
  static const _drawEnd = 0.55;

  double get _jigglePhase =>
      t < _jiggleEnd ? (t / _jiggleEnd).clamp(0.0, 1.0) : 1.0;
  double get _drawProgress => t < _jiggleEnd
      ? 0.0
      : t < _drawEnd
          ? ((t - _jiggleEnd) / (_drawEnd - _jiggleEnd)).clamp(0.0, 1.0)
          : 1.0;
  double get _labelProgress =>
      t < _drawEnd ? 0.0 : ((t - _drawEnd) / (1.0 - _drawEnd)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.shortStrawTitle,
          style: const TextStyle(fontFamily: MerakiFonts.geistMonoFamily,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            color: AppTheme.terra,
          ),
        ),
        const SizedBox(height: AppTheme.space5),
        _FistAndStraws(
          seats: seats,
          dealerSeat: dealerSeat,
          jigglePhase: _jigglePhase,
          drawProgress: _drawProgress,
          jitterPhases: jitterPhases,
        ),
        const SizedBox(height: AppTheme.space5),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 240),
          opacity: _labelProgress,
          child: Column(
            children: [
              Text(
                'μοιράζει',
                style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                  fontSize: 20,
                  color: AppTheme.inkSoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dealerName,
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                  fontSize: 42,
                  color: AppTheme.ink,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FistAndStraws extends StatelessWidget {
  const _FistAndStraws({
    required this.seats,
    required this.dealerSeat,
    required this.jigglePhase,
    required this.drawProgress,
    required this.jitterPhases,
  });

  final List<int> seats;
  final int dealerSeat;
  final double jigglePhase;
  final double drawProgress;
  final List<double> jitterPhases;

  static const double _canvasWidth = 280;
  static const double _fistHeight = 18;
  static const double _strawHeight = 150;
  static const double _strawWidth = 22;
  static const double _dealerShrinkTo = 0.55; // short straw ends at 55% height

  @override
  Widget build(BuildContext context) {
    final n = seats.length;
    final totalStrawsWidth = n * _strawWidth + (n - 1) * 16;
    final leftMargin = (_canvasWidth - totalStrawsWidth) / 2;

    return SizedBox(
      width: _canvasWidth,
      height: _fistHeight + _strawHeight + 28,
      child: Stack(
        children: [
          // Fist bar
          Positioned(
            left: 24,
            right: 24,
            top: 0,
            child: Container(
              height: _fistHeight,
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(3),
                boxShadow: AppTheme.shadowSm,
              ),
            ),
          ),
          // Straws
          for (var i = 0; i < n; i++)
            _Straw(
              seatLabel: seats[i] + 1,
              isDealer: seats[i] == dealerSeat,
              jigglePhase: jigglePhase,
              drawProgress: drawProgress,
              jitterPhase: jitterPhases[i],
              left: leftMargin + i * (_strawWidth + 16),
              top: _fistHeight - 2, // tuck into fist
              shrinkTo: _dealerShrinkTo,
              baseHeight: _strawHeight,
              width: _strawWidth,
            ),
        ],
      ),
    );
  }
}

class _Straw extends StatelessWidget {
  const _Straw({
    required this.seatLabel,
    required this.isDealer,
    required this.jigglePhase,
    required this.drawProgress,
    required this.jitterPhase,
    required this.left,
    required this.top,
    required this.shrinkTo,
    required this.baseHeight,
    required this.width,
  });

  final int seatLabel;
  final bool isDealer;
  final double jigglePhase;
  final double drawProgress;
  final double jitterPhase;
  final double left;
  final double top;
  final double shrinkTo;
  final double baseHeight;
  final double width;

  @override
  Widget build(BuildContext context) {
    // Jiggle: sine wave that attenuates as jigglePhase approaches 1 (settle).
    final jiggleAmp = (1 - Curves.easeOut.transform(jigglePhase)) * 3.5;
    final jiggleRot = math.sin(jitterPhase + jigglePhase * math.pi * 6) *
        (jiggleAmp * math.pi / 180);

    // Dealer straw shrinks from 1.0 → shrinkTo as drawProgress goes 0→1.
    final heightFactor = isDealer
        ? 1.0 - (1.0 - shrinkTo) * Curves.easeOut.transform(drawProgress)
        : 1.0;
    final effectiveHeight = baseHeight * heightFactor;

    // Subtle highlight for the dealer after the draw completes.
    final dealerGlow = isDealer ? drawProgress : 0.0;

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: jiggleRot,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // The straw itself — a paper strip with tiny seat label on top.
            Container(
              width: width,
              height: effectiveHeight,
              decoration: BoxDecoration(
                color: AppTheme.paper,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(3),
                ),
                border: Border.all(
                  color: isDealer && dealerGlow > 0.3
                      ? AppTheme.terra.withValues(alpha: 0.6)
                      : AppTheme.border,
                  width: isDealer && dealerGlow > 0.3 ? 1.4 : 1,
                ),
                boxShadow: AppTheme.shadowSm,
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$seatLabel',
                style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                  fontSize: 9,
                  letterSpacing: 1,
                  color: isDealer && dealerGlow > 0.3
                      ? AppTheme.terra
                      : AppTheme.inkFaint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
