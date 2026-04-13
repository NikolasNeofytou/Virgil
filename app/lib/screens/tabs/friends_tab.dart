import 'package:flutter/material.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(A1): friends list, pending requests, search, invite.
    return Scaffold(
      appBar: AppBar(title: const Text('Φίλοι')),
      body: const Center(child: Text('Σύντομα')),
    );
  }
}
