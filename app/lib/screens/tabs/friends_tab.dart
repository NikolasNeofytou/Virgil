import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/friendship.dart';
import '../../providers/auth_providers.dart';
import '../../providers/friends_providers.dart';
import '../../services/friends_service.dart';
import '../../theme/app_background.dart';
import '../../theme/app_theme.dart';

/// Friends tab. Real friendships via `public.friendships`. Three sections:
/// inbox (pending inbound), yours (accepted), sent (pending outbound).
class FriendsTab extends ConsumerStatefulWidget {
  const FriendsTab({super.key});

  @override
  ConsumerState<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends ConsumerState<FriendsTab> {
  final _addController = TextEditingController();
  final _addFocus = FocusNode();
  final _service = FriendsService();
  bool _sending = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _addController.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final username = _addController.text.trim();
    if (username.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
      _success = null;
    });
    try {
      await _service.sendFriendRequest(username);
      if (!mounted) return;
      setState(() {
        _success = 'στάλθηκε στον @$username';
        _addController.clear();
      });
      _addFocus.unfocus();
    } on FriendsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = 'σφάλμα · δοκίμασε ξανά');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserIdProvider);
    final accepted = ref.watch(acceptedFriendsProvider);
    final inbound = ref.watch(inboundPendingProvider);
    final outbound = ref.watch(outboundPendingProvider);
    final names =
        ref.watch(friendUsernamesProvider).valueOrNull ?? const {};

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Φίλοι')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space5,
          AppTheme.space4,
          AppTheme.space5,
          AppTheme.space6,
        ),
        children: [
          _AddFriendCard(
            controller: _addController,
            focusNode: _addFocus,
            sending: _sending,
            error: _error,
            success: _success,
            onSend: _send,
          ),

          const SizedBox(height: AppTheme.space6),
          const AppSectionLabel(
            '§ 01 · ΑΙΤΗΣΕΙΣ · INBOX',
            showRule: true,
          ),
          const SizedBox(height: AppTheme.space3),
          if (inbound.isEmpty)
            const _EmptyHint('δεν έχεις αιτήσεις αυτή τη στιγμή')
          else
            ...inbound.map((f) => _InboundRow(
                  friendship: f,
                  name: names[f.requesterId] ?? '…',
                  service: _service,
                ),),

          const SizedBox(height: AppTheme.space6),
          const AppSectionLabel(
            '§ 02 · ΦΙΛΟΙ · YOURS',
            showRule: true,
          ),
          const SizedBox(height: AppTheme.space3),
          if (accepted.isEmpty)
            const _EmptyHint('πρόσθεσε τον πρώτο σου φίλο πιο πάνω')
          else if (me != null)
            ...accepted.map((f) => _FriendRow(
                  friendship: f,
                  name: names[f.otherParty(me)] ?? '…',
                  service: _service,
                ),),

          const SizedBox(height: AppTheme.space6),
          const AppSectionLabel(
            '§ 03 · ΣΕ ΑΝΑΜΟΝΗ · SENT',
            showRule: true,
          ),
          const SizedBox(height: AppTheme.space3),
          if (outbound.isEmpty)
            const _EmptyHint('καμία αίτηση σε αναμονή')
          else
            ...outbound.map((f) => _OutboundRow(
                  friendship: f,
                  name: names[f.addresseeId] ?? '…',
                  service: _service,
                ),),
        ],
      ),
    );
  }
}

// ── Add-friend card ───────────────────────────────────────────────────────────

