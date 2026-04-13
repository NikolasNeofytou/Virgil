import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/estimation_service.dart';
import '../../theme/app_theme.dart';
import 'room_lobby_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _controller = TextEditingController();
  bool _joining = false;
  String? _error;
  final _service = EstimationService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.length != 4) {
      setState(() => _error = 'Ο κωδικός έχει 4 χαρακτήρες');
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
        MaterialPageRoute<void>(
          builder: (_) => RoomLobbyScreen(gameId: gameId),
        ),
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Μπες σε δωμάτιο')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Βάλε τον 4-ψήφιο κωδικό',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 4,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: 12,
                color: AppTheme.gold,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                UpperCaseTextFormatter(),
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _joining ? null : _join,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _joining
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Συμμετοχή'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
