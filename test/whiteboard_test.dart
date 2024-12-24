import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:whiteboard/src/freehand_painter.dart';
import 'package:whiteboard/src/whiteboard.dart';

import 'whiteboard_controller_test.dart';

void main() {
  group('WhiteBoard', () {
    setUp(() {
      registerFallbackValue(ImageByteFormat.rawRgba);
    });
    testWidgets('renders with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const WhiteBoard(),
        ),
      );

      expect(find.byType(GestureDetector), findsOne);
      expect(find.byType(CustomPaint), findsOne);
    });

    testWidgets('renders with custom values', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WhiteBoard(
            backgroundColor: Colors.red,
            strokeColor: Colors.green,
            strokeWidth: 10,
            isErasing: true,
          ),
        ),
      );

      // Verify indirectly by triggering drawing and checking if the painter uses the correct values
      await tester.drag(find.byType(GestureDetector), const Offset(10, 10));
      await tester.pumpAndSettle(); // Wait for rendering to finish

      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      final painter = customPaint.painter as FreehandPainter;

      // It's hard to directly test the backgroundColor without rendering to an image,
      // So we test if the stroke settings have been applied.
      expect(painter.strokes.isNotEmpty, true);
      expect(painter.strokes.first.color, Colors.green);
      expect(painter.strokes.first.width, 10);
      expect(painter.strokes.first.erase, true);
    });

    testWidgets('draws a stroke', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const WhiteBoard(),
        ),
      );

      await tester.drag(find.byType(GestureDetector), const Offset(100, 100));
      await tester.pumpAndSettle();

      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      final painter = customPaint.painter as FreehandPainter;
      expect(painter.strokes.isNotEmpty, isTrue);
      expect(painter.strokes.first.path.getBounds().width, greaterThan(0.0));
      expect(painter.strokes.first.path.getBounds().height, greaterThan(0.0));
    });

    testWidgets('calls onConvertImage', (WidgetTester tester) async {
      final delegate = MockWhiteBoardControllerDelegate();
      final controller = WhiteBoardController.withDelegate(delegate);
      when(() => delegate.saveAsImage(ImageByteFormat.png))
          .thenAnswer((i) async {
        return Uint8List.fromList([]);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: WhiteBoard(
            controller: controller,
          ),
        ),
      );

      final capturedImage =
          controller.convertToImage(format: ImageByteFormat.png);

      await expectLater(capturedImage, isNotNull);
    });

    testWidgets('WhiteBoardController undo/redo/clear', (tester) async {
      bool isUndoAvailable = false;
      bool isRedoAvailable = false;

      final controller = WhiteBoardController();
      final whiteboard = WhiteBoard(
        controller: controller,
        onRedoUndo: (undo, redo) {
          isUndoAvailable = undo;
          isRedoAvailable = redo;
        },
      );

      // Initialize the widget in a test environment.
      await tester.pumpWidget(MaterialApp(home: whiteboard));

      // Simulate drawing a stroke
      await tester.drag(find.byType(GestureDetector), const Offset(100, 100));
      await tester.pumpAndSettle();
      expect(isUndoAvailable, true);
      expect(isRedoAvailable, false);

      // Undo
      controller.undo();
      expect(isUndoAvailable, false);
      expect(isRedoAvailable, true);

      // Redo
      controller.redo();
      expect(isUndoAvailable, true);
      expect(isRedoAvailable, false);

      // Simulate drawing another stroke
      await tester.drag(find.byType(GestureDetector), const Offset(100, 100));
      await tester.pumpAndSettle();

      // Clear
      controller.clear();
      expect(isUndoAvailable, true);
      expect(isRedoAvailable, false);
    });
  });
}
