import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Sign-in screen: email → 6-digit OTP code → signed in.
/// No deep linking required — works perfectly on emulators.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _codeSent = false;

  final _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
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
      // Auth state change is picked up by authStateProvider → auth gate.
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Λάθος κωδικός. Δοκίμασε ξανά.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

              // Title
              Text(
                'Tichu Cyprus',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Το παιχνίδι καρτών της Κύπρου',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const Spacer(),

              if (_codeSent) ...[
                // Step 2: Enter 6-digit OTP code
                const Icon(Icons.mark_email_read, color: AppTheme.gold, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Στείλαμε κωδικό στο\n${_emailController.text.trim()}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _otpController,
                  autofocus: true,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12,
                    color: AppTheme.gold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '------',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _verifyOtp,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Επιβεβαίωση'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _codeSent = false;
                    _otpController.clear();
                    _error = null;
                  }),
                  child: const Text('Χρήση άλλου email'),
                ),
              ] else ...[
                // Step 1: Enter email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loading ? null : _sendOtp,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Αποστολή κωδικού'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child:
                          Text('ή', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _auth.signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Συνέχεια με Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _auth.signInWithApple(),
                  icon: const Icon(Icons.apple),
                  label: const Text('Συνέχεια με Apple'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],

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
