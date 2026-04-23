import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/app_background.dart';
import '../theme/app_theme.dart';

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
  bool _useOtp = false;
  bool _codeSent = false;

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
      setState(() => _error = 'Βάλε ένα έγκυρο email');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Βάλε τον κωδικό σου');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } catch (_) {
      if (mounted) setState(() => _error = 'Λάθος email ή κωδικός');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Βάλε ένα έγκυρο email');
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
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Ο κωδικός έχει 6 ψηφία');
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
      if (mounted) setState(() => _error = 'Λάθος κωδικός. Δοκίμασε ξανά.');
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
                        onSubmit: _useOtp ? _sendOtp : _signInWithPassword,
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

class _OtpForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
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
          child: const Icon(Icons.mark_email_read_outlined,
              color: AppTheme.gold, size: 28,),
        ),
        const SizedBox(height: AppTheme.space4),
        Text(
          'Έλεγξε το email σου',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.space1),
        Text(
          emailController.text.trim(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: AppTheme.space5),
        TextField(
          controller: otpController,
          autofocus: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 10,
            color: AppTheme.gold,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: TextStyle(
              fontSize: 28,
              letterSpacing: 10,
              color: AppTheme.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        FilledButton(
          onPressed: loading ? null : onVerify,
          child: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Επιβεβαίωση'),
        ),
        const SizedBox(height: AppTheme.space2),
        TextButton(onPressed: onBack, child: const Text('Πίσω')),
      ],
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
