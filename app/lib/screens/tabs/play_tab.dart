import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/active_game_provider.dart';
import '../../providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/meraki_fonts.dart';
import '../../theme/meraki_tokens.dart';
import '../../widgets/virgil_button.dart';
import '../../widgets/virgil_card.dart';
import '../../widgets/virgil_chip.dart';
import '../estimation/create_room_screen.dart';
import '../estimation/estimation_game_screen.dart';
import '../estimation/join_room_screen.dart';
import '../estimation/room_lobby_screen.dart';
import '../../theme/app_route.dart';

/// Lobby — the deck's "opens like a journal" pattern from §05.
/// Editorial header, daily-moment hero, optional Continue card, and a list
/// of game tiles where Estimation is the live one and the three Cypriot
/// classics sit as Σύντομα placeholders.
class PlayTab extends ConsumerWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeEstimationGameProvider);
    final profileAsync = ref.watch(currentPlayerProfileProvider);
    final username = profileAsync.valueOrNull?.username;

    Future<void> openCreate() async {
      await Navigator.of(context).push<void>(
        AppRoute.build((_) => const CreateRoomScreen()),
      );
      ref.invalidate(activeEstimationGameProvider);
    }

    Future<void> openJoin() async {
      await Navigator.of(context).push<void>(
        AppRoute.build((_) => const JoinRoomScreen()),
      );
      ref.invalidate(activeEstimationGameProvider);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.space5,
            AppTheme.space5,
            AppTheme.space5,
            AppTheme.space6,
          ),
          children: [
            LobbyHeader(username: username),
            const SizedBox(height: AppTheme.space6),
            DailyMomentCard(onCreate: openCreate, onJoin: openJoin),
            activeAsync.maybeWhen(
              data: (active) => active == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: AppTheme.space5),
                      child: ContinueCard(
                        active: active,
                        onTap: () {
                          ref.invalidate(activeEstimationGameProvider);
                          Navigator.of(context).push<void>(
                            AppRoute.build(
                              (_) => active.isInLobby
                                  ? RoomLobbyScreen(gameId: active.gameId)
                                  : EstimationGameScreen(gameId: active.gameId),
                            ),
                          );
                        },
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppTheme.space6),
            GamesSection(onEstimationTap: openCreate),
          ],
        ),
      ),
    );
  }
}

/// Editorial header — time-aware greeting eyebrow, "A table is set for you."
/// Fraunces title, and a TODAY · 29 APR date stamp.
class LobbyHeader extends StatelessWidget {
  const LobbyHeader({super.key, required this.username});

  final String? username;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    final greeting = _greetingFor(DateTime.now(), loc);
    final greetingLine = username == null
        ? greeting.toUpperCase()
        : '${greeting.toUpperCase()}, ${username!.toUpperCase()}';

    final locale = Localizations.localeOf(context).languageCode;
    final today =
        DateFormat.MMMd(locale).format(DateTime.now()).toUpperCase();
    final dateLine = '${loc.lobbyTodayLabel} · $today';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greetingLine, style: tokens.eyebrow.copyWith(color: scheme.primary)),
        const SizedBox(height: AppTheme.space3),
        Text(
          loc.lobbyHeroTitle,
          style: GoogleFonts.fraunces(
            fontSize: 36,
            height: 1.05,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.6,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        Text(dateLine, style: tokens.eyebrow),
      ],
    );
  }

  String _greetingFor(DateTime now, AppLocalizations loc) {
    final h = now.hour;
    if (h >= 5 && h < 12) return loc.lobbyGreetingMorning;
    if (h >= 12 && h < 18) return loc.lobbyGreetingAfternoon;
    if (h >= 18 || h < 5) return loc.lobbyGreetingEvening;
    return loc.lobbyGreetingFallback;
  }
}

