import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Catches incoming `virgil://login-callback/?code=…` URIs from magic-link
/// emails and OAuth redirects, then exchanges the code for a Supabase session.
///
/// Call [start] once at app startup, after [Supabase.initialize] has resolved.
/// Lives for the lifetime of the app.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  bool _started = false;

  Future<void> start() async {
    if (_started || kIsWeb) return;
    _started = true;

    final initial = await _appLinks.getInitialLink();
    if (initial != null) await _handle(initial);

    _appLinks.uriLinkStream.listen(
      _handle,
      onError: (Object e) => debugPrint('DeepLinkService stream error: $e'),
    );
  }

  Future<void> _handle(Uri uri) async {
    if (uri.scheme != 'virgil') return;
    if (uri.host != 'login-callback') return;
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint('DeepLinkService session exchange failed: $e');
    }
  }
}
