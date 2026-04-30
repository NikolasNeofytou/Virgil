import 'dart:io';

import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';

/// One of the three Meraki app-icon variants from deck §04.B.
///
/// `alternateName` matches the key under `CFBundleAlternateIcons` in
/// `ios/Runner/Info.plist`; `null` means the primary `AppIcon` set.
/// `assetName` is the in-app preview asset for the Profile picker.
enum AppIconVariant {
  aegean(null, 'assets/icon/icon.png'),
  coral('Coral', 'assets/icon/icon_coral.png'),
  ochre('Ochre', 'assets/icon/icon_ochre.png');

  const AppIconVariant(this.alternateName, this.assetName);

  final String? alternateName;
  final String assetName;
}

/// iOS-only thin wrapper over `flutter_dynamic_icon_plus`. Android and
/// other platforms always report the Aegean default and reject sets —
/// the Profile picker UI is hidden entirely on those platforms.
class AppIconService {
  /// Cheap synchronous gate — Android/desktop builds shouldn't even
  /// surface the picker.
  bool get platformSupported => Platform.isIOS;

  /// Runtime check — true only when the iOS build's Info.plist actually
  /// declares CFBundleAlternateIcons. False on iPad if alternates aren't
  /// configured for that idiom, or on iOS versions older than 10.3.
  Future<bool> get available async {
    if (!platformSupported) return false;
    return FlutterDynamicIconPlus.supportsAlternateIcons;
  }

  /// The currently active variant, defaulting to Aegean when no
  /// alternate is set or the platform doesn't support switching.
  Future<AppIconVariant> current() async {
    if (!platformSupported) return AppIconVariant.aegean;
    final name = await FlutterDynamicIconPlus.alternateIconName;
    return AppIconVariant.values.firstWhere(
      (v) => v.alternateName == name,
      orElse: () => AppIconVariant.aegean,
    );
  }

  /// Switch to [variant]. iOS shows a system confirmation modal — that
  /// behaviour is built into the platform and not worth suppressing
  /// (private-API workarounds are App Store review risks).
  Future<void> setVariant(AppIconVariant variant) async {
    if (!platformSupported) return;
    await FlutterDynamicIconPlus.setAlternateIconName(
      iconName: variant.alternateName,
    );
  }
}
