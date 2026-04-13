import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../services/supabase_client.dart';
import '../../theme/app_theme.dart';

/// Room lobby — players see the room code, watch seats fill in realtime, and
/// the host starts the game once all seats are taken.
class RoomLobbyScreen extends ConsumerStatefulWidget {
  const RoomLobbyScreen({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends ConsumerState<RoomLobbyScreen> {
  Map<String, dynamic>? _game;
  List<Map<String, dynamic>> _seats = const [];

  /// player_id → username cache so we don't re-query on every stream tick.
  final Map<String, String> _usernameCache = {};

  late final Stream<List<Map<String, dynamic>>> _gameStream;
  late final Stream<List<Map<String, dynamic>>> _playersStream;

  bool _starting = false;

  @override
  void initState() {
    super.initState();
    final client = SupabaseBootstrap.client;
    _gameStream = client
        .from('estimation_games')
        .stream(primaryKey: ['id'])
        .eq('id', widget.gameId);
    _playersStream = client
        .from('estimation_players')
        .stream(primaryKey: ['id'])
        .eq('game_id', widget.gameId)
        .order('seat');
  }

  Future<void> _resolveUsernames(List<Map<String, dynamic>> rows) async {
    final missing = <String>[];
    for (final row in rows) {
      final pid = row['player_id'] as String;
      if (!_usernameCache.containsKey(pid)) missing.add(pid);
    }
    if (missing.isEmpty) return;

    final results = await SupabaseBootstrap.client
        .from('players')
        .select('id, username')
        .inFilter('id', missing);

    for (final r in results) {
      _usernameCache[r['id'] as String] = r['username'] as String;
    }
  }

  bool get _isHost {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null || _seats.isEmpty) return false;
    final seat0 = _seats.firstWhere(
      (s) => s['seat'] == 0,
      orElse: () => const {},
    );
    return seat0.isNotEmpty && seat0['player_id'] == userId;
  }

  bool get _isFull {
    if (_game == null) return false;
    return _seats.length >= (_game!['player_count'] as int);
  }

  Future<void> _startGame() async {
    setState(() => _starting = true);
    try {
      await SupabaseBootstrap.client
          .from('estimation_games')
          .update({'status': 'active'})
          .eq('id', widget.gameId);
      // A2 will navigate to the prediction screen on status change.
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _leaveRoom() async {
    final userId = SupabaseBootstrap.client.auth.currentUser?.id;
    if (userId == null) return;
    await SupabaseBootstrap.client
        .from('estimation_players')
        .delete()
        .eq('game_id', widget.gameId)
        .eq('player_id', userId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showLeaveDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Δωμάτιο'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _showLeaveDialog,
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _gameStream,
          builder: (context, gSnap) {
            if (gSnap.hasData && gSnap.data!.isNotEmpty) {
              _game = gSnap.data!.first;
            }
            if (_game == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final code = _game!['room_code'] as String;
            final playerCount = _game!['player_count'] as int;
            final status = _game!['status'] as String;

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _playersStream,
              builder: (context, pSnap) {
                if (pSnap.hasData) {
                  _seats = pSnap.data!;
                  _resolveUsernames(_seats);
                }
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Room code banner
                      const Text(
                        'Κωδικός δωματίου',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Αντιγράφτηκε!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              code,
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 14,
                                color: AppTheme.gold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.copy_rounded,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Πάτα για αντιγραφή',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Player count header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people, size: 20, color: AppTheme.gold),
                          const SizedBox(width: 8),
                          Text(
                            'Παίκτες ${_seats.length} / $playerCount',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Seat list
                      Expanded(
                        child: ListView.separated(
                          itemCount: playerCount,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _buildSeatTile(i),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Start / waiting button
                      if (status == 'waiting') ...[
                        if (_isHost)
                          FilledButton(
                            onPressed: _isFull && !_starting ? _startGame : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.gold,
                              foregroundColor: AppTheme.background,
                              disabledBackgroundColor:
                                  AppTheme.gold.withValues(alpha: 0.3),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _starting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    _isFull
                                        ? 'Ξεκίνα το παιχνίδι'
                                        : 'Περιμένω παίκτες...',
                                  ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Ο host θα ξεκινήσει...',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                      ],
                      if (status == 'active')
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Το παιχνίδι ξεκίνησε!',
                            style: TextStyle(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeatTile(int seatIndex) {
    final seated = _seats.firstWhere(
      (s) => s['seat'] == seatIndex,
      orElse: () => const {},
    );
    final isEmpty = seated.isEmpty;
    final playerId = isEmpty ? null : seated['player_id'] as String;
    final username = playerId != null ? _usernameCache[playerId] : null;
    final currentUserId = ref.read(currentUserIdProvider);
    final isMe = playerId == currentUserId;
    final isHostSeat = seatIndex == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isEmpty
            ? AppTheme.surface
            : isMe
                ? AppTheme.gold.withValues(alpha: 0.1)
                : AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEmpty
              ? AppTheme.textSecondary.withValues(alpha: 0.15)
              : isMe
                  ? AppTheme.gold.withValues(alpha: 0.5)
                  : AppTheme.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Seat number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isEmpty
                  ? AppTheme.surface
                  : AppTheme.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${seatIndex + 1}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isEmpty ? AppTheme.textSecondary : AppTheme.gold,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name
          Expanded(
            child: isEmpty
                ? Text(
                    'Αναμονή...',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username != null ? '@$username' : '...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isMe ? AppTheme.gold : AppTheme.textPrimary,
                        ),
                      ),
                      if (isMe)
                        const Text(
                          'εσύ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
          ),

          // Host badge
          if (isHostSeat && !isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HOST',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gold,
                  letterSpacing: 1,
                ),
              ),
            ),

          // Ready check
          if (!isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle,
                size: 20,
                color: AppTheme.success.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }

  void _showLeaveDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text('Αποχώρηση;'),
        content: const Text('Θα βγεις από το δωμάτιο.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Άκυρο'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _leaveRoom();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.danger,
            ),
            child: const Text('Βγες'),
          ),
        ],
      ),
    );
  }
}
