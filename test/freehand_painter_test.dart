import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:whiteboard/src/freehand_painter.dart';
import 'package:whiteboard/src/models.dart';

class MockCanvas extends Mock implements Canvas {}

class MockPath extends Mock implements Path {}

void main() {
  group('FreehandPainter', () {
    late FreehandPainter painter;
    late MockCanvas canvas;
    late Size size;
    late List<WhiteBoardStroke> strokes;

    setUp(() {
      registerFallbackValue(Paint());
      registerFallbackValue(Path());
      registerFallbackValue(Rect.zero);
      canvas = MockCanvas();
      size = const Size(200, 100);
      strokes = [];
      painter = FreehandPainter(strokes, Colors.white);
    });

    test('paints background color', () {
      painter.paint(canvas, size);

      verify(() => canvas.drawRect(any(), any()))
          .called(1); // Verify background is drawn
    });

    test('paints single stroke', () {
      strokes.add(WhiteBoardStroke(
        color: Colors.black,
        width: 5.0,
        erase: false,
      ));

      painter = FreehandPainter(strokes, Colors.white);
      painter.paint(canvas, size);

      verify(() => canvas.drawPath(any(), any())).called(1);
    });

    test('paints multiple strokes', () {
      strokes.add(WhiteBoardStroke(
        color: Colors.black,
        width: 5.0,
        erase: false,
      ));
      strokes.add(WhiteBoardStroke(
        color: Colors.red,
        width: 2.0,
        erase: false,
      ));

      painter = FreehandPainter(strokes, Colors.white);
      painter.paint(canvas, size);

      verify(() => canvas.drawPath(any(), any())).called(2);
    });

    test('paints erase stroke with transparent color and clear blend mode', () {
      strokes.add(WhiteBoardStroke(
        color: Colors.black, // Color shouldn't matter for erase
        width: 10.0,
        erase: true,
      ));

      painter = FreehandPainter(strokes, Colors.white);
      painter.paint(canvas, size);

      final capturedPaint = verify(() => canvas.drawPath(any(), captureAny()))
          .captured
          .single as Paint;
      expect(capturedPaint.color, Colors.transparent);
      expect(capturedPaint.blendMode, BlendMode.clear);
    });

    test('shouldRepaint always returns true', () {
      expect(painter.shouldRepaint(painter), true);
    });

    test('uses correct save and restore layer', () {
      painter.paint(canvas, size);
      verifyInOrder([
        () => canvas.saveLayer(any(), any()),
        () => canvas.restore(),
      ]);
    });
  });
}
