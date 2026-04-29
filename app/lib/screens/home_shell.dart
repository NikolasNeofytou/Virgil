import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_background.dart';
import '../theme/virgil_icons.dart';
import 'tabs/friends_tab.dart';
import 'tabs/leaderboard_tab.dart';
import 'tabs/play_tab.dart';
import 'tabs/profile_tab.dart';

/// Bottom-tab shell. Play · Friends · Leaderboard · Profile.
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
    final l10n = AppLocalizations.of(context)!;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(index: _index, children: _tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const VirgilIcon(VirgilIconName.home),
              label: l10n.tabPlay,
            ),
            NavigationDestination(
              icon: const VirgilIcon(VirgilIconName.rooms),
              label: l10n.tabFriends,
            ),
            NavigationDestination(
              icon: const VirgilIcon(VirgilIconName.stats),
              label: l10n.tabLeaderboard,
            ),
            NavigationDestination(
              icon: const VirgilIcon(VirgilIconName.profile),
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
