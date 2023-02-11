part of whiteboard;

/// Whiteboard controller for Undo, Redo, clear and saveAsImage
class WhiteBoardController {
  late _WhiteBoardControllerDelegate _delegate;

  /// Convert [Whiteboard] into image data with given format.
  /// You can obtain converted image data via [onConvert] property of [Crop].
  void convertToImage({ImageByteFormat format = ImageByteFormat.png}) =>
      _delegate.saveAsImage(format);

  /// Undo last stroke
  /// Return [false] if there is no stroke to undo, otherwise return [true].
  bool undo() => _delegate.onUndo();

  /// Redo last undo stroke
  /// Return [false] if there is no stroke to redo, otherwise return [true].
  bool redo() => _delegate.onRedo();

  /// Clear all the strokes
  void clear() => _delegate.onClear();
}

class _WhiteBoardControllerDelegate {
  late Future<void> Function(ImageByteFormat format) saveAsImage;

  late bool Function() onUndo;

  late bool Function() onRedo;

  late VoidCallback onClear;
}
