import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_providers.dart';
import 'screens/home_shell.dart';
import 'screens/sign_in_screen.dart';
import 'screens/username_picker_screen.dart';
import 'theme/app_background.dart';
import 'theme/app_theme.dart';

class TichuCyprusApp extends ConsumerWidget {
  const TichuCyprusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Virgil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
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
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Virgil',
                style: GoogleFonts.gloock(
                  fontSize: 72,
                  color: AppTheme.ink,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: AppTheme.space2),
              Container(
                height: 1,
                width: 120,
                color: AppTheme.terra.withValues(alpha: 0.6),
              ),
              const SizedBox(height: AppTheme.space3),
              Text(
                'a guide for the table',
                style: GoogleFonts.caveat(
                  fontSize: 20,
                  color: AppTheme.terra,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
