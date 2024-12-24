import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:whiteboard/src/whiteboard.dart';

class MockWhiteBoardControllerDelegate extends Mock
    implements WhiteBoardControllerDelegate {}

void main() {
  late WhiteBoardController controller;
  late MockWhiteBoardControllerDelegate delegate;

  setUp(() {
    registerFallbackValue(ImageByteFormat.rawRgba);
    delegate = MockWhiteBoardControllerDelegate();
    controller = WhiteBoardController.withDelegate(delegate);
  });

  group('WhiteBoardController', () {
    test('undo calls delegate.onUndo and returns the result', () {
      when(() => delegate.onUndo).thenReturn(() => true);

      final result = controller.undo();

      expect(result, true);
      verify(() => delegate.onUndo()).called(1);

      when(() => delegate.onUndo).thenReturn(() => false);

      final result2 = controller.undo();

      expect(result2, false);
      verify(() => delegate.onUndo()).called(1); // Second call
    });

    test('redo calls delegate.onRedo and returns the result', () {
      when(() => delegate.onRedo).thenReturn(() => false);

      final result = controller.redo();

      expect(result, false);
      verify(() => delegate.onRedo()).called(1);

      when(() => delegate.onRedo).thenReturn(() => true);

      final result2 = controller.redo();

      expect(result2, true);
      verify(() => delegate.onRedo()).called(1); // Second call
    });

    test('clear calls delegate.onClear', () {
      when(() => delegate.onClear)
          .thenReturn(() {}); // VoidCallback returns null

      controller.clear();

      verify(() => delegate.onClear()).called(1);
    });
  });
}
