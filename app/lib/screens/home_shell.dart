import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tabs/friends_tab.dart';
import 'tabs/leaderboard_tab.dart';
import 'tabs/play_tab.dart';
import 'tabs/profile_tab.dart';

/// Bottom-tab shell matching the plan's "Bottom Tab Bar (Portrait)".
/// Play · Friends · Leaderboard · Profile.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    PlayTab(),
    FriendsTab(),
    LeaderboardTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.gold.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style, color: AppTheme.gold),
            label: 'Παίξε',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppTheme.gold),
            label: 'Φίλοι',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard, color: AppTheme.gold),
            label: 'Κατάταξη',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.gold),
            label: 'Προφίλ',
          ),
        ],
      ),
    );
  }
}
