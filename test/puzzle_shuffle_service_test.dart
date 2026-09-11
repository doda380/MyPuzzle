import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_puzzle/models/selected_image.dart';
import 'package:photo_puzzle/services/puzzle_shuffle_service.dart';
import 'package:photo_puzzle/services/puzzle_tile_service.dart';

void main() {
  const image = SelectedImage(path: '/tmp/photo.jpg', name: 'photo.jpg');
  const shuffleService = PuzzleShuffleService();
  const tileService = PuzzleTileService();

  test('shuffle produces a valid permutation of positions', () {
    final puzzle = tileService.buildPuzzle(image);
    final shuffled = shuffleService.shuffle(puzzle, random: Random(1));

    final currentIndices = shuffled.tiles.map((t) => t.currentIndex).toList()
      ..sort();
    expect(currentIndices, List<int>.generate(puzzle.tileCount, (i) => i));
  });

  test('shuffle never returns the solved order', () {
    final puzzle = tileService.buildPuzzle(image);

    for (var seed = 0; seed < 20; seed++) {
      final shuffled = shuffleService.shuffle(puzzle, random: Random(seed));
      expect(shuffled.isSolved, isFalse);
    }
  });

  test('shuffle preserves which image fragment each tile represents', () {
    final puzzle = tileService.buildPuzzle(image);
    final shuffled = shuffleService.shuffle(puzzle, random: Random(2));

    for (final tile in puzzle.tiles) {
      final shuffledTile = shuffled.tiles.firstWhere(
        (t) => t.correctIndex == tile.correctIndex,
      );
      expect(shuffledTile.row, tile.row);
      expect(shuffledTile.column, tile.column);
    }
  });

  test('does not attempt to shuffle a single-tile puzzle', () {
    final puzzle = tileService.buildPuzzle(image, gridSize: 1);
    final shuffled = shuffleService.shuffle(puzzle, random: Random(3));

    expect(shuffled.tiles.single.currentIndex, 0);
  });
}
