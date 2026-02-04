import 'package:flutter/material.dart';
import 'dart:math' as math;

class PatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  PatternPainter({
    this.color = const Color(0xFF1B5E20), // Deep Green default
    this.opacity = 0.05,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Define pattern grid size
    const double gridSize = 60.0;
    final int rows = (size.height / gridSize).ceil();
    final int cols = (size.width / gridSize).ceil();

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        // Stagger positions for organic look
        double dx = j * gridSize + (i % 2 == 0 ? 0 : gridSize / 2);
        double dy = i * gridSize;

        // Draw Crescent (simplified as two circles)
        if ((i + j) % 3 == 0) {
          _drawCrescent(canvas, paint, dx + gridSize / 2, dy + gridSize / 2, 8);
        } else if ((i + j) % 2 == 0) {
          // Draw Star
          _drawStar(canvas, paint, dx + gridSize / 2, dy + gridSize / 2, 4);
        }
      }
    }
  }

  void _drawCrescent(
      Canvas canvas, Paint paint, double x, double y, double radius) {
    // Draw base circle
    canvas.drawCircle(Offset(x, y), radius, paint);

    // Masking usually requires path operations or blend modes.
    // For simplicity and performance in standard CustomPainter without complex blend modes:
    // We will draw a crescent path.

    Path path = Path();
    path.addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));

    // Subtract a slightly offset circle to make a crescent
    Path cutout = Path();
    cutout.addOval(Rect.fromCircle(
        center: Offset(x + radius * 0.4, y - radius * 0.1),
        radius: radius * 0.9));

    final crescentPath = Path.combine(PathOperation.difference, path, cutout);
    canvas.drawPath(crescentPath, paint);
  }

  void _drawStar(
      Canvas canvas, Paint paint, double x, double y, double radius) {
    // 8-point star (Rub el Hizb style simplified)
    // Actually standard 5 point star or simple 4 point diamond for Islamic geometric feel?
    // Let's go with a simple 8-point star made of two squares rotated.

    canvas.save();
    canvas.translate(x, y);

    // First square
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: radius * 2, height: radius * 2),
        paint);

    // Second square rotated 45 degrees
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: radius * 2, height: radius * 2),
        paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
