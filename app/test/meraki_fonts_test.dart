// Smoke test for the Meraki rebrand font helpers (PR 1 of the rebrand).
//
// We only assert on the GeistMono branch here, because that is the wiring
// unique to this PR (vendored asset family declared in pubspec). The Fraunces
// and Inter branches go through `google_fonts` whose typed API is verified
// at compile time by `flutter analyze` — exercising them in a unit test
// triggers an async asset-bundle lookup that orphans the test runner.
//
// Visual smoke for all three families happens in PR 2 once the helpers are
// wired into the production TextTheme.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tichu_cyprus/theme/meraki_fonts.dart';

void main() {
  group('MerakiFonts.caption (GeistMono)', () {
    test('resolves to the vendored GeistMono family', () {
      final s = MerakiFonts.caption();
      expect(s.fontFamily, MerakiFonts.geistMonoFamily);
      expect(s.fontFamily, 'GeistMono');
    });

    test('matches deck spec (11/16, w500)', () {
      final s = MerakiFonts.caption();
      expect(s.fontSize, 11);
      expect(s.height, 16 / 11);
      expect(s.fontWeight, FontWeight.w500);
    });

    test('honours color and size overrides', () {
      const aegean = Color(0xFF1F2A5C);
      final s = MerakiFonts.caption(color: aegean, fontSize: 14);
      expect(s.color, aegean);
      expect(s.fontSize, 14);
      expect(s.fontFamily, 'GeistMono'); // family is preserved
    });
  });
}
