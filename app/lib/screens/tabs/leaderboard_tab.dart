import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

/// Placeholder leaderboard — a paper receipt that announces the coming
/// feature without pretending to have data. Replaces the old dark-themed
/// "coming soon" card.
class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Κατάταξη')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space5,
          AppTheme.space5,
          AppTheme.space5,
          AppTheme.space6,
        ),
        children: [
          // Page-level masthead eyebrow + Gloock title.
          Center(
            child: Text(
              'VOL. I · APR 2026 · KAFENEIO',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(height: 1.5, color: AppTheme.ink),
          const SizedBox(height: 2),
          Container(height: 0.5, color: AppTheme.ink),
          const SizedBox(height: AppTheme.space4),
          Center(
            child: Text(
              'Κατάταξη',
              style: GoogleFonts.gloock(
                fontSize: 44,
                color: AppTheme.ink,
                letterSpacing: -0.6,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'τα σκορ του τραπεζιού',
              style: GoogleFonts.caveat(
                fontSize: 20,
                color: AppTheme.terra,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.space7),

          // Receipt-style placeholder
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space5,
              vertical: AppTheme.space6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.paper,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.shadowMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'σύντομα',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.gloock(
                    fontSize: 36,
                    color: AppTheme.ink,
                    height: 1.0,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AppTheme.space2),
                Center(
                  child: Container(
                    height: 1,
                    width: 60,
                    color: AppTheme.terra.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppTheme.space3),
                Text(
                  'εδώ θα δεις όλους τους παίκτες '
                  'ταξινομημένους κατά πόντους — '
                  'ολική κατάταξη, τελευταίες νίκες, '
                  'στρογγυλές ∙ στοιχεία από όλα τα κλειστά παιχνίδια.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.kalam(
                    fontSize: 14,
                    color: AppTheme.inkSoft,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: AppTheme.space4),
                Text(
                  '— FIN —',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    letterSpacing: 3,
                    color: AppTheme.inkFaint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
