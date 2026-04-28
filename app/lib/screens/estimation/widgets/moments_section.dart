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
import 'game_over_panel.dart' show AppSectionLabelMono;

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
                    duration: 280.ms,
                    delay: (i * 60).ms,
                    curve: Curves.easeOut,
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
        style: GoogleFonts.kalam(
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
                  style: GoogleFonts.caveat(
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
                    style: GoogleFonts.jetBrainsMono(
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
            style: GoogleFonts.kalam(
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

class _AddMomentSheet extends StatefulWidget {
  const _AddMomentSheet({required this.gameId});

  final String gameId;

  @override
  State<_AddMomentSheet> createState() => _AddMomentSheetState();
}

class _AddMomentSheetState extends State<_AddMomentSheet> {
  final _ctrl = TextEditingController();
  bool _saving = false;

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
      await EstimationService().addMoment(gameId: widget.gameId, body: body);
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
              style: GoogleFonts.gloock(
                fontSize: 24,
                color: AppTheme.ink,
                height: 1.0,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'μια φράση για να θυμάστε αυτό το παιχνίδι',
              style: GoogleFonts.kalam(
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
              style: GoogleFonts.kalam(
                fontSize: 16,
                color: AppTheme.ink,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'π.χ. Ο Caesar κάλεσε 5, πήρε 0. Ωραία βραδιά.',
                hintStyle: GoogleFonts.kalam(
                  fontSize: 16,
                  color: AppTheme.inkFaint,
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
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
