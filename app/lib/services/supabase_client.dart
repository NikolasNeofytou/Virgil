import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Thin wrapper around [Supabase.initialize] so we can swap clients in tests
/// and keep initialization in one place.
class SupabaseBootstrap {
  SupabaseBootstrap._();

  static Future<void> initialize() async {
    Env.assertConfigured();
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
