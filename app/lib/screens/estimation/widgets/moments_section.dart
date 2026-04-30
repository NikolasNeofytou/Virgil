import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/estimation_moment.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../services/estimation_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/meraki_motion.dart';
import 'game_over_panel.dart' show AppSectionLabelMono;
import '../../../theme/meraki_fonts.dart';

/// "Στιγμές · MOMENTS" — user-curated 140-char notes attached to a game.
/// Renders on the game-over panel (live and historical) below the auto
/// awards. The current user can add (and delete their own) moments here.
class MomentsSection extends ConsumerWidget {
  const MomentsSection({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments =
        ref.watch(estimationMomentsStreamProvider(gameId)).valueOrNull ?? [];
    final usernames =
        ref.watch(playerUsernamesProvider(gameId)).valueOrNull ?? {};
    final myId = ref.watch(currentUserIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionLabelMono('ΣΤΙΓΜΕΣ · MOMENTS'),
        const SizedBox(height: AppTheme.space3),
        if (moments.isEmpty)
          _EmptyHint()
        else
          for (var i = 0; i < moments.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == moments.length - 1 ? 0 : AppTheme.space2,
              ),
              child: _MomentCard(
                moment: moments[i],
                authorName: usernames[moments[i].authorId] ?? '???',
                isMine: moments[i].authorId == myId,
              ).animate().fadeIn(
                    duration: MerakiMotion.normal,
                    delay: (i * 60).ms,
                    curve: MerakiMotion.entrance,
                  ),
            ),
        const SizedBox(height: AppTheme.space3),
        _AddMomentButton(gameId: gameId),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Text(
        'καμία στιγμή ακόμη.\nγράψε τη φράση που θα θυμόσαστε.',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppTheme.inkSoft,
          height: 1.4,
        ),
      ),
    );
  }
}

class _MomentCard extends ConsumerWidget {
  const _MomentCard({
    required this.moment,
    required this.authorName,
    required this.isMine,
  });

  final EstimationMoment moment;
  final String authorName;
  final bool isMine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.terra.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  authorName,
                  style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.terra,
                    height: 1.1,
                  ),
                ),
              ),
              if (moment.roundNumber != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'ΓΥΡΟΣ ${moment.roundNumber}',
                    style: const TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: AppTheme.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (isMine)
                InkWell(
                  onTap: () => _confirmDelete(context, ref),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppTheme.inkFaint,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            moment.body,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.ink,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Διαγραφή στιγμής;'),
        content: const Text('Θα αφαιρεθεί από το σύνολο.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Άκυρο'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Διέγραψε'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await EstimationService().deleteMoment(moment.id);
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα διαγραφής: $e')),
        );
      }
    }
  }
}

class _AddMomentButton extends StatelessWidget {
  const _AddMomentButton({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Πρόσθεσε στιγμή'),
      onPressed: () => _openSheet(context),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      builder: (_) => _AddMomentSheet(gameId: gameId),
    );
  }
}

class _AddMomentSheet extends ConsumerStatefulWidget {
  const _AddMomentSheet({required this.gameId});

  final String gameId;

  @override
  ConsumerState<_AddMomentSheet> createState() => _AddMomentSheetState();
}

class _AddMomentSheetState extends ConsumerState<_AddMomentSheet> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  /// Null = "Όλο το παιχνίδι" — pin to the game itself, not a round.
  /// Otherwise 1..totalRounds.
  int? _selectedRound;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _ctrl.text.trim();
    if (body.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await EstimationService().addMoment(
        gameId: widget.gameId,
        body: body,
        roundNumber: _selectedRound,
      );
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final game =
        ref.watch(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final totalRounds = game?.totalRounds ?? 0;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space5,
          AppTheme.space5,
          AppTheme.space5,
          AppTheme.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Πρόσθεσε στιγμή',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                color: AppTheme.ink,
                height: 1.0,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'μια φράση για να θυμάστε αυτό το παιχνίδι',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.inkSoft,
              ),
            ),
            const SizedBox(height: AppTheme.space4),
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLength: 140,
              maxLines: 3,
              minLines: 2,
              textInputAction: TextInputAction.newline,
              inputFormatters: [LengthLimitingTextInputFormatter(140)],
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.ink,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'π.χ. Ο Caesar κάλεσε 5, πήρε 0. Ωραία βραδιά.',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.inkFaint,
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (totalRounds > 0) ...[
              const SizedBox(height: AppTheme.space4),
              const Text(
                'ΓΥΡΟΣ · ROUND',
                style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3,
                  color: AppTheme.terra,
                ),
              ),
              const SizedBox(height: AppTheme.space2),
              Wrap(
                spacing: AppTheme.space1,
                runSpacing: AppTheme.space1,
                children: [
                  _RoundChip(
                    label: 'ΌΛΟ',
                    selected: _selectedRound == null,
                    onTap: () => setState(() => _selectedRound = null),
                  ),
                  for (var r = 1; r <= totalRounds; r++)
                    _RoundChip(
                      label: '$r',
                      selected: _selectedRound == r,
                      onTap: () => setState(() => _selectedRound = r),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppTheme.space4),
            FilledButton(
              onPressed:
                  _ctrl.text.trim().isEmpty || _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Αποθήκευση'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paper-and-ink pill for selecting which round a moment pins to. Selected
/// state inverts to a terracotta fill so the choice reads from across the
/// sheet. Kept tight (32×24) so a 14-round game flows on two lines max.
class _RoundChip extends StatelessWidget {
  const _RoundChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.terra : AppTheme.paper,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: selected
                ? AppTheme.terra
                : AppTheme.terra.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: selected ? AppTheme.paper : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}
