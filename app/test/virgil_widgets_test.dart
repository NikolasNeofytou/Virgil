// Smoke tests for the five Virgil widgets — assert that each one builds in
// a real ThemeData (with MerakiTokens registered) and renders the expected
// text / variant. We don't assert on pixels — golden tests would belong with
// PR 4+ once visual specs are nailed down screen by screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tichu_cyprus/theme/app_theme.dart';
import 'package:tichu_cyprus/widgets/virgil_button.dart';
import 'package:tichu_cyprus/widgets/virgil_card.dart';
import 'package:tichu_cyprus/widgets/virgil_chip.dart';
import 'package:tichu_cyprus/widgets/virgil_ornament.dart';
import 'package:tichu_cyprus/widgets/virgil_score.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('VirgilButton', () {
    testWidgets('primary variant builds and shows the label', (tester) async {
      await tester.pumpWidget(_wrap(
        VirgilButton(label: 'Sit', onPressed: () {}),
      ),);
      expect(find.text('Sit'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('trailingArrow appends "→" to the label', (tester) async {
      await tester.pumpWidget(_wrap(
        VirgilButton(
          label: 'Continue',
          onPressed: () {},
          trailingArrow: true,
        ),
      ),);
      expect(find.text('Continue →'), findsOneWidget);
    });

    testWidgets('ghost variant uses TextButton', (tester) async {
      await tester.pumpWidget(_wrap(
        VirgilButton(
          label: 'Cancel',
          onPressed: () {},
          variant: VirgilButtonVariant.ghost,
        ),
      ),);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('null onPressed disables the button', (tester) async {
      await tester.pumpWidget(_wrap(
        const VirgilButton(label: 'Locked', onPressed: null),
      ),);
      final FilledButton btn = tester.widget(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('VirgilChip', () {
    testWidgets('renders the label uppercased', (tester) async {
      await tester.pumpWidget(_wrap(
        const VirgilChip(label: 'online', variant: VirgilChipVariant.success),
      ),);
      expect(find.text('ONLINE'), findsOneWidget);
    });

    testWidgets('dot adds a leading circle indicator', (tester) async {
      await tester.pumpWidget(_wrap(
        const VirgilChip(
          label: 'live',
          variant: VirgilChipVariant.accent,
          dot: true,
        ),
      ),);
      // Two Containers — outer pill + inner dot.
      expect(find.byType(Container), findsNWidgets(2));
    });

    testWidgets('all four variants build without error', (tester) async {
      for (final v in VirgilChipVariant.values) {
        await tester.pumpWidget(_wrap(
          VirgilChip(label: v.name, variant: v),
        ),);
        expect(find.text(v.name.toUpperCase()), findsOneWidget);
      }
    });
  });

  group('VirgilCard', () {
    testWidgets('standard variant builds with the child', (tester) async {
      await tester.pumpWidget(_wrap(
        const VirgilCard(child: Text('hello')),
      ),);
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('hero variant builds with the child', (tester) async {
      await tester.pumpWidget(_wrap(
        const VirgilCard(
          variant: VirgilCardVariant.hero,
          child: Text('featured'),
        ),
      ),);
      expect(find.text('featured'), findsOneWidget);
    });

    testWidgets('onTap wires an InkWell', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(
        VirgilCard(
          onTap: () => taps++,
          child: const Text('tap me'),
        ),
      ),);
      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.text('tap me'));
      expect(taps, 1);
    });
  });

  group('VirgilOrnament', () {
    testWidgets('default glyph is §', (tester) async {
      await tester.pumpWidget(_wrap(const VirgilOrnament()));
      expect(find.text('§'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('custom glyph renders verbatim', (tester) async {
      await tester.pumpWidget(_wrap(const VirgilOrnament(glyph: '·')));
      expect(find.text('·'), findsOneWidget);
    });
  });

  group('VirgilScore', () {
    testWidgets('single value renders as just the number', (tester) async {
      await tester.pumpWidget(_wrap(const VirgilScore(value: 247)));
      expect(find.text('247'), findsOneWidget);
    });

    testWidgets('outOf renders as a fraction with the U+2044 slash',
        (tester) async {
      await tester.pumpWidget(_wrap(const VirgilScore(value: 21, outOf: 14)));
      expect(find.text('21⁄14'), findsOneWidget);
    });

    testWidgets('color override is honoured', (tester) async {
      await tester.pumpWidget(_wrap(
        const VirgilScore(value: 7, color: Color(0xFFD9573F)),
      ),);
      final Text text = tester.widget(find.byType(Text));
      expect(text.style?.color, const Color(0xFFD9573F));
    });
  });
}
