import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/generated/app_localizations.dart';
import 'providers/auth_providers.dart';
import 'providers/locale_provider.dart';
import 'screens/home_shell.dart';
import 'screens/sign_in_screen.dart';
import 'screens/username_picker_screen.dart';
import 'theme/app_background.dart';
import 'theme/app_theme.dart';

class TichuCyprusApp extends ConsumerWidget {
  const TichuCyprusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(activeLocaleProvider);
    return MaterialApp(
      title: 'Virgil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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

/// Splash. Plays the design's SceneLaunch motion on mount:
///
///   0.00 → 0.50  "Virgil" wordmark ink-bleeds into focus (scale 0.6→1.0
///                with a slight overshoot, Gaussian blur 3→0.6)
///   0.25 → 0.70  terracotta rule underline sweeps outward from center
///   0.55 → 1.00  Caveat tagline fades in
///
/// Held indefinitely once the animation completes — the auth state
/// stream decides when to swap this screen out.
class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Custom "ink-settle" curve — overshoots to 1.08 then relaxes to 1.0.
  double _inkSettle(double t) {
    if (t < 0.7) return (t / 0.7) * 1.08;
    final k = (t - 0.7) / 0.3;
    return 1.08 - 0.08 * k;
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = _ctrl.value;
              final wordT = (t / 0.5).clamp(0.0, 1.0);
              final ruleT = ((t - 0.25) / 0.45).clamp(0.0, 1.0);
              final tagT = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
              final scale = 0.6 + 0.4 * _inkSettle(wordT);
              final blurSigma = 0.6 + 3.0 * (1 - wordT);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: wordT,
                    child: Transform.scale(
                      scale: scale,
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: blurSigma,
                          sigmaY: blurSigma,
                        ),
                        child: Text(
                          'Virgil',
                          style: GoogleFonts.fraunces(
                            fontSize: 72,
                            color: AppTheme.ink,
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space2),
                  Container(
                    height: 1,
                    width: 120 * Curves.easeOutCubic.transform(ruleT),
                    color: AppTheme.terra.withValues(alpha: 0.6 * ruleT),
                  ),
                  const SizedBox(height: AppTheme.space3),
                  Opacity(
                    opacity: tagT,
                    child: Text(
                      'a guide for the table',
                      style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                        fontSize: 20,
                        color: AppTheme.terra,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
