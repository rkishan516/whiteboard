import 'package:flutter/material.dart';
import 'package:whiteboard/src/models.dart';

/// Subclass of [CustomPainter] to paint strokes
class FreehandPainter extends CustomPainter {
  final List<WhiteBoardStroke> strokes;
  final Color backgroundColor;

  FreehandPainter(
    this.strokes,
    this.backgroundColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    for (final stroke in strokes) {
      final paint = Paint()
        ..strokeWidth = stroke.width
        ..color = stroke.erase ? Colors.transparent : stroke.color
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..blendMode = stroke.erase ? BlendMode.clear : BlendMode.srcOver;
      canvas.drawPath(stroke.path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
