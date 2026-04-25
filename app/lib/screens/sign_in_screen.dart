import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/app_background.dart';
import '../theme/app_theme.dart';
import '../theme/shake_on_error.dart';

/// Sign-in screen: email + password (primary) or email OTP (fallback).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;
  int _shakes = 0;
  bool _useOtp = false;
  bool _codeSent = false;

  void _setError(String? message) {
    setState(() {
      _error = message;
      if (message != null) _shakes++;
    });
  }

  final _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _signInWithPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      _setError('Βάλε ένα έγκυρο email');
      return;
    }
    if (password.isEmpty) {
      _setError('Βάλε τον κωδικό σου');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } catch (_) {
      if (mounted) _setError('Λάθος email ή κωδικός');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _setError('Βάλε ένα έγκυρο email');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.signInWithEmailOtp(email);
      if (!mounted) return;
      setState(() => _codeSent = true);
    } catch (e) {
      if (mounted) _setError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _setError('Ο κωδικός έχει 6 ψηφία');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.verifyEmailOtp(
        email: _emailController.text.trim(),
        token: code,
      );
    } catch (_) {
      if (mounted) _setError('Λάθος κωδικός. Δοκίμασε ξανά.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                    // ── Brand ──
                    _Brand(),
                    const SizedBox(height: AppTheme.space7),

                    ShakeOnError(
                      trigger: _shakes,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_useOtp && _codeSent)
                            _OtpForm(
                              emailController: _emailController,
                              otpController: _otpController,
                              loading: _loading,
                              onVerify: _verifyOtp,
                              onBack: () => setState(() {
                                _codeSent = false;
                                _otpController.clear();
                                _error = null;
                              }),
                            )
                          else
                            _PrimaryForm(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              useOtp: _useOtp,
                              loading: _loading,
                              onSubmit:
                                  _useOtp ? _sendOtp : _signInWithPassword,
                              onToggleMode: () => setState(() {
                                _useOtp = !_useOtp;
                                _error = null;
                              }),
                            ),
                          if (_error != null) ...[
                            const SizedBox(height: AppTheme.space4),
                            _ErrorBanner(message: _error!),
                          ],
                        ],
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Masthead eyebrow — VOL. I · IDENTITY · KAFENEIO SERIES
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
              'KAFENEIO SERIES',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Double hairline rule
        Container(height: 2, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space5),
        // Wordmark
        Text(
          'Virgil',
          textAlign: TextAlign.center,
          style: GoogleFonts.gloock(
            fontSize: 72,
            color: AppTheme.ink,
            letterSpacing: -1.5,
            height: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          'a guide for the table',
          textAlign: TextAlign.center,
          style: GoogleFonts.caveat(
            fontSize: 22,
            color: AppTheme.terra,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        // Closing double rule
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 2, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space4),
        Text(
          'ένας οδηγός για το τραπέζι',
          textAlign: TextAlign.center,
          style: GoogleFonts.kalam(
            fontSize: 14,
            color: AppTheme.inkSoft,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PrimaryForm extends StatelessWidget {
  const _PrimaryForm({
    required this.emailController,
    required this.passwordController,
    required this.useOtp,
    required this.loading,
    required this.onSubmit,
    required this.onToggleMode,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool useOtp;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline, size: 18),
          ),
        ),
        if (!useOtp) ...[
          const SizedBox(height: AppTheme.space3),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Κωδικός',
              prefixIcon: Icon(Icons.lock_outline, size: 18),
            ),
          ),
        ],
        const SizedBox(height: AppTheme.space5),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(useOtp ? 'Αποστολή κωδικού' : 'Σύνδεση'),
        ),
        const SizedBox(height: AppTheme.space3),
        TextButton(
          onPressed: onToggleMode,
          child: Text(
            useOtp ? 'Σύνδεση με κωδικό' : 'Σύνδεση με email OTP',
          ),
        ),
      ],
    );
  }
}

/// Verify-OTP view. Paper-tile digits mirroring a hidden [TextField],
/// Gloock glyphs for each digit, JetBrains Mono email echo.
class _OtpForm extends StatefulWidget {
  const _OtpForm({
    required this.emailController,
    required this.otpController,
    required this.loading,
    required this.onVerify,
    required this.onBack,
  });

  final TextEditingController emailController;
  final TextEditingController otpController;
  final bool loading;
  final VoidCallback onVerify;
  final VoidCallback onBack;

  @override
  State<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<_OtpForm> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.otpController.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.otpController.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    // Auto-verify when 6 digits are entered.
    if (widget.otpController.text.length == 6 && !widget.loading) {
      widget.onVerify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Eyebrow stamp
        Center(
          child: Text(
            'ΕΛΕΓΞΕ ΤΟ EMAIL · CHECK YOUR EMAIL',
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
            'σου στείλαμε κωδικό',
            style: GoogleFonts.caveat(
              fontSize: 22,
              color: AppTheme.ink,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            widget.emailController.text.trim(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              letterSpacing: 1,
              color: AppTheme.inkSoft,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space5),
        _OtpTiles(
          controller: widget.otpController,
          focusNode: _focusNode,
        ),
        const SizedBox(height: AppTheme.space5),
        FilledButton(
          onPressed:
              widget.loading || widget.otpController.text.length != 6
                  ? null
                  : widget.onVerify,
          child: widget.loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Επιβεβαίωση'),
        ),
        const SizedBox(height: AppTheme.space2),
        TextButton(onPressed: widget.onBack, child: const Text('Πίσω')),
      ],
    );
  }
}

/// Six paper tiles mirroring a hidden [TextField]. The field drives state;
/// the tiles render the current digit with a terra hairline underscore on
/// whichever slot the next digit will land in.
class _OtpTiles extends StatefulWidget {
  const _OtpTiles({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_OtpTiles> createState() => _OtpTilesState();
}

class _OtpTilesState extends State<_OtpTiles> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    widget.focusNode.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    widget.focusNode.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final digits = widget.controller.text.split('');
    final focusedIndex =
        widget.focusNode.hasFocus ? digits.length.clamp(0, 5) : -1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.focusNode.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 6; i++) ...[
                _DigitTile(
                  digit: i < digits.length ? digits[i] : null,
                  isFocused: i == focusedIndex,
                ),
                if (i != 5) const SizedBox(width: 6),
              ],
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLength: 6,
                autocorrect: false,
                enableSuggestions: false,
                showCursor: false,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitTile extends StatelessWidget {
  const _DigitTile({required this.digit, required this.isFocused});

  final String? digit;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.paper,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isFocused
                ? AppTheme.terra.withValues(alpha: 0.6)
                : AppTheme.border,
            width: isFocused ? 1.4 : 1,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit ?? '',
              style: GoogleFonts.gloock(
                fontSize: 30,
                color: AppTheme.ink,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 18,
              height: 1,
              color: isFocused
                  ? AppTheme.terra.withValues(alpha: 0.8)
                  : AppTheme.ink.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: const Color(0x1AE5484D),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: const Color(0x33E5484D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
