import '../models/puzzle.dart';
import '../models/puzzle_tile.dart';
import '../models/selected_image.dart';

class PuzzleTileService {
  const PuzzleTileService();

  static const defaultGridSize = 3;

  /// Splits [sourceImage] into an evenly divided, solved-order set of tiles.
  Puzzle buildPuzzle(
    SelectedImage sourceImage, {
    int gridSize = defaultGridSize,
  }) {
    final tiles = List<PuzzleTile>.generate(gridSize * gridSize, (index) {
      final row = index ~/ gridSize;
      final column = index % gridSize;

      return PuzzleTile(
        correctIndex: index,
        currentIndex: index,
        row: row,
        column: column,
      );
    });

    return Puzzle(
      sourceImage: sourceImage,
      gridSize: gridSize,
      tiles: tiles,
    );
  }
}
