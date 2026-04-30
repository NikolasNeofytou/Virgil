import 'package:flutter/animation.dart';

/// Meraki motion language — deck §08 step 03. Names the register the
/// rebrand has been using ad-hoc since the lobby ship: 200–260ms with
/// `Curves.easeOutCubic` for entrances, `Curves.easeIn` for exits.
///
/// "Restrained, decelerating, no overshoot" — same editorial tone as
/// the type and the palette. Bigger, fancier motion (laurel reveals,
/// shuffle sequences, Hero transitions) lives in its own widget; this
/// file just gives ordinary transitions a shared vocabulary.
class MerakiMotion {
  MerakiMotion._();

  // ── Durations ──────────────────────────────────────────────────────────
  /// Micro-interactions — chip toggles, snackbar swaps, focus rings.
  static const Duration brisk = Duration(milliseconds: 180);

  /// Standard transitions — page routes, AnimatedSwitcher, sheet appear,
  /// value swaps. The existing AppRoute (220ms) and number-picker (260)
  /// converge here.
  static const Duration normal = Duration(milliseconds: 240);

  /// Hero reveals and scene shifts — winner laurel, narration unveil.
  /// Set deliberately slower than `normal` so the user feels the gear
  /// change.
  static const Duration slow = Duration(milliseconds: 560);

  // ── Curves ─────────────────────────────────────────────────────────────
  /// Default entrance curve — restrained deceleration; nothing arrives
  /// in a hurry.
  static const Curve entrance = Curves.easeOutCubic;

  /// Default exit curve — gentle acceleration into departure.
  static const Curve exit = Curves.easeIn;

  /// Bidirectional / continuous motion (scrub-friendly).
  static const Curve serene = Curves.easeInOutCubic;
}
