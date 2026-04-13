import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseBootstrap.initialize();

  // TODO(A3): initialize Sentry (Env.sentryDsn) + SentryFlutter.run wrap
  // TODO(B5): initialize Firebase + FCM

  runApp(const ProviderScope(child: TichuCyprusApp()));
}
