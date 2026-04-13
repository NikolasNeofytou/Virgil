import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../services/supabase_client.dart';
import '../theme/app_theme.dart';

/// Shown once, right after first sign-in. Username must be 3-24 chars,
/// alphanumeric + underscore, and globally unique. Matches the DB check
/// constraint in `0001_players.sql`.
class UsernamePickerScreen extends ConsumerStatefulWidget {
  const UsernamePickerScreen({super.key});

  @override
  ConsumerState<UsernamePickerScreen> createState() => _UsernamePickerScreenState();
}

class _UsernamePickerScreenState extends ConsumerState<UsernamePickerScreen> {
  final _controller = TextEditingController();
  static final _re = RegExp(r'^[a-zA-Z0-9_]{3,24}$');
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    final username = _controller.text.trim();
    if (!_re.hasMatch(username)) {
      setState(() => _error = '3-24 χαρακτήρες: γράμματα, αριθμοί, _');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final userId = SupabaseBootstrap.client.auth.currentUser!.id;
      await SupabaseBootstrap.client
          .from('players')
          .update({'username': username})
          .eq('id', userId);
      ref.invalidate(currentPlayerProfileProvider);
    } on Object catch (e) {
      setState(() {
        _error = e.toString().contains('players_username_key')
            ? 'Αυτό το username υπάρχει ήδη'
            : e.toString();
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Διάλεξε username',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Έτσι θα σε βλέπουν οι φίλοι σου',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 24,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                ],
                decoration: const InputDecoration(
                  prefixText: '@ ',
                  labelText: 'username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Συνέχεια'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.danger),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
