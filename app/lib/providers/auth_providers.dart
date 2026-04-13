import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/player_profile.dart';
import '../services/supabase_client.dart';

/// Streams Supabase auth state changes. Emits the current [Session] or null.
final authStateProvider = StreamProvider<Session?>((ref) {
  final client = SupabaseBootstrap.client;
  return client.auth.onAuthStateChange.map((event) => event.session).distinct();
});

/// Currently authenticated user id, or null if signed out.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.user.id;
});

/// Fetches the `players` row for the signed-in user. Refetched whenever auth
/// state changes. Null when signed out or when the row hasn't been created yet
/// (the Supabase trigger should always create it, but the username picker
/// runs before it's safe to assume `username` is meaningful).
final currentPlayerProfileProvider = FutureProvider<PlayerProfile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final row = await SupabaseBootstrap.client
      .from('players')
      .select()
      .eq('id', userId)
      .maybeSingle();

  if (row == null) return null;
  return PlayerProfile.fromJson(row);
});

/// True once the user has picked a username (i.e. their row has a non-default
/// username). Default usernames look like `player_xxxxxxxx` — we treat them as
/// "not yet picked".
final hasPickedUsernameProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentPlayerProfileProvider).valueOrNull;
  if (profile == null) return false;
  return !profile.username.startsWith('player_');
});