class _AddFriendCard extends StatelessWidget {
  const _AddFriendCard({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.error,
    required this.success,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final String? error;
  final String? success;
  final VoidCallback onSend;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'πρόσθεσε φίλο με όνομα',
            style: GoogleFonts.caveat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '@',
                style: GoogleFonts.gloock(
                  fontSize: 22,
                  color: AppTheme.terra,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: !sending,
                  maxLength: 24,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  style: GoogleFonts.caveat(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                    height: 1.2,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9_]'),
                    ),
                  ],
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'όνομα',
                    hintStyle: GoogleFonts.caveat(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.inkFaint,
                    ),
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              FilledButton(
                onPressed: sending ? null : onSend,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space4,
                  ),
                ),
                child: sending
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Στείλε'),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: AppTheme.space2),
            Text(
              error!,
              style: GoogleFonts.caveat(
                color: AppTheme.danger,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (success != null) ...[
            const SizedBox(height: AppTheme.space2),
            Text(
              success!,
              style: GoogleFonts.caveat(
                color: AppTheme.olive,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Row shells ────────────────────────────────────────────────────────────────

/// Base paper row. Action buttons on the right.
class _FriendshipRow extends StatelessWidget {
  const _FriendshipRow({
    required this.name,
    required this.children,
    this.subtitle,
    this.nameColor,
  });

  final String name;
  final List<Widget> children;
  final String? subtitle;
  final Color? nameColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space2),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.caveat(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: nameColor ?? AppTheme.ink,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.kalam(
                      fontSize: 12,
                      color: AppTheme.inkFaint,
                      height: 1.2,
                    ),
                  ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _InboundRow extends StatelessWidget {
  const _InboundRow({
    required this.friendship,
    required this.name,
    required this.service,
  });

  final Friendship friendship;
  final String name;
  final FriendsService service;

  @override
  Widget build(BuildContext context) {
    return _FriendshipRow(
      name: name,
      subtitle: 'θέλει να γίνει φίλος σου',
      children: [
        IconButton(
          onPressed: () => service.declineRequest(friendship.id),
          icon: const Icon(Icons.close, size: 20),
          color: AppTheme.inkFaint,
          tooltip: 'Απόρριψη',
        ),
        const SizedBox(width: 4),
        FilledButton(
          onPressed: () => service.acceptRequest(friendship.id),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.olive,
            minimumSize: const Size(0, 36),
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.space3),
          ),
          child: const Text('Δέξου'),
        ),
      ],
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({
    required this.friendship,
    required this.name,
    required this.service,
  });

  final Friendship friendship;
  final String name;
  final FriendsService service;

  @override
  Widget build(BuildContext context) {
    return _FriendshipRow(
      name: name,
      children: [
        const Icon(Icons.check_circle, size: 16, color: AppTheme.olive),
        IconButton(
          onPressed: () async {
            final confirm = await _confirmUnfriend(context, name);
            if (confirm ?? false) service.removeFriend(friendship.id);
          },
          icon: const Icon(Icons.more_horiz, size: 18),
          color: AppTheme.inkFaint,
          tooltip: 'Ενέργειες',
        ),
      ],
    );
  }

  Future<bool?> _confirmUnfriend(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Αφαίρεση @$name;'),
        content: const Text('Η φιλία θα διαγραφεί και για τους δύο.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Άκυρο'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Αφαίρεσε'),
          ),
        ],
      ),
    );
  }
}

class _OutboundRow extends StatelessWidget {
  const _OutboundRow({
    required this.friendship,
    required this.name,
    required this.service,
  });

  final Friendship friendship;
  final String name;
  final FriendsService service;

  @override
  Widget build(BuildContext context) {
    return _FriendshipRow(
      name: name,
      subtitle: 'αναμονή επιβεβαίωσης',
      nameColor: AppTheme.inkSoft,
      children: [
        IconButton(
          onPressed: () => service.cancelRequest(friendship.id),
          icon: const Icon(Icons.close, size: 20),
          color: AppTheme.inkFaint,
          tooltip: 'Ακύρωση',
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space2,
        vertical: AppTheme.space3,
      ),
      child: Text(
        text,
        style: GoogleFonts.caveat(
          fontSize: 18,
          color: AppTheme.inkFaint,
        ),
      ),
    );
  }
}
