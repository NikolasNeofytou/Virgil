import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_icon_service.dart';

/// The currently active iOS app-icon variant. Resolves to Aegean on
/// Android / desktop / older iOS versions. Invalidated by the Profile
/// picker after a successful switch so the new selection ring renders.
final currentAppIconProvider =
    FutureProvider<AppIconVariant>((ref) async {
  return AppIconService().current();
});

/// Whether dynamic icon switching is wired up and usable on this device.
/// Used by the Profile picker to hide the section entirely on Android.
final appIconSupportedProvider = FutureProvider<bool>((ref) async {
  return AppIconService().available;
});
