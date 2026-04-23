import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Hand-inked Virgil icons — rounded 1.8px strokes on a 48×48 grid. Paths
/// mirror those from the Virgil identity sheet (`identity_icons.jsx`).
///
/// Defined as [CustomPainter]s rather than SVG assets so they respond to
/// [currentColor] and scale cleanly on any density.
enum VirgilIconName {
  home,
  rooms,
  stats,
  profile,
}

class VirgilIcon extends StatelessWidget {
  const VirgilIcon(
    this.name, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 1.8,
  });

  final VirgilIconName name;
  final double? size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    // Pick up IconTheme values so NavigationBar / IconButton selected states
    // flow through without a manual color override.
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 22;
    final resolvedColor = color ?? iconTheme.color ?? AppTheme.ink;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: CustomPaint(
        painter: _VirgilIconPainter(
          name: name,
          color: resolvedColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _VirgilIconPainter extends CustomPainter {
  _VirgilIconPainter({
    required this.name,
    required this.color,
    required this.strokeWidth,
  });

  final VirgilIconName name;
  final Color color;
  final double strokeWidth;

  static const double _canvas = 48;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _canvas;
    canvas.save();
    canvas.scale(scale);

    final stroke = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (name) {
      case VirgilIconName.home:
        _drawHome(canvas, stroke);
      case VirgilIconName.rooms:
        _drawRooms(canvas, stroke);
      case VirgilIconName.stats:
        _drawStats(canvas, stroke);
      case VirgilIconName.profile:
        _drawProfile(canvas, stroke);
    }

    canvas.restore();
  }

  // M8 22 L24 9 L40 22   roof
  // M12 20 V39 H20 V28 H28 V39 H36 V20   walls + door
  void _drawHome(Canvas canvas, Paint stroke) {
    final roof = Path()
      ..moveTo(8, 22)
      ..lineTo(24, 9)
      ..lineTo(40, 22);
    canvas.drawPath(roof, stroke);

    final body = Path()
      ..moveTo(12, 20)
      ..lineTo(12, 39)
      ..lineTo(20, 39)
      ..lineTo(20, 28)
      ..lineTo(28, 28)
      ..lineTo(28, 39)
      ..lineTo(36, 39)
      ..lineTo(36, 20);
    canvas.drawPath(body, stroke);
  }

  // Two people seated at a table — maps to rooms/friends/lobby.
  // circles cx=18,32  cy=20 r=5
  // M8 38 Q8 30 18 30 Q24 30 24 34
  // M24 34 Q24 30 32 30 Q42 30 42 38
  void _drawRooms(Canvas canvas, Paint stroke) {
    canvas.drawCircle(const Offset(18, 20), 5, stroke);
    canvas.drawCircle(const Offset(32, 20), 5, stroke);

    final left = Path()
      ..moveTo(8, 38)
      ..quadraticBezierTo(8, 30, 18, 30)
      ..quadraticBezierTo(24, 30, 24, 34);
    canvas.drawPath(left, stroke);

    final right = Path()
      ..moveTo(24, 34)
      ..quadraticBezierTo(24, 30, 32, 30)
      ..quadraticBezierTo(42, 30, 42, 38);
    canvas.drawPath(right, stroke);
  }

  // Baseline + three bars.
  void _drawStats(Canvas canvas, Paint stroke) {
    canvas.drawLine(const Offset(8, 40), const Offset(40, 40), stroke);
    // Rectangles as stroked paths so strokeJoin is applied on corners.
    _strokedRect(canvas, stroke, const Rect.fromLTWH(12, 28, 5, 10));
    _strokedRect(canvas, stroke, const Rect.fromLTWH(21, 20, 5, 18));
    _strokedRect(canvas, stroke, const Rect.fromLTWH(30, 14, 5, 24));
  }

  void _drawProfile(Canvas canvas, Paint stroke) {
    canvas.drawCircle(const Offset(24, 18), 7, stroke);
    final shoulders = Path()
      ..moveTo(10, 40)
      ..quadraticBezierTo(10, 28, 24, 28)
      ..quadraticBezierTo(38, 28, 38, 40);
    canvas.drawPath(shoulders, stroke);
  }

  void _strokedRect(Canvas canvas, Paint stroke, Rect rect) {
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _VirgilIconPainter old) =>
      old.name != name ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
