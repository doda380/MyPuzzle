import 'puzzle_tile.dart';
import 'selected_image.dart';

class Puzzle {
  const Puzzle({
    required this.sourceImage,
    required this.gridSize,
    required this.tiles,
  });

  final SelectedImage sourceImage;
  final int gridSize;
  final List<PuzzleTile> tiles;

  int get tileCount => tiles.length;

  bool get isSolved => tiles.every((tile) => tile.isInCorrectPosition);

  Puzzle copyWith({List<PuzzleTile>? tiles}) {
    return Puzzle(
      sourceImage: sourceImage,
      gridSize: gridSize,
      tiles: tiles ?? this.tiles,
    );
  }
}
