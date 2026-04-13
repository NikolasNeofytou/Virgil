import 'package:flutter/material.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(B5): global / friends / Cyprus ELO leaderboard.
    return Scaffold(
      appBar: AppBar(title: const Text('Κατάταξη')),
      body: const Center(child: Text('Σύντομα')),
    );
  }
}
