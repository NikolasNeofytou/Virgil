import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../estimation/create_room_screen.dart';
import '../estimation/join_room_screen.dart';

/// The Play tab. In Phase A the only live card is the Estimation Score
/// Companion. Quick Match / Create Room / Join Room buttons are placeholders
/// until Phase B (Tichu) ships.
class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tichu Cyprus'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _DisabledCard(
            title: 'Γρήγορο Παιχνίδι',
            subtitle: 'Σύντομα — Phase B',
            icon: Icons.bolt,
          ),
          const SizedBox(height: 12),
          const _DisabledCard(
            title: 'Δημιούργησε δωμάτιο',
            subtitle: 'Σύντομα — Phase B',
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 12),
          const _DisabledCard(
            title: 'Μπες σε δωμάτιο',
            subtitle: 'Σύντομα — Phase B',
            icon: Icons.login,
          ),
          const SizedBox(height: 28),
          const Text(
            'ESTIMATION',
            style: TextStyle(
              color: AppTheme.gold,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _ScoreCompanionCard(
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
        ],
      ),
    );
  }
}

class _ScoreCompanionCard extends StatelessWidget {
  const _ScoreCompanionCard({required this.onCreate, required this.onJoin});

  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: AppTheme.gold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Score Companion',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Παρακολούθηση score για Estimation · 2-4 παίκτες',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onCreate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Δημιούργησε'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onJoin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
                  ),
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

class _DisabledCard extends StatelessWidget {
  const _DisabledCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),),
                  Text(subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
