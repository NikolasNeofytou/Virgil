import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

/// Wraps [GoTrueClient] with the three sign-in methods we support in A1:
/// email (magic link / OTP), Google, Apple.
class AuthService {
  AuthService({GoTrueClient? auth})
      : _auth = auth ?? SupabaseBootstrap.client.auth;

  final GoTrueClient _auth;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithEmailOtp(String email) async {
    await _auth.signInWithOtp(
      email: email,
      emailRedirectTo: kIsWeb ? null : 'virgil://login-callback/',
    );
  }

  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) {
    return _auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: token,
    );
  }

  Future<bool> signInWithGoogle() {
    return _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'virgil://login-callback/',
    );
  }

  Future<bool> signInWithApple() {
    return _auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: kIsWeb ? null : 'virgil://login-callback/',
    );
  }

  Future<void> signOut() => _auth.signOut();
}
