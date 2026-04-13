// Placeholder smoke test. Full widget tests land with A3.
//
// We avoid booting the real app here because it requires SUPABASE_URL and
// SUPABASE_ANON_KEY via --dart-define; see app/lib/services/env.dart.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(1 + 1, 2);
  });
}
