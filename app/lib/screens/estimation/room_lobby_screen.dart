import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_providers.dart';
import '../../services/estimation_service.dart';
import '../../services/supabase_client.dart';
import '../../theme/app_background.dart';
import '../../theme/app_route.dart';
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

  // Session-name editing state for the host. Non-host players see whatever's
  // already on the game row; the host can write to it (debounced) and other
  // players see the change live via [_gameStream].
  final TextEditingController _sessionNameCtrl = TextEditingController();
  String _lastSyncedSessionName = '';
  Timer? _sessionNameDebounce;

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

  @override
  void dispose() {
    _sessionNameDebounce?.cancel();
    _sessionNameCtrl.dispose();
    super.dispose();
  }

  void _onSessionNameChanged(String value) {
    _sessionNameDebounce?.cancel();
    _sessionNameDebounce = Timer(const Duration(milliseconds: 500), () {
      final trimmed = value.trim();
      if (trimmed == _lastSyncedSessionName) return;
      _lastSyncedSessionName = trimmed;
      EstimationService().updateSessionName(
        gameId: widget.gameId,
        name: trimmed.isEmpty ? null : trimmed,
      );
    });
  }

  /// Mirror remote session_name into the controller for non-host players,
  /// and for the host on first load. Skip while the host is actively typing
  /// (detected via _lastSyncedSessionName equality).
  void _syncSessionNameFromRemote(String? remote) {
    final value = remote ?? '';
    if (_sessionNameCtrl.text == value) return;
    if (_lastSyncedSessionName == value) return;
    _lastSyncedSessionName = value;
    _sessionNameCtrl.text = value;
    _sessionNameCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
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
      final seats = _seats.map((s) => s['seat'] as int).toList();
      final playerCount = _game!['player_count'] as int;

      await EstimationService().startGame(
        gameId: widget.gameId,
        playerCount: playerCount,
        seats: seats,
        playerIds: playerIds,
      );
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
        AppRoute.build((_) => EstimationGameScreen(gameId: widget.gameId)),
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
                _syncSessionNameFromRemote(_game!['session_name'] as String?);
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

                            const SizedBox(height: AppTheme.space4),

                            // ── Session name (host edits, others see live) ──
                            _buildSessionNameField(),

                            const SizedBox(height: AppTheme.space5),

                            // ── Players header ──
                            Row(
                              children: [
                                const AppSectionLabel('ΠΑΙΚΤΕΣ · SEATED'),
                                const Spacer(),
                                Text(
                                  '${_seats.length} / $playerCount',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2,
                                    color: AppTheme.terra,
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

  Widget _buildSessionNameField() {
    final remote = (_game?['session_name'] as String?) ?? '';
    if (_isHost) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space3,
          vertical: AppTheme.space2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.paper,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppTheme.terra,
            ),
            const SizedBox(width: AppTheme.space2),
            Expanded(
              child: TextField(
                controller: _sessionNameCtrl,
                textInputAction: TextInputAction.done,
                maxLength: 48,
                onChanged: _onSessionNameChanged,
                style: GoogleFonts.caveat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  height: 1.1,
                ),
                decoration: InputDecoration(
                  hintText: 'όνομα παιχνιδιού (προαιρετικό)',
                  hintStyle: GoogleFonts.caveat(
                    fontSize: 20,
                    color: AppTheme.inkFaint,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  filled: false,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (remote.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bookmark_outline,
            size: 16,
            color: AppTheme.terra,
          ),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            child: Text(
              remote,
              style: GoogleFonts.caveat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                height: 1.1,
              ),
            ),
          ),
        ],
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
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppTheme.inkFaint,
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Text(
            'περιμένοντας τον host…',
            style: GoogleFonts.caveat(
              fontSize: 18,
              color: AppTheme.inkSoft,
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
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isMe
              ? AppTheme.terra.withValues(alpha: 0.55)
              : isEmpty
                  ? AppTheme.border
                  : AppTheme.borderAccent,
          width: isMe ? 1.2 : 1,
        ),
        boxShadow: isEmpty ? null : AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${seatIndex + 1}',
              textAlign: TextAlign.center,
              style: GoogleFonts.gloock(
                fontSize: 22,
                color: isEmpty ? AppTheme.inkFaint : AppTheme.terra,
                height: 1.0,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: isEmpty
                ? Text(
                    'αναμονή…',
                    style: GoogleFonts.caveat(
                      fontSize: 18,
                      color: AppTheme.inkFaint,
                    ),
                  )
                : Row(
                    children: [
                      Flexible(
                        child: Text(
                          username ?? '…',
                          style: GoogleFonts.caveat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isMe ? AppTheme.terra : AppTheme.ink,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.terraMuted,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'ΕΣΥ',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2,
                              color: AppTheme.terra,
                            ),
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
                color: AppTheme.oliveMuted,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                'HOST',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: AppTheme.olive,
                ),
              ),
            ),
          if (!isEmpty && !isHostSeat)
            const Icon(
              Icons.check_circle,
              size: 16,
              color: AppTheme.olive,
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
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          Text(
            'ROOM · ΚΩΔΙΚΟΣ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
              color: AppTheme.terra,
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
                    content: Text('αντιγράφτηκε'),
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
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 44,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 10,
                        color: AppTheme.ink,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space3),
                    const Icon(
                      Icons.copy_outlined,
                      size: 16,
                      color: AppTheme.inkFaint,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Container(
            height: 1,
            width: 60,
            color: AppTheme.terra.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            'μοιράσου με τους παίκτες',
            style: GoogleFonts.caveat(
              fontSize: 18,
              color: AppTheme.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
