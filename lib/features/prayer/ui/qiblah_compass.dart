import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A circular compass widget with a gold needle pointing toward the Qiblah.
///
/// [direction] is degrees clockwise from North, as returned by
/// adhan's [Qibla.direction].
class QiblahCompass extends StatelessWidget {
  final double direction;

  const QiblahCompass({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _CompassPainter(direction: direction),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double direction;

  const _CompassPainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // ── Outer ring ────────────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Inner fill
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()..color = AppColors.surface,
    );

    // ── Tick marks (every 45°) ────────────────────────────────────────────────
    final tickPaint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1;
    for (int i = 0; i < 8; i++) {
      final bearing = i * 45.0;
      final a = _bearingToAngle(bearing);
      final isCardinal = i % 2 == 0;
      final tickLen = isCardinal ? 10.0 : 6.0;
      final outer = center + Offset(radius * math.cos(a), radius * math.sin(a));
      final inner = center +
          Offset((radius - tickLen) * math.cos(a),
              (radius - tickLen) * math.sin(a));
      canvas.drawLine(inner, outer, tickPaint);
    }

    // ── Cardinal labels ───────────────────────────────────────────────────────
    _drawLabel(canvas, center, radius, 'N', 0, AppColors.gold);
    _drawLabel(canvas, center, radius, 'E', 90, AppColors.textMuted);
    _drawLabel(canvas, center, radius, 'S', 180, AppColors.textMuted);
    _drawLabel(canvas, center, radius, 'W', 270, AppColors.textMuted);

    // ── Qibla needle ──────────────────────────────────────────────────────────
    // Rotate canvas so the "up" (-y) direction aligns with the Qibla bearing.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(direction * math.pi / 180);

    // Needle tail (south side, dimmer)
    canvas.drawLine(
      const Offset(0, 14),
      const Offset(0, 0),
      Paint()
        ..color = AppColors.textMuted
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Needle body (north/Qibla side)
    final tipDist = radius - 22.0;
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, -tipDist),
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Arrowhead
    final arrowPath = Path()
      ..moveTo(0, -(tipDist))
      ..lineTo(-7, -(tipDist - 14))
      ..lineTo(7, -(tipDist - 14))
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = AppColors.gold);

    // Center dot
    canvas.drawCircle(Offset.zero, 5, Paint()..color = AppColors.gold);

    canvas.restore();

    // ── Ka'bah label at tip ───────────────────────────────────────────────────
    final tipAngle = _bearingToAngle(direction);
    final labelDist = radius - 8.0;
    _drawKaabahLabel(
      canvas,
      center + Offset(labelDist * math.cos(tipAngle), labelDist * math.sin(tipAngle)),
    );
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    double bearing,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final a = _bearingToAngle(bearing);
    final d = radius + 16;
    tp.paint(
      canvas,
      center +
          Offset(d * math.cos(a) - tp.width / 2,
              d * math.sin(a) - tp.height / 2),
    );
  }

  void _drawKaabahLabel(Canvas canvas, Offset position) {
    final tp = TextPainter(
      text: const TextSpan(
        text: '🕋',
        style: TextStyle(fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, position - Offset(tp.width / 2, tp.height / 2));
  }

  /// Converts a compass bearing (degrees CW from North) to a Flutter canvas
  /// angle (radians CCW from East = standard math angle).
  ///
  /// North (bearing 0) → canvas -y → angle = -π/2
  static double _bearingToAngle(double bearing) =>
      (bearing - 90) * math.pi / 180;

  @override
  bool shouldRepaint(_CompassPainter old) => old.direction != direction;
}
