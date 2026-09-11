import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_puzzle/models/puzzle.dart';
import 'package:photo_puzzle/models/selected_image.dart';
import 'package:photo_puzzle/screens/puzzle_grid_screen.dart';
import 'package:photo_puzzle/services/puzzle_shuffle_service.dart';
import 'package:photo_puzzle/services/puzzle_tile_service.dart';
import 'package:photo_puzzle/widgets/puzzle_tile_view.dart';

class _IdentityShuffleService extends PuzzleShuffleService {
  const _IdentityShuffleService();

  @override
  Puzzle shuffle(Puzzle puzzle, {Random? random}) => puzzle;
}

class _SwapFirstTwoShuffleService extends PuzzleShuffleService {
  const _SwapFirstTwoShuffleService();

  @override
  Puzzle shuffle(Puzzle puzzle, {Random? random}) {
    final tiles = [
      for (final tile in puzzle.tiles)
        if (tile.correctIndex == 0)
          tile.copyWith(currentIndex: 1)
        else if (tile.correctIndex == 1)
          tile.copyWith(currentIndex: 0)
        else
          tile,
    ];
    return puzzle.copyWith(tiles: tiles);
  }
}

void main() {
  const image = SelectedImage(
    path: '/tmp/does-not-exist.jpg',
    name: 'photo.jpg',
  );
  final puzzle = const PuzzleTileService().buildPuzzle(image);

  testWidgets('renders one tile view per puzzle tile, unshuffled here', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleGridScreen(
          puzzle: puzzle,
          shuffleService: const _IdentityShuffleService(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PuzzleTileView), findsNWidgets(puzzle.tileCount));
    expect(find.text('photo.jpg'), findsOneWidget);

    final tileViews = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();
    for (var i = 0; i < tileViews.length; i++) {
      expect(tileViews[i].row, i ~/ puzzle.gridSize);
      expect(tileViews[i].column, i % puzzle.gridSize);
    }
  });

  testWidgets('uses the real shuffle service by default', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PuzzleGridScreen(puzzle: puzzle)));
    await tester.pump();

    final tileViews = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();

    final isSolvedOrder = List.generate(
      tileViews.length,
      (i) => tileViews[i].row == i ~/ puzzle.gridSize &&
          tileViews[i].column == i % puzzle.gridSize,
    ).every((matches) => matches);

    expect(isSolvedOrder, isFalse);
  });

  testWidgets('tapping two tiles swaps their displayed positions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleGridScreen(
          puzzle: puzzle,
          shuffleService: const _IdentityShuffleService(),
        ),
      ),
    );
    await tester.pump();

    final before = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();
    final firstBefore = (row: before[0].row, column: before[0].column);
    final secondBefore = (row: before[1].row, column: before[1].column);

    await tester.tap(find.byType(PuzzleTileView).at(0));
    await tester.pump();
    await tester.tap(find.byType(PuzzleTileView).at(1));
    await tester.pump();

    final after = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();

    expect(after[0].row, secondBefore.row);
    expect(after[0].column, secondBefore.column);
    expect(after[1].row, firstBefore.row);
    expect(after[1].column, firstBefore.column);
  });

  testWidgets('tapping the same tile twice deselects it instead of swapping', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleGridScreen(
          puzzle: puzzle,
          shuffleService: const _IdentityShuffleService(),
        ),
      ),
    );
    await tester.pump();

    final before = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();

    await tester.tap(find.byType(PuzzleTileView).at(0));
    await tester.pump();
    await tester.tap(find.byType(PuzzleTileView).at(0));
    await tester.pump();

    final after = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();

    for (var i = 0; i < before.length; i++) {
      expect(after[i].row, before[i].row);
      expect(after[i].column, before[i].column);
    }
  });

  testWidgets('solving the puzzle shows the win dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleGridScreen(
          puzzle: puzzle,
          shuffleService: const _SwapFirstTwoShuffleService(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Puzzle Solved!'), findsNothing);

    await tester.tap(find.byType(PuzzleTileView).at(0));
    await tester.pump();
    await tester.tap(find.byType(PuzzleTileView).at(1));
    await tester.pump();

    expect(find.text('Puzzle Solved!'), findsOneWidget);
    expect(find.text('Play Again'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });

  testWidgets('Play Again dismisses the dialog and reshuffles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleGridScreen(
          puzzle: puzzle,
          shuffleService: const _SwapFirstTwoShuffleService(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(PuzzleTileView).at(0));
    await tester.pump();
    await tester.tap(find.byType(PuzzleTileView).at(1));
    await tester.pump();

    expect(find.text('Puzzle Solved!'), findsOneWidget);

    await tester.tap(find.text('Play Again'));
    await tester.pump();

    expect(find.text('Puzzle Solved!'), findsNothing);
  });
}
