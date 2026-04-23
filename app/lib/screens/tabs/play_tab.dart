import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_background.dart';
import '../../theme/app_theme.dart';
import '../estimation/create_room_screen.dart';
import '../estimation/join_room_screen.dart';

/// Play tab — the Virgil masthead above a paper hero card for the score
/// companion, with Phase B modes listed as locked sheets below.
class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.space5,
            AppTheme.space5,
            AppTheme.space5,
            AppTheme.space6,
          ),
          children: [
            const _Masthead(),
            const SizedBox(height: AppTheme.space6),

            // Hero
            const AppSectionLabel('§ 01 · LIVE', showRule: true),
            const SizedBox(height: AppTheme.space3),
            _HeroCard(
              title: 'Score Companion',
              subtitle: 'το παιχνίδι μπάζας, χωρίς μολύβι',
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
            const AppSectionLabel('§ 02 · COMING SOON', showRule: true),
            const SizedBox(height: AppTheme.space3),
            const _ComingSoonRow(
              title: 'Γρήγορο Παιχνίδι',
              subtitle: 'matchmaking με ELO',
            ),
            const SizedBox(height: AppTheme.space2),
            const _ComingSoonRow(
              title: 'Tichu Online',
              subtitle: '4 παίκτες, πραγματικό τραπέζι',
            ),
            const SizedBox(height: AppTheme.space2),
            const _ComingSoonRow(
              title: 'Πιλόττα',
              subtitle: 'η Κυπριακή κλασική',
            ),
          ],
        ),
      ),
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top stamps
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
        // Wordmark
        Center(
          child: Text(
            'Virgil',
            style: GoogleFonts.gloock(
              fontSize: 64,
              color: AppTheme.ink,
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: Text(
            'a guide for the table',
            style: GoogleFonts.caveat(
              fontSize: 20,
              color: AppTheme.terra,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 2, color: AppTheme.ink),
      ],
    );
  }
}

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
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.gloock(
              fontSize: 28,
              color: AppTheme.ink,
              height: 1.1,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.caveat(
              fontSize: 20,
              color: AppTheme.terra,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          // Dashed-style divider
          Container(height: 1, color: AppTheme.border),
          const SizedBox(height: AppTheme.space3),
          Text(
            tagline,
            style: GoogleFonts.kalam(
              fontSize: 13,
              color: AppTheme.inkSoft,
              height: 1.5,
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
  const _ComingSoonRow({required this.title, required this.subtitle});

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
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.caveat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.inkSoft,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.kalam(
                    fontSize: 12,
                    color: AppTheme.inkFaint,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.paperEdge.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              'SOON',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 2,
                color: AppTheme.inkFaint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
