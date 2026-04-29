import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/meraki_tokens.dart';

/// Status pill — small ALL-CAPS Geist Mono label inside a tinted pill.
/// Matches the deck's "ONLINE / LIVE / SOON / EZY" badge family.
///
/// Variants pick the tone:
///
/// * `success` — myrtle (online, free, gentle confirms).
/// * `accent`  — coral (live, your turn, action-tied).
/// * `reward`  — ochre (wins, premium tier).
/// * `neutral` — bone (status / metadata, no emphasis).
///
/// `dot: true` prepends a small filled circle in the foreground tone — the
/// "quiet presence" indicator from the Lobby spec.
enum VirgilChipVariant { success, accent, reward, neutral }

class VirgilChip extends StatelessWidget {
  const VirgilChip({
    super.key,
    required this.label,
    this.variant = VirgilChipVariant.neutral,
    this.dot = false,
  });

  final String label;
  final VirgilChipVariant variant;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (variant) {
      VirgilChipVariant.success => (tokens.myrtleMuted, scheme.secondary),
      VirgilChipVariant.accent => (tokens.coralMuted, scheme.primary),
      VirgilChipVariant.reward => (tokens.ochreMuted, tokens.ochre),
      VirgilChipVariant.neutral => (tokens.bone, scheme.onSurface),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space3,
        vertical: AppTheme.space1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppTheme.space2),
          ],
          Text(
            label.toUpperCase(),
            style: tokens.eyebrow.copyWith(color: fg, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
