import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/friendship.dart';
import '../../providers/auth_providers.dart';
import '../../providers/friend_closeness_provider.dart';
import '../../providers/friends_providers.dart';
import '../../services/friends_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/meraki_tokens.dart';
import '../../widgets/virgil_card.dart';

/// Parea — friends, restyled to the Meraki §05 SCREEN 03 pattern. Linen
/// canvas, Fraunces names, GeistMono section eyebrows, italic-verb actions.
/// Three sections drive the same friendship state machine the kafeneio
/// version did: INBOX → YOURS → SENT.
///
/// Accepted friends are sorted by deck §05 SCREEN 03 closeness — games
/// shared in the last 30 days, descending; alphabetical username for ties.
/// The shared-games count surfaces as a quiet GeistMono caption under each
/// name when > 0; suppressed when the parea has no co-game history yet.
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
    final loc = AppLocalizations.of(context)!;
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
        _success = loc.pareaAddSuccess(username);
        _addController.clear();
      });
      _addFocus.unfocus();
    } on FriendsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = loc.pareaAddErrorGeneric);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final me = ref.watch(currentUserIdProvider);
    final accepted = ref.watch(acceptedFriendsProvider);
    final inbound = ref.watch(inboundPendingProvider);
    final outbound = ref.watch(outboundPendingProvider);
    final names =
        ref.watch(friendUsernamesProvider).valueOrNull ?? const {};
    final closeness =
        ref.watch(friendClosenessProvider).valueOrNull ?? const {};

    // Sort accepted friends by closeness desc, alphabetical username asc
    // for ties. Done in build() so the original provider order is
    // preserved for the inbound / outbound sections.
    final sortedAccepted = me == null
        ? accepted
        : ([...accepted]..sort((a, b) {
            final aId = a.otherParty(me);
            final bId = b.otherParty(me);
            final byScore =
                (closeness[bId] ?? 0).compareTo(closeness[aId] ?? 0);
            if (byScore != 0) return byScore;
            final aName = (names[aId] ?? '').toLowerCase();
            final bName = (names[bId] ?? '').toLowerCase();
            return aName.compareTo(bName);
          }));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(loc.pareaTitle)),
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
          _SectionEyebrow('§ 01 · ${loc.pareaInboxSection}'),
          const SizedBox(height: AppTheme.space3),
          if (inbound.isEmpty)
            _EmptyHint(loc.pareaInboxEmpty)
          else
            ...inbound.map(
              (f) => _InboundRow(
                friendship: f,
                name: names[f.requesterId] ?? '…',
                service: _service,
              ),
            ),
          const SizedBox(height: AppTheme.space6),
          _SectionEyebrow('§ 02 · ${loc.pareaYoursSection}'),
          const SizedBox(height: AppTheme.space3),
          if (accepted.isEmpty)
            _EmptyHint(loc.pareaYoursEmpty)
          else if (me != null)
            ...sortedAccepted.map(
              (f) => _FriendRow(
                friendship: f,
                name: names[f.otherParty(me)] ?? '…',
                sharedGames: closeness[f.otherParty(me)] ?? 0,
                service: _service,
              ),
            ),
          const SizedBox(height: AppTheme.space6),
          _SectionEyebrow('§ 03 · ${loc.pareaSentSection}'),
          const SizedBox(height: AppTheme.space3),
          if (outbound.isEmpty)
            _EmptyHint(loc.pareaSentEmpty)
          else
            ...outbound.map(
              (f) => _OutboundRow(
                friendship: f,
                name: names[f.addresseeId] ?? '…',
                service: _service,
              ),
            ),
        ],
      ),
    );
  }
}

