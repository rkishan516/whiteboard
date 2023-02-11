# whiteboard

A package for freehand use on whiteboard.

## Feature

* Save whiteboard as Image
* Undo
* Redo
* Eraser mode
* Pencil width and color change
* Whiteboard background color change

# Usage

## Whiteboard

```dart
WhiteBoard(
    // background Color of white board
    backgroundColor: Colors.white,
    // Controller for action on whiteboard
    controller: WhiteBoardController(),
    // Stroke width of freehand
    strokeWidth: 5,
    // Stroke color of freehand
    strokeColor: Colors.green,
    // For Eraser mode
    isErasing: false,
    // Save image
    onConvertImage: (list){},
    // Callback common for redo or undo
    onRedoUndo: (t,m){},
)
```

## WhiteBoardController
```dart
// Create a controller
WhiteBoardController whiteBoardController =WhiteBoardController();
// Clear all the strokes
whiteBoardController.clear();
// Convert Whiteboard into file
whiteBoardController.convertToImage();
// Redo last stroke
whiteBoardController.redo();
// Undo last stroke
whiteBoardController.undo();
```
