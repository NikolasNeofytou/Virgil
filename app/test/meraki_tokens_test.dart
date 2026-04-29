// MerakiTokens — copyWith, lerp, and `of(context)` smoke.
//
// Most unit tests use a raw fixture (`_fixture()`) instead of
// `MerakiTokens.light`, because the `light` getter calls google_fonts which
// tries to fetch Fraunces from the live runtime. In a unit-test context that
// schedules an orphaned async load and crashes the test runner. The
// `MerakiTokens.of(context)` test below pumps a real MaterialApp, where the
// async load resolves cleanly inside the widget binding.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tichu_cyprus/theme/app_theme.dart';
import 'package:tichu_cyprus/theme/meraki_tokens.dart';

MerakiTokens _fixture({
  Color aegean = const Color(0xFF1F2A5C),
  Color ochre = const Color(0xFFC39448),
  Color bone = const Color(0xFFEBE2D3),
  double radiusHero = 16,
}) =>
    MerakiTokens(
      aegean: aegean,
      ochre: ochre,
      ochreMuted: const Color(0x33C39448),
      myrtleMuted: const Color(0x334F6B5C),
      coralMuted: const Color(0x33D9573F),
      bone: bone,
      radiusHero: radiusHero,
      // Plain TextStyles — no google_fonts in unit-test scope.
      italicVerb: const TextStyle(
        fontSize: 17,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
      ),
      eyebrow: const TextStyle(
        fontFamily: 'GeistMono',
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
      ),
      scoreOldstyle: const TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w500,
        fontFeatures: [FontFeature.oldstyleFigures()],
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('MerakiTokens.copyWith', () {
    test('overrides only the named fields', () {
      const newAegean = Color(0xFF000000);
      final base = _fixture();
      final swapped = base.copyWith(aegean: newAegean);
      expect(swapped.aegean, newAegean);
      expect(swapped.ochre, base.ochre);
      expect(swapped.bone, base.bone);
      expect(swapped.radiusHero, base.radiusHero);
    });
  });

  group('MerakiTokens.lerp', () {
    test('t=0 returns this', () {
      final a = _fixture();
      final b = a.copyWith(aegean: const Color(0xFF000000));
      final out = a.lerp(b, 0.0);
      expect(out.aegean, a.aegean);
    });

    test('t=1 returns other', () {
      final a = _fixture();
      final b = a.copyWith(aegean: const Color(0xFF000000));
      final out = a.lerp(b, 1.0);
      expect(out.aegean, b.aegean);
    });

    test('t=0.5 sits between the endpoints (radiusHero 16 → 32 → 24)', () {
      final a = _fixture(radiusHero: 16);
      final b = a.copyWith(radiusHero: 32);
      final out = a.lerp(b, 0.5);
      expect(out.radiusHero, 24);
    });

    test('returns this when other is not MerakiTokens', () {
      final a = _fixture();
      final out = a.lerp(null, 0.5);
      expect(identical(out, a), isTrue);
    });
  });

  group('MerakiTokens fixture parity with deck spec', () {
    test('eyebrow style points at the vendored GeistMono family', () {
      final t = _fixture();
      expect(t.eyebrow.fontFamily, 'GeistMono');
      expect(t.eyebrow.fontSize, 11);
      expect(t.eyebrow.fontWeight, FontWeight.w500);
    });

    test('scoreOldstyle requests oldstyle figures', () {
      final t = _fixture();
      expect(
        t.scoreOldstyle.fontFeatures,
        contains(const FontFeature.oldstyleFigures()),
      );
      expect(t.scoreOldstyle.fontWeight, FontWeight.w500);
    });

    test('italicVerb is italic 500', () {
      final t = _fixture();
      expect(t.italicVerb.fontStyle, FontStyle.italic);
      expect(t.italicVerb.fontWeight, FontWeight.w500);
    });
  });

  group('MerakiTokens.of(context)', () {
    testWidgets('reads the registered extension off ThemeData', (tester) async {
      MerakiTokens? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(builder: (ctx) {
            captured = MerakiTokens.of(ctx);
            return const SizedBox.shrink();
          },),
        ),
      );
      expect(captured, isNotNull);
      expect(captured!.aegean, AppTheme.aegean);
      expect(captured!.radiusHero, 16);
      expect(captured!.bone, AppTheme.bone);
    });
  });
}
