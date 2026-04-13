/// Compile-time environment variables.
///
/// Read via `--dart-define-from-file=.env` (preferred) or individual
/// `--dart-define=KEY=value` flags. We avoid reading `.env` at runtime to
/// keep secrets out of the app bundle and to make release builds reproducible.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Phase B only.
  static const String gameServerWsUrl = String.fromEnvironment(
    'GAME_SERVER_WS_URL',
    defaultValue: '',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Throws [StateError] early if required vars are missing.
  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
        'Run with --dart-define-from-file=.env',
      );
    }
  }
}
