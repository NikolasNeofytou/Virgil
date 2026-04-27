import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/game_award.dart';
import '../../../theme/app_theme.dart';

/// Static, animation-free poster of the game result, sized for capture →
/// PNG → share-sheet. Width is fixed at 360 logical pixels; capture at
/// pixelRatio: 3.0 for a 1080-wide image that looks crisp on phones.
class EstimationShareCard extends StatelessWidget {
  const EstimationShareCard({
    super.key,
    required this.sessionLabel,
    required this.winnerName,
    required this.winnerScore,
    required this.standings,
    required this.awards,
    required this.narration,
    required this.gameDate,
  });

  final String sessionLabel;
  final String winnerName;
  final int winnerScore;
  final List<EstimationStanding> standings;
  final List<GameAward> awards;
  final String? narration;
  final DateTime gameDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: const BoxDecoration(color: AppTheme.paper),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space6,
        vertical: AppTheme.space7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Masthead(),
          const SizedBox(height: AppTheme.space5),
          Center(
            child: Text(
              sessionLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.5,
                color: AppTheme.inkSoft,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space5),
          _WinnerBlock(name: winnerName, score: winnerScore),
          const SizedBox(height: AppTheme.space6),
          const _SectionLabel('ΚΑΤΑΤΑΞΗ · FINAL'),
          const SizedBox(height: AppTheme.space3),
          for (var i = 0; i < standings.length; i++)
            _StandingRow(
              rank: i + 1,
              name: standings[i].name,
              score: standings[i].score,
              isWinner: i == 0,
            ),
          if (narration != null) ...[
            const SizedBox(height: AppTheme.space5),
            const _SectionLabel('ΝΑΡΡΗΣΗ · NIGHT NOTE'),
            const SizedBox(height: AppTheme.space3),
            _NarrationCard(text: narration!),
          ],
          if (awards.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space5),
            const _SectionLabel('ΒΡΑΒΕΙΑ · AWARDS'),
            const SizedBox(height: AppTheme.space3),
            for (var i = 0; i < awards.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == awards.length - 1 ? 0 : AppTheme.space2,
                ),
                child: _AwardCard(award: awards[i]),
              ),
          ],
          const SizedBox(height: AppTheme.space6),
          _Footer(date: gameDate),
        ],
      ),
    );
  }
}

class EstimationStanding {
  const EstimationStanding({required this.name, required this.score});
  final String name;
  final int score;
}

class _Masthead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'A GUIDE FOR THE TABLE',
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 3.5,
            color: AppTheme.terra,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Container(height: 1, color: AppTheme.ink),
        const SizedBox(height: 3),
        Container(height: 1, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space3),
        Text(
          'VIRGIL',
          textAlign: TextAlign.center,
          style: GoogleFonts.gloock(
            fontSize: 38,
            color: AppTheme.ink,
            height: 1.0,
            letterSpacing: 4,
          ),
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
        Text(
          'ΝΙΚΗΤΗΣ · WINNER',
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            color: AppTheme.terra,
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.gloock(
            fontSize: 42,
            color: AppTheme.ink,
            height: 1.05,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 60),
          height: 28,
          decoration: const BoxDecoration(color: AppTheme.terra),
          alignment: Alignment.center,
          child: Text(
            '$score πόντοι',
            style: GoogleFonts.gloock(
              fontSize: 16,
              color: AppTheme.paper,
              height: 1.0,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
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

class _NarrationCard extends StatelessWidget {
  const _NarrationCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space5,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.terra.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.kalam(
          fontSize: 14,
          color: AppTheme.ink,
          height: 1.55,
        ),
      ),
    );
  }
}

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
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              award.emoji,
              style: const TextStyle(fontSize: 20, height: 1),
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
                    fontSize: 15,
                    color: AppTheme.ink,
                    height: 1.0,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  award.description,
                  style: GoogleFonts.kalam(
                    fontSize: 12,
                    color: AppTheme.inkSoft,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          Text(
            award.username,
            style: GoogleFonts.caveat(
              fontSize: 16,
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

class _Footer extends StatelessWidget {
  const _Footer({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: AppTheme.border),
        const SizedBox(height: AppTheme.space3),
        Text(
          'virgil · ${DateFormat('d MMM yyyy').format(date.toLocal())}',
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.5,
            color: AppTheme.inkFaint,
          ),
        ),
      ],
    );
  }
}
