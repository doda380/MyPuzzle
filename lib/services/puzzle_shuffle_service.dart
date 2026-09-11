import 'dart:math';

import '../models/puzzle.dart';

class PuzzleShuffleService {
  const PuzzleShuffleService();

  /// Returns a copy of [puzzle] with tile positions randomly shuffled.
  ///
  /// Each tile keeps the image fragment it represents (`correctIndex`,
  /// `row`, `column`); only `currentIndex` changes. The result is
  /// guaranteed to differ from the solved arrangement whenever the puzzle
  /// has more than one tile.
  Puzzle shuffle(Puzzle puzzle, {Random? random}) {
    final tiles = puzzle.tiles;
    if (tiles.length <= 1) {
      return puzzle;
    }

    final rng = random ?? Random();

    List<int> positions;
    do {
      positions = List<int>.generate(tiles.length, (i) => i)..shuffle(rng);
    } while (_isIdentity(positions));

    final shuffledTiles = [
      for (var i = 0; i < tiles.length; i++)
        tiles[i].copyWith(currentIndex: positions[i]),
    ];

    return puzzle.copyWith(tiles: shuffledTiles);
  }

  bool _isIdentity(List<int> positions) {
    for (var i = 0; i < positions.length; i++) {
      if (positions[i] != i) {
        return false;
      }
    }
    return true;
  }
}