/// Hero card — the daily moment. Spotlights Estimation (our live game)
/// with a primary "Take your seat →" CTA and a ghost "Join" verb. Per the
/// deck this card is "never gamified, always editorial."
class DailyMomentCard extends StatelessWidget {
  const DailyMomentCard({
    super.key,
    required this.onCreate,
    required this.onJoin,
  });

  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return VirgilCard(
      variant: VirgilCardVariant.hero,
      padding: const EdgeInsets.all(AppTheme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '§ 01 · ${loc.lobbyTonightSection}',
            style: tokens.eyebrow.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            '${loc.lobbyEstimationName}.',
            style: GoogleFonts.fraunces(
              fontSize: 44,
              height: 1.0,
              letterSpacing: -1.0,
              fontWeight: FontWeight.w400,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            loc.lobbyEstimationDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppTheme.space5),
          Row(
            children: [
              Expanded(
                child: VirgilButton(
                  label: loc.lobbyTakeYourSeat,
                  trailingArrow: true,
                  onPressed: onCreate,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              VirgilButton(
                label: loc.lobbyJoin,
                variant: VirgilButtonVariant.ghost,
                trailingArrow: true,
                onPressed: onJoin,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Continue card — passive resume per the deck's "Continue, in your own
/// time. Resume happens passively, with no pressure" cue. Standard surface
/// (not hero), italic Continue → on the right.
class ContinueCard extends StatelessWidget {
  const ContinueCard({
    super.key,
    required this.active,
    required this.onTap,
  });

  final ActiveGameSummary active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    final progressLine = active.isInGame
        ? loc.lobbyInProgressRound(active.currentRound)
        : loc.lobbyInProgressLobby;

    return VirgilCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.lobbyInProgressSection,
                  style: tokens.eyebrow.copyWith(color: scheme.primary),
                ),
                const SizedBox(height: AppTheme.space2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      active.roomCode,
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                        color: scheme.onSurface,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space3),
                    Text(
                      '· $progressLine',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.inkSoft,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Text(
            '${loc.lobbyContinueLabel} →',
            style: tokens.italicVerb.copyWith(color: scheme.primary),
          ),
        ],
      ),
    );
  }
}

/// Games list — a section header eyebrow followed by four tiles. Estimation
/// is live and tappable; Pilotta / Tavli / Biriba sit as Σύντομα cards
/// pending the actual game implementations.
class GamesSection extends StatelessWidget {
  const GamesSection({super.key, required this.onEstimationTap});

  final VoidCallback onEstimationTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '§ 02 · ${loc.lobbyGamesSection}',
          style: tokens.eyebrow.copyWith(color: scheme.primary),
        ),
        const SizedBox(height: AppTheme.space3),
        _GameTile(
          name: loc.lobbyEstimationName,
          tagline: loc.lobbyEstimationDescription,
          live: true,
          onTap: onEstimationTap,
        ),
        const SizedBox(height: AppTheme.space2),
        _GameTile(
          name: loc.lobbyGamePilotta,
          tagline: loc.lobbyGamePilottaTagline,
          live: false,
        ),
        const SizedBox(height: AppTheme.space2),
        _GameTile(
          name: loc.lobbyGameTavli,
          tagline: loc.lobbyGameTavliTagline,
          live: false,
        ),
        const SizedBox(height: AppTheme.space2),
        _GameTile(
          name: loc.lobbyGameBiriba,
          tagline: loc.lobbyGameBiribaTagline,
          live: false,
        ),
      ],
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.name,
    required this.tagline,
    required this.live,
    this.onTap,
  });

  final String name;
  final String tagline;
  final bool live;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dim = !live;
    final titleColor =
        dim ? AppTheme.inkSoft : Theme.of(context).colorScheme.onSurface;
    final taglineColor = dim ? AppTheme.inkFaint : AppTheme.inkSoft;

    return VirgilCard(
      onTap: live ? onTap : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.fraunces(
                    fontSize: 22,
                    height: 1.1,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.2,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tagline,
                  style: TextStyle(
                    fontFamily: MerakiFonts.geistMonoFamily,
                    fontSize: 12,
                    height: 1.4,
                    color: taglineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          VirgilChip(
            label: live ? loc.lobbyChipLive : loc.lobbyChipSoon,
            variant:
                live ? VirgilChipVariant.accent : VirgilChipVariant.neutral,
            dot: live,
          ),
        ],
      ),
    );
  }
}