/// Top "add a friend" composer. Lives in a hero card with a coral '@' prefix
/// and an Inter input. Italic-Fraunces "Send" verb on the right.
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
    final loc = AppLocalizations.of(context)!;
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return VirgilCard(
      variant: VirgilCardVariant.hero,
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.pareaAddPrompt,
            style: tokens.eyebrow.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: AppTheme.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '@',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: scheme.primary,
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
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
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
                    hintText: loc.pareaAddHint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 17,
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
                    : Text(loc.pareaAddSubmit),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: AppTheme.space2),
            Text(
              error!,
              style: GoogleFonts.inter(
                color: AppTheme.danger,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (success != null) ...[
            const SizedBox(height: AppTheme.space2),
            Text(
              success!,
              style: GoogleFonts.inter(
                color: scheme.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section eyebrow — Geist Mono with a hairline rule running to the right.
class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text, style: tokens.eyebrow.copyWith(color: scheme.primary)),
        const SizedBox(width: AppTheme.space2),
        const Expanded(
          child: Divider(thickness: 1, color: AppTheme.border, height: 1),
        ),
      ],
    );
  }
}

/// Empty-state line — italic Fraunces faint ink, no card.
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
        style: GoogleFonts.fraunces(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: AppTheme.inkFaint,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Base parea row — VirgilCard standard with a Fraunces name, optional
/// GeistMono caption (closeness etc.), optional italic Fraunces subtitle,
/// and a list of trailing action widgets.
class _PareaRow extends StatelessWidget {
  const _PareaRow({
    required this.name,
    required this.children,
    this.subtitle,
    this.caption,
    this.dim = false,
  });

  final String name;
  final List<Widget> children;
  final String? subtitle;

  /// Quiet GeistMono caption rendered between the name and any italic
  /// subtitle. Used for the closeness count ("12 παρτίδες · 30 μέρες").
  final String? caption;

  final bool dim;

  @override
  Widget build(BuildContext context) {
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final nameColor = dim ? AppTheme.inkSoft : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space2),
      child: VirgilCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space4,
          vertical: AppTheme.space3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@$name',
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                      color: nameColor,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (caption != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        caption!,
                        style: tokens.eyebrow.copyWith(
                          letterSpacing: 0.6,
                          color: AppTheme.inkFaint,
                        ),
                      ),
                    ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: GoogleFonts.fraunces(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.inkFaint,
                          height: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ...children,
          ],
        ),
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
    final loc = AppLocalizations.of(context)!;
    return _PareaRow(
      name: name,
      subtitle: loc.pareaInboxWantsToBeFriends,
      children: [
        IconButton(
          onPressed: () => service.declineRequest(friendship.id),
          icon: const Icon(Icons.close, size: 20),
          color: AppTheme.inkFaint,
          tooltip: loc.pareaInboxDecline,
        ),
        const SizedBox(width: 4),
        FilledButton(
          onPressed: () => service.acceptRequest(friendship.id),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            minimumSize: const Size(0, 36),
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.space3),
          ),
          child: Text(loc.pareaInboxAccept),
        ),
      ],
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({
    required this.friendship,
    required this.name,
    required this.sharedGames,
    required this.service,
  });

  final Friendship friendship;
  final String name;
  final int sharedGames;
  final FriendsService service;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return _PareaRow(
      name: name,
      caption: sharedGames > 0 ? loc.pareaSharedGames(sharedGames) : null,
      children: [
        Icon(Icons.check_circle, size: 16, color: scheme.secondary),
        IconButton(
          onPressed: () async {
            final confirm = await _confirmUnfriend(context, name);
            if (confirm ?? false) service.removeFriend(friendship.id);
          },
          icon: const Icon(Icons.more_horiz, size: 18),
          color: AppTheme.inkFaint,
        ),
      ],
    );
  }

  Future<bool?> _confirmUnfriend(BuildContext context, String name) {
    final loc = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.pareaUnfriendTitle(name)),
        content: Text(loc.pareaUnfriendBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.pareaUnfriendCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: Text(loc.pareaUnfriendConfirm),
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
    final loc = AppLocalizations.of(context)!;
    return _PareaRow(
      name: name,
      subtitle: loc.pareaSentLabel,
      dim: true,
      children: [
        IconButton(
          onPressed: () => service.cancelRequest(friendship.id),
          icon: const Icon(Icons.close, size: 20),
          color: AppTheme.inkFaint,
          tooltip: loc.pareaSentCancel,
        ),
      ],
    );
  }
}
