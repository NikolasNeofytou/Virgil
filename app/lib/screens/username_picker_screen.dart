import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../services/supabase_client.dart';
import '../theme/app_background.dart';
import '../theme/app_theme.dart';

/// Shown once, right after first sign-in. Username must be 3-24 chars,
/// alphanumeric + underscore, and globally unique.
class UsernamePickerScreen extends ConsumerStatefulWidget {
  const UsernamePickerScreen({super.key});

  @override
  ConsumerState<UsernamePickerScreen> createState() =>
      _UsernamePickerScreenState();
}

class _UsernamePickerScreenState extends ConsumerState<UsernamePickerScreen> {
  final _controller = TextEditingController();
  static final _re = RegExp(r'^[a-zA-Z0-9_]{3,24}$');
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    final username = _controller.text.trim();
    if (!_re.hasMatch(username)) {
      setState(() => _error = '3–24 χαρακτήρες: γράμματα, αριθμοί, _');
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
            : 'Σφάλμα: $e';
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
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space6,
                  vertical: AppTheme.space5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.goldMuted,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppTheme.gold,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space4),
                    Text(
                      'Διάλεξε username',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppTheme.space2),
                    Text(
                      'Έτσι θα σε βλέπουν οι φίλοι σου',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppTheme.space6),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLength: 24,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9_]'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        prefixText: '@ ',
                        prefixStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                        labelText: 'username',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppTheme.space4),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Συνέχεια'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppTheme.space4),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
