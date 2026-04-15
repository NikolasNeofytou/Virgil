import 'package:flutter/material.dart';

import '../../services/estimation_service.dart';
import '../../theme/app_background.dart';
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
    final maxCards = 52 ~/ _playerCount;
    final totalRounds = 2 * maxCards - 1;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Νέο δωμάτιο')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppTheme.space4),
                    const AppSectionLabel('Αριθμός παικτών'),
                    const SizedBox(height: AppTheme.space3),
                    Row(
                      children: [
                        for (final n in [2, 3, 4]) ...[
                          Expanded(
                            child: _CountOption(
                              count: n,
                              selected: _playerCount == n,
                              onTap: () => setState(() => _playerCount = n),
                            ),
                          ),
                          if (n != 4) const SizedBox(width: AppTheme.space3),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppTheme.space5),

                    // Round preview
                    Container(
                      padding: const EdgeInsets.all(AppTheme.space4),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          _StatChip(
                            label: 'Κάρτες/γύρο',
                            value: 'έως $maxCards',
                          ),
                          const SizedBox(width: AppTheme.space3),
                          Container(
                            width: 1,
                            height: 32,
                            color: AppTheme.border,
                          ),
                          const SizedBox(width: AppTheme.space3),
                          _StatChip(
                            label: 'Σύνολο γύρων',
                            value: '$totalRounds',
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    FilledButton(
                      onPressed: _creating ? null : _create,
                      child: _creating
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Δημιούργησε δωμάτιο'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppTheme.space3),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountOption extends StatelessWidget {
  const _CountOption({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.goldMuted : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: selected ? AppTheme.gold : AppTheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: selected ? AppTheme.gold : AppTheme.textPrimary,
              letterSpacing: -1,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
