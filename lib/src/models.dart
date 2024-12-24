import 'package:flutter/material.dart';

class WhiteBoardStroke {
  final Path path = Path();
  final Color color;
  final double width;
  final bool erase;

  WhiteBoardStroke({
    this.color = Colors.black,
    this.width = 4,
    this.erase = false,
  });
}

class RedoUndoHistory {
  final VoidCallback undo;
  final VoidCallback redo;

  RedoUndoHistory({
    required this.undo,
    required this.redo,
  });
}
