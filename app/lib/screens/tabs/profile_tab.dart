import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/player_profile.dart';
import '../../providers/app_icon_provider.dart';
import '../../providers/auth_providers.dart';
import '../../providers/stats_providers.dart';
import '../../services/app_icon_service.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_client.dart';
import '../../theme/app_background.dart';
import '../../theme/app_route.dart';
import '../../theme/app_theme.dart';
import '../../theme/meraki_tokens.dart';
import '../history/game_history_screen.dart';
import '../../theme/meraki_fonts.dart';

/// Profile tab — ink-stamp avatar, Caveat username, JetBrains Mono email,
/// paper stats card over the player's Estimation history, language toggle,
/// outlined danger sign-out.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentPlayerProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Προφίλ')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'σφάλμα · $e',
            style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
              color: AppTheme.danger,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        data: (p) {
          if (p == null) return const SizedBox.shrink();
          return _ProfileBody(profile: p);
        },
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = profile;
    final email = SupabaseBootstrap.client.auth.currentUser?.email;
    final statsAsync = ref.watch(estimationStatsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space5,
        AppTheme.space4,
        AppTheme.space5,
        AppTheme.space6,
      ),
      children: [
        // ── Identity ──
        Center(child: _StampAvatar(username: p.username, url: p.avatarUrl)),
        const SizedBox(height: AppTheme.space4),
        Center(
          child: Text(
            '@${p.username}',
            style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
              height: 1.0,
            ),
          ),
        ),
        if (email != null) ...[
          const SizedBox(height: 4),
          Center(
            child: Text(
              email,
              style: const TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                fontSize: 11,
                letterSpacing: 1,
                color: AppTheme.inkSoft,
              ),
            ),
          ),
        ],
        if (p.displayName?.isNotEmpty ?? false) ...[
          const SizedBox(height: AppTheme.space2),
          Center(
            child: Text(
              p.displayName!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.inkSoft,
              ),
            ),
          ),
        ],

        const SizedBox(height: AppTheme.space6),

        // ── Stats ──
        const AppSectionLabel('§ 01 · ΣΤΑΤΙΣΤΙΚΑ · STATS', showRule: true),
        const SizedBox(height: AppTheme.space3),
        statsAsync.when(
          loading: () => const _StatsSkeleton(),
          error: (_, __) => const _StatsCard.empty(),
          data: _StatsCard.new,
        ),

        const SizedBox(height: AppTheme.space6),

        // ── History ──
        const AppSectionLabel(
          '§ 02 · ΤΑ ΠΑΙΧΝΙΔΙΑ ΜΟΥ · HISTORY',
          showRule: true,
        ),
        const SizedBox(height: AppTheme.space3),
        _HistoryEntry(
          onTap: () => Navigator.of(context).push<void>(
            AppRoute.build((_) => const GameHistoryScreen()),
          ),
        ),

        const SizedBox(height: AppTheme.space6),

        // ── Settings ──
        const AppSectionLabel('§ 03 · ΡΥΘΜΙΣΕΙΣ · SETTINGS', showRule: true),
        const SizedBox(height: AppTheme.space3),
        _SettingsCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.profileLanguageLabel,
                  style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'el', label: Text('EL')),
                  ButtonSegment(value: 'en', label: Text('EN')),
                ],
                selected: {p.locale},
                onSelectionChanged: (s) async {
                  await SupabaseBootstrap.client
                      .from('players')
                      .update({'locale': s.first}).eq('id', p.id);
                  ref.invalidate(currentPlayerProfileProvider);
                },
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.space3),
        const _IconPicker(),

        const SizedBox(height: AppTheme.space5),

        OutlinedButton(
          onPressed: () => AuthService().signOut(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.danger,
            side: BorderSide(
              color: AppTheme.danger.withValues(alpha: 0.5),
            ),
          ),
          child: const Text('Αποσύνδεση'),
        ),
      ],
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _StampAvatar extends StatelessWidget {
  const _StampAvatar({required this.username, this.url});

  final String username;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppTheme.paper,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.terra.withValues(alpha: 0.6), width: 1.6),
        boxShadow: AppTheme.shadowMd,
      ),
      alignment: Alignment.center,
      child: url != null
          ? ClipOval(child: Image.network(url!, fit: BoxFit.cover))
          : Text(
              username.isEmpty ? '?' : username.substring(0, 1).toUpperCase(),
              style: GoogleFonts.fraunces(
                fontSize: 48,
                color: AppTheme.ink,
                height: 1.0,
                letterSpacing: -0.8,
              ),
            ),
    );
  }
}

// ── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard(this.stats);

  const _StatsCard.empty() : stats = EstimationStats.empty;

  final EstimationStats stats;

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
          Expanded(
            child: _StatCell(
              value: '${stats.gamesPlayed}',
              label: 'παιχνίδια',
            ),
          ),
          Container(width: 1, height: 52, color: AppTheme.border),
          Expanded(
            child: _StatCell(
              value: '${stats.wins}',
              label: 'νίκες',
              highlight: stats.wins > 0,
            ),
          ),
          Container(width: 1, height: 52, color: AppTheme.border),
          Expanded(
            child: _StatCell(
              value: '${stats.totalScore}',
              label: 'πόντοι',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.fraunces(
            fontSize: 32,
            color: highlight ? AppTheme.goldReserved : AppTheme.ink,
            height: 1.0,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.inkSoft,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

// ── History entry ─────────────────────────────────────────────────────────────

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({required this.onTap});

  final VoidCallback onTap;

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
                  children: [
                    Text(
                      'Τα παιχνίδια μου',
                      style: GoogleFonts.fraunces(
                        fontSize: 20,
                        color: AppTheme.ink,
                        height: 1.0,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'άνοιξε ένα παλιό σύνολο · ξαναδές · ξαναμοιράσου',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.inkSoft,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.inkFaint,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

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
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: child,
    );
  }
}

// ── App icon picker ───────────────────────────────────────────────────────────

/// Dynamic-icon picker for the three Meraki variants from deck §04.B.
/// iOS-only — hidden entirely on Android (and on iOS builds whose
/// Info.plist doesn't declare CFBundleAlternateIcons). The picker is a
/// second tile inside the §03 Settings section, sitting under the
/// language toggle.
class _IconPicker extends ConsumerWidget {
  const _IconPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportedAsync = ref.watch(appIconSupportedProvider);
    final supported = supportedAsync.valueOrNull ?? false;
    if (!supported) return const SizedBox.shrink();

    final loc = AppLocalizations.of(context)!;
    final current =
        ref.watch(currentAppIconProvider).valueOrNull ?? AppIconVariant.aegean;

    Future<void> pick(AppIconVariant v) async {
      if (v == current) return;
      try {
        await AppIconService().setVariant(v);
        ref.invalidate(currentAppIconProvider);
      } on Object {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.profileIconError)),
        );
      }
    }

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.profileIconLabel,
            style: GoogleFonts.fraunces(
              fontStyle: FontStyle.italic,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Row(
            children: [
              Expanded(
                child: _IconChoice(
                  variant: AppIconVariant.aegean,
                  name: loc.profileIconAegean,
                  role: loc.profileIconAegeanRole,
                  selected: current == AppIconVariant.aegean,
                  onTap: () => pick(AppIconVariant.aegean),
                ),
              ),
              Expanded(
                child: _IconChoice(
                  variant: AppIconVariant.coral,
                  name: loc.profileIconCoral,
                  role: loc.profileIconCoralRole,
                  selected: current == AppIconVariant.coral,
                  onTap: () => pick(AppIconVariant.coral),
                ),
              ),
              Expanded(
                child: _IconChoice(
                  variant: AppIconVariant.ochre,
                  name: loc.profileIconOchre,
                  role: loc.profileIconOchreRole,
                  selected: current == AppIconVariant.ochre,
                  onTap: () => pick(AppIconVariant.ochre),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.variant,
    required this.name,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final AppIconVariant variant;
  final String name;
  final String role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ringColor = selected ? scheme.primary : AppTheme.border;
    final ringWidth = selected ? 2.0 : 1.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: tokens.coralMuted,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ringColor, width: ringWidth),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(variant.assetName, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: AppTheme.space2),
            Text(
              name,
              style: GoogleFonts.fraunces(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.ink,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              role,
              style: tokens.eyebrow.copyWith(
                fontSize: 9,
                letterSpacing: 1.0,
                color: AppTheme.inkFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
