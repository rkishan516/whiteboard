import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:whiteboard/src/freehand_painter.dart';
import 'package:whiteboard/src/models.dart';

part 'whiteboard_controller.dart';

typedef OnRedoUndo = void Function(bool isUndoAvailable, bool isRedoAvailable);

/// Whiteboard widget for canvas
class WhiteBoard extends StatefulWidget {
  /// WhiteBoardController for actions.
  final WhiteBoardController? controller;

  /// [Color] for background of whiteboard.
  final Color backgroundColor;

  /// [Color] of strokes.
  final Color strokeColor;

  /// Width of strokes
  final double strokeWidth;

  /// Flag for erase mode
  final bool isErasing;

  /// Callback for [Canvas] when it converted to image data.
  /// Use [WhiteBoardController] to convert.

  /// This callback exposes if undo / redo is available and called successfully.
  final OnRedoUndo? onRedoUndo;

  const WhiteBoard({
    Key? key,
    this.controller,
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.blue,
    this.strokeWidth = 4,
    this.isErasing = false,
    this.onRedoUndo,
  }) : super(key: key);

  @override
  _WhiteBoardState createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard> {
  final _undoHistory = <RedoUndoHistory>[];
  final _redoStack = <RedoUndoHistory>[];

  final _strokes = <WhiteBoardStroke>[];

  // cached current canvas size
  late Size _canvasSize;

  // convert current canvas to image data.
  Future<Uint8List> _convertToImage(ImageByteFormat format) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Emulate painting using _FreehandPainter
    // recorder will record this painting
    FreehandPainter(
      _strokes,
      widget.backgroundColor,
    ).paint(canvas, _canvasSize);

    // Stop emulating and convert to Image
    final result = await recorder
        .endRecording()
        .toImage(_canvasSize.width.floor(), _canvasSize.height.floor());

    // Cast image data to byte array with converting to given format
    final converted =
        (await result.toByteData(format: format))!.buffer.asUint8List();

    return converted;
  }

  void onClear() {
    if (_strokes.isEmpty) return;
    setState(() {
      final _removedStrokes = <WhiteBoardStroke>[]..addAll(_strokes);
      final _redoUndoHistoryItem = RedoUndoHistory(
        undo: () => setState(() => _strokes.addAll(_removedStrokes)),
        redo: () => setState(() => _strokes.clear()),
      );
      _undoHistory.add(_redoUndoHistoryItem);
      _strokes.clear();
      _redoStack.clear();
    });
    widget.onRedoUndo?.call(_undoHistory.isNotEmpty, _redoStack.isNotEmpty);
  }

  bool onRedo() {
    if (_redoStack.isEmpty) return false;

    _undoHistory.add(_redoStack.removeLast()..redo());
    widget.onRedoUndo?.call(_undoHistory.isNotEmpty, _redoStack.isNotEmpty);
    return true;
  }

  bool onUndo() {
    if (_undoHistory.isEmpty) return false;

    _redoStack.add(_undoHistory.removeLast()..undo());
    widget.onRedoUndo?.call(_undoHistory.isNotEmpty, _redoStack.isNotEmpty);
    return true;
  }

  @override
  void initState() {
    widget.controller?._delegate = WhiteBoardControllerDelegate(
      saveAsImage: _convertToImage,
      onClear: onClear,
      onUndo: onUndo,
      onRedo: onRedo,
    );
    super.initState();
  }

  void _start(double startX, double startY) {
    final newStroke = WhiteBoardStroke(
      color: widget.strokeColor,
      width: widget.strokeWidth,
      erase: widget.isErasing,
    );
    newStroke.path.moveTo(startX, startY);

    _strokes.add(newStroke);
    _undoHistory.add(
      RedoUndoHistory(
        undo: () => setState(() => _strokes.remove(newStroke)),
        redo: () => setState(() => _strokes.add(newStroke)),
      ),
    );
    _redoStack.clear();
    widget.onRedoUndo?.call(_undoHistory.isNotEmpty, _redoStack.isNotEmpty);
  }

  void _add(double x, double y) {
    setState(() {
      _strokes.last.path.lineTo(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height,
      width: size.width,
      child: GestureDetector(
        onPanStart: (details) => _start(
          details.localPosition.dx,
          details.localPosition.dy,
        ),
        onPanUpdate: (details) => _add(
          details.localPosition.dx,
          details.localPosition.dy,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
            return CustomPaint(
              painter: FreehandPainter(_strokes, widget.backgroundColor),
            );
          },
        ),
      ),
    );
  }
}
