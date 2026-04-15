import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../services/estimation_service.dart';
import '../../services/supabase_client.dart';
import '../../theme/app_background.dart';
import '../../theme/app_theme.dart';
import 'estimation_game_screen.dart';

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

  final Map<String, String> _usernameCache = {};

  late final Stream<List<Map<String, dynamic>>> _gameStream;
  late final Stream<List<Map<String, dynamic>>> _playersStream;

  bool _starting = false;
  bool _navigatedToGame = false;

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
    if (mounted) setState(() {});
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
      final playerIds = _seats.map((s) => s['player_id'] as String).toList();
      await EstimationService().createRoundEntries(
        gameId: widget.gameId,
        roundNumber: 1,
        cardsThisRound: 1,
        playerIds: playerIds,
      );

      await SupabaseBootstrap.client
          .from('estimation_games')
          .update({'status': 'active'})
          .eq('id', widget.gameId);
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

  void _navigateToGameIfActive() {
    if (_navigatedToGame) return;
    if (_game == null) return;
    final status = _game!['status'] as String;
    if (status != 'active') return;
    _navigatedToGame = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => EstimationGameScreen(gameId: widget.gameId),
        ),
      );
    });
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

  void _showLeaveDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
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
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Βγες'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _showLeaveDialog();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                _navigateToGameIfActive();
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
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.space5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppTheme.space3),

                            // ── Room code card ──
                            _RoomCodeCard(code: code),

                            const SizedBox(height: AppTheme.space5),

                            // ── Players header ──
                            Row(
                              children: [
                                const AppSectionLabel('Παίκτες'),
                                const Spacer(),
                                Text(
                                  '${_seats.length} / $playerCount',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.gold,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.space3),

                            // ── Seat list ──
                            Expanded(
                              child: ListView.separated(
                                itemCount: playerCount,
                                separatorBuilder: (_, __) => const SizedBox(
                                  height: AppTheme.space2,
                                ),
                                itemBuilder: (_, i) => _buildSeatTile(i),
                              ),
                            ),

                            const SizedBox(height: AppTheme.space4),

                            // ── Action ──
                            if (status == 'waiting') _buildActionArea(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    if (_isHost) {
      return FilledButton(
        onPressed: _isFull && !_starting ? _startGame : null,
        child: _starting
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(_isFull ? 'Ξεκίνα το παιχνίδι' : 'Περιμένω παίκτες…'),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppTheme.textTertiary,
            ),
          ),
          SizedBox(width: AppTheme.space3),
          Text(
            'Περιμένοντας τον host…',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
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
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.goldMuted : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isMe
              ? AppTheme.gold.withValues(alpha: 0.4)
              : isEmpty
                  ? AppTheme.border
                  : AppTheme.borderAccent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isEmpty
                  ? AppTheme.surfaceElevated
                  : AppTheme.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            alignment: Alignment.center,
            child: Text(
              '${seatIndex + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isEmpty ? AppTheme.textTertiary : AppTheme.gold,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: isEmpty
                ? const Text(
                    'Αναμονή…',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 14,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        username != null ? '@$username' : '…',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isMe ? AppTheme.gold : AppTheme.textPrimary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: AppTheme.space2),
                        const Text(
                          'εσύ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (isHostSeat && !isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Text(
                'HOST',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          if (!isEmpty && !isHostSeat)
            const Icon(
              Icons.check_circle,
              size: 16,
              color: AppTheme.success,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RoomCodeCard extends StatelessWidget {
  const _RoomCodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Text(
            'ΚΩΔΙΚΟΣ ΔΩΜΑΤΙΟΥ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Αντιγράφτηκε'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space3,
                  vertical: AppTheme.space2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 14,
                        color: AppTheme.gold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space3),
                    const Icon(
                      Icons.copy_outlined,
                      size: 18,
                      color: AppTheme.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          const Text(
            'Μοιράσου με τους παίκτες',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
