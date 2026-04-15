import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Κατάταξη')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.leaderboard_outlined,
                size: 28,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              'Σύντομα',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.space1),
            const Text(
              'ELO κατάταξη · top 50',
              style: TextStyle(color: AppTheme.textTertiary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
