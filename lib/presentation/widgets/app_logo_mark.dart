import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Two overlapping parallelograms matching the splash brand mark.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.85),
      painter: _LogoPainter(),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final skew = w * 0.18;

    Path parallelogram(Offset origin, double dx) {
      final p = Path()
        ..moveTo(origin.dx + skew, origin.dy)
        ..lineTo(origin.dx + w * 0.55 + skew, origin.dy)
        ..lineTo(origin.dx + w * 0.55, origin.dy + h * 0.62)
        ..lineTo(origin.dx, origin.dy + h * 0.62)
        ..close();
      return p;
    }

    final back = Paint()..color = AppColors.accentPurple;
    final front = Paint()..color = AppColors.logoBlue;

    canvas.save();
    canvas.translate(w * 0.08, h * 0.12);
    canvas.rotate(-12 * math.pi / 180);
    canvas.drawPath(parallelogram(Offset.zero, 0), back);
    canvas.drawPath(parallelogram(Offset(w * 0.12, h * 0.18), 0), front);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
