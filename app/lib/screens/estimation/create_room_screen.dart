import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/estimation_service.dart';
import '../../theme/app_background.dart';
import '../../theme/app_route.dart';
import '../../theme/app_theme.dart';
import 'room_lobby_screen.dart';
import '../../theme/meraki_fonts.dart';

/// Create-room screen. Virgil masthead → player-count picker (paper tiles
/// with the same terracotta stamp-ring animation as [NumberPicker]) → a
/// short game-length summary → terra filled button.
class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  int _playerCount = 2;
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
        AppRoute.build((_) => RoomLobbyScreen(gameId: gameId)),
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mirror the SQL: max_cards = least(7, floor(52 / player_count)),
    // total_rounds = 2 × max_cards (peak doubled ladder).
    final maxCards = math.min(7, 52 ~/ _playerCount);
    final totalRounds = 2 * maxCards;

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
                    _MiniMasthead(),
                    const SizedBox(height: AppTheme.space6),

                    const AppSectionLabel(
                      '§ 01 · ΠΑΙΚΤΕΣ · PLAYERS',
                      showRule: true,
                    ),
                    const SizedBox(height: AppTheme.space3),
                    Row(
                      children: [
                        for (final n in const [2, 3, 4]) ...[
                          Expanded(
                            child: _CountTile(
                              count: n,
                              selected: _playerCount == n,
                              onTap: () => setState(() => _playerCount = n),
                            ),
                          ),
                          if (n != 4) const SizedBox(width: AppTheme.space3),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppTheme.space6),
                    const AppSectionLabel(
                      '§ 02 · ΓΥΡΟΙ · LENGTH',
                      showRule: true,
                    ),
                    const SizedBox(height: AppTheme.space3),
                    _LengthSummary(
                      maxCards: maxCards,
                      totalRounds: totalRounds,
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
                        style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                          color: AppTheme.danger,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.space2),
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

/// Mini masthead — double-rule Gloock title. Smaller than the home tab's
/// full Virgil masthead; enough to keep identity consistency on interior
/// screens without overwhelming the form.
class _MiniMasthead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VOL. I · APR 2026',
              style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
            Text(
              'KAFENEIO',
              style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 1.5, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space3),
        Center(
          child: Text(
            'Νέο δωμάτιο',
            style: GoogleFonts.fraunces(
              fontSize: 40,
              color: AppTheme.ink,
              letterSpacing: -0.6,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'στήσε το τραπέζι',
            style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
              fontSize: 20,
              color: AppTheme.terra,
            ),
          ),
        ),
      ],
    );
  }
}

/// One of the three player-count tiles. Paper tile with Gloock numeral +
/// Caveat label; terracotta stamp ring when selected.
class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  static const _labels = {
    2: 'δύο',
    3: 'τρεις',
    4: 'τέσσερις',
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        splashColor: AppTheme.terraMuted,
        highlightColor: Colors.transparent,
        child: Container(
          height: 112,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: selected
                  ? AppTheme.terra.withValues(alpha: 0.6)
                  : AppTheme.border,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (selected)
                TweenAnimationBuilder<double>(
                  key: ValueKey('stamp-$count'),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) {
                    final scale = 2.4 - 1.4 * t;
                    final opacity = (t * 2).clamp(0.0, 1.0);
                    return Positioned(
                      top: 8,
                      child: Opacity(
                        opacity: 0.9 - t * 0.4,
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    AppTheme.terra.withValues(alpha: opacity),
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count',
                    style: GoogleFonts.fraunces(
                      fontSize: 44,
                      color: selected ? AppTheme.terra : AppTheme.ink,
                      height: 1.0,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _labels[count]!,
                    style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                      fontSize: 16,
                      color: selected ? AppTheme.terra : AppTheme.inkSoft,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "7 κάρτες max · 14 γύροι" summary card — Gloock numerals flanking short
/// Caveat captions, divided by a thin ink rule.
class _LengthSummary extends StatelessWidget {
  const _LengthSummary({required this.maxCards, required this.totalRounds});

  final int maxCards;
  final int totalRounds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(child: _Stat(value: '$maxCards', label: 'κάρτες max')),
          Container(width: 1, height: 44, color: AppTheme.border),
          Expanded(child: _Stat(value: '$totalRounds', label: 'γύροι')),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.fraunces(
            fontSize: 32,
            color: AppTheme.ink,
            height: 1.0,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.inkSoft,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
