import 'package:flutter/material.dart';

import '../../services/estimation_service.dart';
import '../../theme/app_theme.dart';
import 'room_lobby_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  int _playerCount = 4;
  bool _creating = false;
  String? _error;
  final _service = EstimationService();

  Future<void> _create() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final gameId = await _service.createGame(playerCount: _playerCount);
      if (!mounted) return;
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => RoomLobbyScreen(gameId: gameId),
        ),
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Νέο δωμάτιο')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Πόσοι παίκτες;',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 4, label: Text('4')),
              ],
              selected: {_playerCount},
              onSelectionChanged: (s) => setState(() => _playerCount = s.first),
            ),
            const SizedBox(height: 24),
            Text(
              _roundsSummary(_playerCount),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _creating ? null : _create,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _creating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Δημιούργησε δωμάτιο'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppTheme.danger)),
            ],
          ],
        ),
      ),
    );
  }

  static String _roundsSummary(int playerCount) {
    final maxCards = 52 ~/ playerCount;
    final totalRounds = 2 * maxCards - 1;
    return 'Μέχρι $maxCards κάρτες/γύρο  ·  $totalRounds γύροι συνολικά';
  }
}
