import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/estimation_service.dart';
import '../../theme/app_background.dart';
import '../../theme/app_route.dart';
import '../../theme/app_theme.dart';
import '../../theme/shake_on_error.dart';
import 'room_lobby_screen.dart';
import '../../theme/meraki_fonts.dart';

/// Join-room screen. Renders four paper tiles that mirror a single hidden
/// [TextField] so we get the full keyboard / paste / autofill experience
/// while showing the code as Gloock glyphs on individual receipts.
///
/// Auto-submits when the fourth character lands.
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _joining = false;
  String? _error;
  int _shakes = 0;
  final _service = EstimationService();

  void _setError(String message) {
    setState(() {
      _error = message;
      _shakes++;
      _joining = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() => _error = null);
    if (_controller.text.length == 4 && !_joining) {
      _join();
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim().toUpperCase() ?? '';
    if (text.isEmpty) return;
    // Only keep valid code characters; cap at 4.
    final filtered =
        text.replaceAll(RegExp('[^A-Z0-9]'), '').substring(0, text.length.clamp(0, 4));
    _controller.value = TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }

  Future<void> _join() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.length != 4) {
      _setError('ο κωδικός έχει 4 χαρακτήρες');
      return;
    }
    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      final gameId = await _service.joinGameByCode(code);
      if (!mounted) return;
      Navigator.of(context).pushReplacement<void, void>(
        AppRoute.build((_) => RoomLobbyScreen(gameId: gameId)),
      );
    } on Object catch (e) {
      if (mounted) {
        _setError(
          e.toString().replaceFirst('Bad state: ', '').toLowerCase(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Μπες σε δωμάτιο')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppTheme.space4),
                    _MiniMasthead(),
                    const SizedBox(height: AppTheme.space6),

                    const AppSectionLabel(
                      '§ 01 · ΚΩΔΙΚΟΣ · CODE',
                      showRule: true,
                    ),
                    const SizedBox(height: AppTheme.space4),
                    ShakeOnError(
                      trigger: _shakes,
                      child: _CodeEntry(
                        controller: _controller,
                        focusNode: _focusNode,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space3),
                    Center(
                      child: TextButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.content_paste, size: 14),
                        label: const Text('επικόλληση'),
                      ),
                    ),

                    const Spacer(),

                    FilledButton(
                      onPressed: _joining || _controller.text.length != 4
                          ? null
                          : _join,
                      child: _joining
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Συμμετοχή'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppTheme.space3),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
                          color: AppTheme.danger,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.space2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniMasthead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VOL. I · APR 2026',
              style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
            Text(
              'KAFENEIO',
              style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
                fontSize: 9,
                letterSpacing: 3,
                color: AppTheme.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 1.5, color: AppTheme.ink),
        const SizedBox(height: 2),
        Container(height: 0.5, color: AppTheme.ink),
        const SizedBox(height: AppTheme.space3),
        Center(
          child: Text(
            'Μπες στο δωμάτιο',
            style: GoogleFonts.fraunces(
              fontSize: 36,
              color: AppTheme.ink,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'στο ίδιο τραπέζι',
            style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
              fontSize: 20,
              color: AppTheme.terra,
            ),
          ),
        ),
      ],
    );
  }
}

/// Four paper tiles that mirror a hidden [TextField]. Tapping anywhere on
/// the row focuses the underlying field so the keyboard pops up.
class _CodeEntry extends StatefulWidget {
  const _CodeEntry({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_CodeEntry> createState() => _CodeEntryState();
}

class _CodeEntryState extends State<_CodeEntry> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    widget.focusNode.addListener(_rebuild);
    // Autofocus on next frame so the keyboard appears on mount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    widget.focusNode.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.controller.text.split('');
    final focusedIndex =
        widget.focusNode.hasFocus ? chars.length.clamp(0, 3) : -1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.focusNode.requestFocus(),
      child: Stack(
        children: [
          // Visible tiles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 4; i++) ...[
                _CodeTile(
                  character: i < chars.length ? chars[i] : null,
                  isFocused: i == focusedIndex,
                ),
                if (i != 3) const SizedBox(width: AppTheme.space2),
              ],
            ],
          ),
          // Invisible text field covers the whole row to capture input.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLength: 4,
                autocorrect: false,
                enableSuggestions: false,
                showCursor: false,
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('[A-Za-z0-9]'),
                  ),
                  _UpperCaseFormatter(),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeTile extends StatelessWidget {
  const _CodeTile({required this.character, required this.isFocused});

  final String? character;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.paper,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isFocused
                ? AppTheme.terra.withValues(alpha: 0.6)
                : AppTheme.border,
            width: isFocused ? 1.4 : 1,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              character ?? '',
              style: GoogleFonts.fraunces(
                fontSize: 44,
                color: AppTheme.ink,
                height: 1.0,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            // A short ink hairline underscore that darkens when focused.
            Container(
              width: 28,
              height: 1.5,
              color: isFocused
                  ? AppTheme.terra.withValues(alpha: 0.8)
                  : AppTheme.ink.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
