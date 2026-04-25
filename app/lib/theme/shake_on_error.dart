import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps [child] and replays a horizontal shake animation every time
/// [trigger] changes. Pair with a counter that you increment on each invalid
/// attempt.
///
/// Usage:
/// ```dart
/// int _shakes = 0;
/// // on validation failure:
/// setState(() { _error = '...'; _shakes++; });
/// // in build:
/// ShakeOnError(trigger: _shakes, child: _form());
/// ```
class ShakeOnError extends StatefulWidget {
  const ShakeOnError({
    super.key,
    required this.trigger,
    required this.child,
    this.haptic = true,
  });

  /// Increment this on each invalid attempt to replay the shake.
  final int trigger;

  /// When true, fires `HapticFeedback.heavyImpact()` whenever [trigger]
  /// changes — keeps the visual + tactile feedback in sync.
  final bool haptic;

  final Widget child;

  @override
  State<ShakeOnError> createState() => _ShakeOnErrorState();
}

class _ShakeOnErrorState extends State<ShakeOnError> {
  @override
  void didUpdateWidget(covariant ShakeOnError oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger && widget.haptic) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trigger == 0) return widget.child;
    // ValueKey on Animate forces a fresh state when trigger changes, which
    // restarts the effect from t=0.
    return Animate(
      key: ValueKey<int>(widget.trigger),
      effects: const [
        ShakeEffect(
          duration: Duration(milliseconds: 280),
          hz: 7,
          offset: Offset(8, 0),
        ),
      ],
      child: widget.child,
    );
  }
}
