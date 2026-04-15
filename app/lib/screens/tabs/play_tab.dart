import 'package:flutter/material.dart';

import '../../theme/app_background.dart';
import '../../theme/app_theme.dart';
import '../estimation/create_room_screen.dart';
import '../estimation/join_room_screen.dart';

/// Play tab. Phase A shows the Estimation Score Companion prominently.
/// Phase B buttons are visible but disabled ("Coming soon").
class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Tichu Cyprus')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space5,
          AppTheme.space3,
          AppTheme.space5,
          AppTheme.space6,
        ),
        children: [
          // ── Hero: Score Companion ──
          const AppSectionLabel('Phase A · Live'),
          const SizedBox(height: AppTheme.space3),
          _HeroCard(
            title: 'Score Companion',
            subtitle: 'Παρακολούθηση score για Estimation',
            tagline: '2–4 παίκτες · peer validation · αυτόματο scoring',
            onCreate: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const CreateRoomScreen(),
              ),
            ),
            onJoin: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const JoinRoomScreen(),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.space6),

          // ── Coming soon ──
          const AppSectionLabel('Phase B · Coming soon'),
          const SizedBox(height: AppTheme.space3),
          const _ComingSoonRow(
            icon: Icons.bolt_outlined,
            title: 'Γρήγορο Παιχνίδι',
            subtitle: 'Matchmaking με ELO',
          ),
          const SizedBox(height: AppTheme.space2),
          const _ComingSoonRow(
            icon: Icons.add_box_outlined,
            title: 'Δημιούργησε δωμάτιο',
            subtitle: 'Παίξε με φίλους',
          ),
          const SizedBox(height: AppTheme.space2),
          const _ComingSoonRow(
            icon: Icons.login_outlined,
            title: 'Μπες σε δωμάτιο',
            subtitle: 'Με 4-ψήφιο κωδικό',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.tagline,
    required this.onCreate,
    required this.onJoin,
  });

  final String title;
  final String subtitle;
  final String tagline;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space5),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.goldMuted,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: AppTheme.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space3,
              vertical: AppTheme.space2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              tagline,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space5),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onCreate,
                  child: const Text('Δημιούργησε'),
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: OutlinedButton(
                  onPressed: onJoin,
                  child: const Text('Μπες'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComingSoonRow extends StatelessWidget {
  const _ComingSoonRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textTertiary),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space2,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Text(
              'SOON',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
