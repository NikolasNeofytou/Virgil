import 'package:flutter/material.dart';

/// Meraki-rebrand button. Two variants:
///
/// * `primary` — coral pill with italic-Fraunces verb. The "Take your seat /
///   Sit / Continue" register from the deck.
/// * `ghost` — coral italic-Fraunces text button, no fill. The same register,
///   without the pill weight, for inline actions.
///
/// Wraps Material's `FilledButton` / `TextButton` — typography and color come
/// from the AppTheme. The wrapper enforces the italic-verb convention and
/// adds the optional trailing arrow ("Sit →") that the deck uses on
/// invitational verbs.
enum VirgilButtonVariant { primary, ghost }

class VirgilButton extends StatelessWidget {
  const VirgilButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = VirgilButtonVariant.primary,
    this.trailingArrow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final VirgilButtonVariant variant;
  final bool trailingArrow;

  @override
  Widget build(BuildContext context) {
    final text = trailingArrow ? '$label →' : label;
    final child = Text(text);
    return switch (variant) {
      VirgilButtonVariant.primary =>
        FilledButton(onPressed: onPressed, child: child),
      VirgilButtonVariant.ghost =>
        TextButton(onPressed: onPressed, child: child),
    };
  }
}
