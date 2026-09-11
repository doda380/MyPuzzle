import 'package:flutter_test/flutter_test.dart';
import 'package:photo_puzzle/models/selected_image.dart';
import 'package:photo_puzzle/services/puzzle_tile_service.dart';

void main() {
  group('PuzzleTileService', () {
    const service = PuzzleTileService();
    const image = SelectedImage(path: '/tmp/photo.jpg', name: 'photo.jpg');

    test('a 3x3 puzzle produces exactly 9 tiles', () {
      final puzzle = service.buildPuzzle(image);

      expect(puzzle.gridSize, 3);
      expect(puzzle.tileCount, 9);
      expect(puzzle.tiles.length, 9);
    });

    test('tiles are prepared in solved order with matching positions', () {
      final puzzle = service.buildPuzzle(image);

      for (var i = 0; i < puzzle.tiles.length; i++) {
        final tile = puzzle.tiles[i];

        expect(tile.correctIndex, i);
        expect(tile.currentIndex, i);
        expect(tile.isInCorrectPosition, isTrue);
        expect(tile.row, i ~/ 3);
        expect(tile.column, i % 3);
      }
    });

    test('keeps a reference to the source image', () {
      final puzzle = service.buildPuzzle(image);

      expect(puzzle.sourceImage, same(image));
    });
  });
}
