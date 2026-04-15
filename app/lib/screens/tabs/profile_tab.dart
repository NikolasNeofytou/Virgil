import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/player_profile.dart';
import '../../providers/auth_providers.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_client.dart';
import '../../theme/app_background.dart';
import '../../theme/app_theme.dart';

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
        error: (e, _) => Center(child: Text('Σφάλμα: $e')),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space5,
        AppTheme.space4,
        AppTheme.space5,
        AppTheme.space6,
      ),
      children: [
        // ── Identity ──
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: p.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(p.avatarUrl!, fit: BoxFit.cover),
                      )
                    : Text(
                        p.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                        ),
                      ),
              ),
              const SizedBox(height: AppTheme.space4),
              Text(
                '@${p.username}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (p.displayName?.isNotEmpty ?? false) ...[
                const SizedBox(height: 2),
                Text(
                  p.displayName!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppTheme.space6),

        // ── Stats ──
        Row(
          children: [
            _StatTile(label: 'ELO', value: '${p.elo}'),
            const SizedBox(width: AppTheme.space3),
            _StatTile(label: 'LEVEL', value: '${p.level}'),
            const SizedBox(width: AppTheme.space3),
            _StatTile(label: 'XP', value: '${p.xp}'),
            const SizedBox(width: AppTheme.space3),
            _StatTile(label: 'GAMES', value: '${p.gamesPlayed}'),
          ],
        ),

        const SizedBox(height: AppTheme.space6),

        // ── Settings ──
        const AppSectionLabel('Ρυθμίσεις'),
        const SizedBox(height: AppTheme.space3),
        _SettingsRow(
          icon: Icons.language_outlined,
          title: 'Γλώσσα',
          trailing: SegmentedButton<String>(
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
        ),
        const SizedBox(height: AppTheme.space2),
        _SettingsRow(
          icon: Icons.logout_outlined,
          title: 'Αποσύνδεση',
          onTap: () => AuthService().signOut(),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppTheme.textTertiary,
            size: 18,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.space4,
          horizontal: AppTheme.space2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space4,
            vertical: AppTheme.space4,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

