import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_providers.dart';
import 'screens/home_shell.dart';
import 'screens/sign_in_screen.dart';
import 'screens/username_picker_screen.dart';
import 'theme/app_theme.dart';

class TichuCyprusApp extends ConsumerWidget {
  const TichuCyprusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tichu Cyprus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const _AuthGate(),
    );
  }
}

/// Three-state auth gate:
/// 1. Signed out       → [SignInScreen]
/// 2. Signed in, no username → [UsernamePickerScreen]
/// 3. Signed in, has username → [HomeShell]
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return auth.when(
      loading: () => const _Splash(),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Auth error: $e')),
      ),
      data: (session) {
        if (session == null) return const SignInScreen();
        final hasUsername = ref.watch(hasPickedUsernameProvider);
        if (!hasUsername) return const UsernamePickerScreen();
        return const HomeShell();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Tichu Cyprus',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.gold,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
