import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_error != null && mounted) setState(() => _error = null);
    });
  }

  Future<void> _save() async {
    final username = _controller.text.trim();
    if (!_re.hasMatch(username)) {
      setState(() => _error = '3–24 χαρακτήρες · γράμματα, αριθμοί, _');
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
            ? 'αυτό το όνομα υπάρχει ήδη'
            : 'σφάλμα · δοκίμασε ξανά';
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
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space5,
                  vertical: AppTheme.space5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MiniMasthead(),
                    const SizedBox(height: AppTheme.space6),

                    Center(
                      child: Text(
                        '§ 01 · ΟΝΟΜΑ · NAME',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3,
                          color: AppTheme.terra,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space3),
                    Center(
                      child: Text(
                        'Διάλεξε όνομα',
                        style: GoogleFonts.gloock(
                          fontSize: 40,
                          color: AppTheme.ink,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'το όνομά σου στο τραπέζι',
                        style: GoogleFonts.caveat(
                          fontSize: 20,
                          color: AppTheme.terra,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space5),

                    _UsernameField(
                      controller: _controller,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: AppTheme.space2),
                    Center(
                      child: Text(
                        '3–24 χαρακτήρες · γράμματα, αριθμοί, _',
                        style: GoogleFonts.kalam(
                          fontSize: 12,
                          color: AppTheme.inkFaint,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.space5),
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
                      const SizedBox(height: AppTheme.space3),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.caveat(
                          color: AppTheme.danger,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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

/// Paper card wrapping the username text field. Gloock `@` prefix +
/// Caveat user input; terra underline grows as the name becomes valid.
class _UsernameField extends StatefulWidget {
  const _UsernameField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  State<_UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<_UsernameField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
    _focus.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    _focus.removeListener(_rebuild);
    widget.controller.removeListener(_rebuild);
    _focus.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focus.hasFocus;
    final hasText = widget.controller.text.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: hasFocus
              ? AppTheme.terra.withValues(alpha: 0.6)
              : AppTheme.border,
          width: hasFocus ? 1.4 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '@',
            style: GoogleFonts.gloock(
              fontSize: 24,
              color: hasText ? AppTheme.terra : AppTheme.inkFaint,
              height: 1.0,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              maxLength: 24,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              style: GoogleFonts.caveat(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                height: 1.2,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9_]'),
                ),
              ],
              decoration: InputDecoration(
                counterText: '',
                hintText: 'όνομα…',
                hintStyle: GoogleFonts.caveat(
                  fontSize: 24,
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
        ],
      ),
    );
  }
}

class _MiniMasthead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VOL. I · APR 2026',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
            Text(
              'KAFENEIO',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 2, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space3),
        Center(
          child: Text(
            'Virgil',
            style: GoogleFonts.gloock(
              fontSize: 56,
              color: AppTheme.ink,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: Text(
            'a guide for the table',
            style: GoogleFonts.caveat(
              fontSize: 18,
              color: AppTheme.terra,
            ),
          ),
        ),
      ],
    );
  }
}
