import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_client.dart';
import '../../theme/app_theme.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentPlayerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Προφίλ')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Σφάλμα: $e')),
        data: (p) {
          if (p == null) return const Center(child: Text('—'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppTheme.surfaceElevated,
                  backgroundImage:
                      p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
                  child: p.avatarUrl == null
                      ? Text(
                          p.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.gold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Username
              Text(
                '@${p.username}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (p.displayName != null && p.displayName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  p.displayName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
              const SizedBox(height: 24),

              // Stat cards
              Row(
                children: [
                  _StatCard(label: 'ELO', value: '${p.elo}', icon: Icons.emoji_events),
                  const SizedBox(width: 10),
                  _StatCard(label: 'Level', value: '${p.level}', icon: Icons.star),
                  const SizedBox(width: 10),
                  _StatCard(label: 'XP', value: '${p.xp}', icon: Icons.bolt),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatCard(
                    label: 'Παιχνίδια',
                    value: '${p.gamesPlayed}',
                    icon: Icons.style,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Γλώσσα',
                    value: p.locale == 'el' ? 'Ελληνικά' : 'English',
                    icon: Icons.language,
                  ),
                  const SizedBox(width: 10),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 28),

              // Locale toggle
              _SettingsTile(
                icon: Icons.language,
                title: 'Γλώσσα / Language',
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'el', label: Text('EL')),
                    ButtonSegment(value: 'en', label: Text('EN')),
                  ],
                  selected: {p.locale},
                  onSelectionChanged: (s) async {
                    final locale = s.first;
                    await SupabaseBootstrap.client
                        .from('players')
                        .update({'locale': locale})
                        .eq('id', p.id);
                    ref.invalidate(currentPlayerProfileProvider);
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Sign out
              _SettingsTile(
                icon: Icons.logout,
                title: 'Αποσύνδεση',
                onTap: () => AuthService().signOut(),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.gold, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
