import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_puzzle/models/puzzle.dart';
import 'package:photo_puzzle/models/selected_image.dart';
import 'package:photo_puzzle/screens/puzzle_grid_screen.dart';
import 'package:photo_puzzle/services/puzzle_shuffle_service.dart';
import 'package:photo_puzzle/services/puzzle_tile_service.dart';
import 'package:photo_puzzle/widgets/puzzle_completion_animation.dart';
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

/// Captures the most recent value reported through `onHintsChanged`.
class _HintsSpy {
  _HintsSpy(this.value);
  int value;
  void call(int newValue) => value = newValue;
}

/// Drags the [PuzzleTileView] at grid position [fromIndex] onto the one at
/// [toIndex], the same gesture a player performs to swap two pieces.
Future<void> _dragTile(WidgetTester tester, int fromIndex, int toIndex) async {
  final from = tester.getCenter(find.byType(PuzzleTileView).at(fromIndex));
  final to = tester.getCenter(find.byType(PuzzleTileView).at(toIndex));

  final gesture = await tester.startGesture(from);
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveTo(to);
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.up();
  await tester.pump();
}

/// Drags a solving move, then pumps through the completion celebration
/// (~1.4s) so the win dialog has had a chance to appear.
Future<void> _dragTileAndSettle(
  WidgetTester tester,
  int fromIndex,
  int toIndex,
) async {
  await _dragTile(tester, fromIndex, toIndex);
  await tester.pumpAndSettle();
}

/// Pumps a [PuzzleGridScreen] starting with [hintsRemaining] hints and taps
/// past the pre-start "view the full image" step, returning a spy that
/// tracks every value reported through `onHintsChanged`.
Future<_HintsSpy> _pumpAndStart(
  WidgetTester tester, {
  required Puzzle puzzle,
  required int hintsRemaining,
  PuzzleShuffleService shuffleService = const PuzzleShuffleService(),
}) async {
  final spy = _HintsSpy(hintsRemaining);
  await tester.pumpWidget(
    MaterialApp(
      home: PuzzleGridScreen(
        puzzle: puzzle,
        hintsRemaining: hintsRemaining,
        onHintsChanged: spy.call,
        shuffleService: shuffleService,
      ),
    ),
  );
  await tester.pump();
  await tester.tap(find.text('Start Puzzle'));
  await tester.pump();
  return spy;
}

void main() {
  const image = SelectedImage(
    path: '/tmp/does-not-exist.jpg',
    name: 'photo.jpg',
  );
  final puzzle = const PuzzleTileService().buildPuzzle(image);

  testWidgets(
    'shows the full image and a Start Puzzle button before shuffling',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGridScreen(
            puzzle: puzzle,
            hintsRemaining: 2,
            onHintsChanged: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Start Puzzle'), findsOneWidget);
      expect(find.byType(PuzzleTileView), findsNothing);
      expect(find.text('photo.jpg'), findsOneWidget);
    },
  );

  testWidgets('Start Puzzle reveals one tile view per puzzle tile', (
    tester,
  ) async {
    await _pumpAndStart(
      tester,
      puzzle: puzzle,
      hintsRemaining: 2,
      shuffleService: const _IdentityShuffleService(),
    );

    expect(find.text('Start Puzzle'), findsNothing);
    expect(find.byType(PuzzleTileView), findsNWidgets(puzzle.tileCount));

    final tileViews = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();
    for (var i = 0; i < tileViews.length; i++) {
      expect(tileViews[i].row, i ~/ puzzle.gridSize);
      expect(tileViews[i].column, i % puzzle.gridSize);
    }
  });

  testWidgets('uses the real shuffle service by default', (tester) async {
    await _pumpAndStart(tester, puzzle: puzzle, hintsRemaining: 2);

    final tileViews = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();

    final isSolvedOrder = List.generate(
      tileViews.length,
      (i) =>
          tileViews[i].row == i ~/ puzzle.gridSize &&
          tileViews[i].column == i % puzzle.gridSize,
    ).every((matches) => matches);

    expect(isSolvedOrder, isFalse);
  });

  testWidgets('dragging one tile onto another swaps their displayed positions', (
    tester,
  ) async {
    await _pumpAndStart(
      tester,
      puzzle: puzzle,
      hintsRemaining: 2,
      shuffleService: const _IdentityShuffleService(),
    );

    final before = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();
    final firstBefore = (row: before[0].row, column: before[0].column);
    final secondBefore = (row: before[1].row, column: before[1].column);

    await _dragTile(tester, 0, 1);

    final after = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();

    expect(after[0].row, secondBefore.row);
    expect(after[0].column, secondBefore.column);
    expect(after[1].row, firstBefore.row);
    expect(after[1].column, firstBefore.column);
  });

  testWidgets('dragging a tile onto itself does not change anything', (
    tester,
  ) async {
    await _pumpAndStart(
      tester,
      puzzle: puzzle,
      hintsRemaining: 2,
      shuffleService: const _IdentityShuffleService(),
    );

    final before = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();

    await _dragTile(tester, 0, 0);

    final after = tester
        .widgetList<PuzzleTileView>(find.byType(PuzzleTileView))
        .toList();

    for (var i = 0; i < before.length; i++) {
      expect(after[i].row, before[i].row);
      expect(after[i].column, before[i].column);
    }
  });

  testWidgets('tapping the hint button shows the full original image', (
    tester,
  ) async {
    await _pumpAndStart(
      tester,
      puzzle: puzzle,
      hintsRemaining: 2,
      shuffleService: const _IdentityShuffleService(),
    );

    await tester.tap(find.byTooltip('Hint (2 left)'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Close preview'), findsOneWidget);
    // The board's tiles stay mounted behind the dialog, plus one full
    // uncropped Image in the preview overlay itself.
    expect(find.byType(Image), findsWidgets);

    await tester.tap(find.byTooltip('Close preview'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Close preview'), findsNothing);
  });

  group('hint counter (session-persistent, reward-based)', () {
    testWidgets('starts from whatever count is passed in, not a hardcoded 2', (
      tester,
    ) async {
      await _pumpAndStart(
        tester,
        puzzle: puzzle,
        hintsRemaining: 1,
        shuffleService: const _IdentityShuffleService(),
      );

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('does not reset hints when Start Puzzle is tapped', (
      tester,
    ) async {
      final spy = await _pumpAndStart(
        tester,
        puzzle: puzzle,
        hintsRemaining: 0,
        shuffleService: const _IdentityShuffleService(),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.byTooltip('No hints left'), findsOneWidget);
      expect(spy.value, 0);
    });

    testWidgets('decrements by exactly 1 per use, then disables at 0', (
      tester,
    ) async {
      final spy = await _pumpAndStart(
        tester,
        puzzle: puzzle,
        hintsRemaining: 2,
        shuffleService: const _IdentityShuffleService(),
      );

      await tester.tap(find.byTooltip('Hint (2 left)'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(spy.value, 1);

      await tester.tap(find.byTooltip('Close preview'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Hint (1 left)'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      expect(spy.value, 0);

      await tester.tap(find.byTooltip('Close preview'));
      await tester.pumpAndSettle();

      // No hints left: the button is disabled and the action must not run.
      expect(find.byTooltip('No hints left'), findsOneWidget);
      await tester.tap(find.byTooltip('No hints left'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Close preview'), findsNothing);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('rewards exactly +1 hint when the puzzle is solved', (
      tester,
    ) async {
      final spy = await _pumpAndStart(
        tester,
        puzzle: puzzle,
        hintsRemaining: 0,
        shuffleService: const _SwapFirstTwoShuffleService(),
      );

      expect(find.text('0'), findsOneWidget);

      await _dragTileAndSettle(tester, 0, 1);

      expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);
      expect(spy.value, 1);
    });

    testWidgets('rewards +1 with no upper limit, even already at the starting count', (
      tester,
    ) async {
      final spy = await _pumpAndStart(
        tester,
        puzzle: puzzle,
        hintsRemaining: 2,
        shuffleService: const _SwapFirstTwoShuffleService(),
      );

      await _dragTileAndSettle(tester, 0, 1);

      expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);
      expect(spy.value, 3);
    });

    testWidgets('keeps rewarding +1 past the old cap on repeated wins', (
      tester,
    ) async {
      final spy = await _pumpAndStart(
        tester,
        puzzle: puzzle,
        hintsRemaining: 3,
        shuffleService: const _SwapFirstTwoShuffleService(),
      );

      await _dragTileAndSettle(tester, 0, 1);
      expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);
      expect(spy.value, 4);

      await tester.tap(find.text('Play Again'));
      await tester.pumpAndSettle();

      await _dragTileAndSettle(tester, 0, 1);
      expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);
      expect(spy.value, 5);
    });

    testWidgets('hints keep accumulating across Play Again rounds, not reset', (
      tester,
    ) async {
      final spy = await _pumpAndStart(
        tester,
        puzzle: puzzle,
        hintsRemaining: 0,
        shuffleService: const _SwapFirstTwoShuffleService(),
      );

      await _dragTileAndSettle(tester, 0, 1);
      expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);
      expect(spy.value, 1);

      await tester.tap(find.text('Play Again'));
      await tester.pump();

      // Reshuffling for another round must not reset the reward earned.
      expect(find.text('1'), findsOneWidget);

      await _dragTileAndSettle(tester, 0, 1);
      expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);
      expect(spy.value, 2);
    });
  });

  group('completion celebration', () {
    testWidgets(
      'keeps the grid visible and the win dialog hidden right after solving',
      (tester) async {
        await _pumpAndStart(
          tester,
          puzzle: puzzle,
          hintsRemaining: 2,
          shuffleService: const _SwapFirstTwoShuffleService(),
        );

        await _dragTile(tester, 0, 1);
        // Only the swap itself has been pumped; the celebration has barely
        // started, so the board's tiles are still what's on screen.
        await tester.pump();

        expect(find.byType(PuzzleCompletionAnimation), findsOneWidget);
        expect(find.byType(PuzzleTileView), findsNWidgets(puzzle.tileCount));
        expect(find.text('🎉 Puzzle Solved!'), findsNothing);
      },
    );

    testWidgets(
      'shows the achievement badge partway through, before the win dialog',
      (tester) async {
        await _pumpAndStart(
          tester,
          puzzle: puzzle,
          hintsRemaining: 2,
          shuffleService: const _SwapFirstTwoShuffleService(),
        );

        await _dragTile(tester, 0, 1);
        // Land inside the 0.68-1.0 fully-settled badge phase of the 2600ms
        // sequence, well before the win dialog appears at t=2600ms.
        await tester.pump(const Duration(milliseconds: 2000));

        expect(find.text('Puzzle Completed!'), findsOneWidget);
        expect(find.text('+1 Hint'), findsOneWidget);
        expect(find.text('🎉 Puzzle Solved!'), findsNothing);
      },
    );

    testWidgets(
      'the celebration plays exactly once, then the win dialog appears',
      (tester) async {
        await _pumpAndStart(
          tester,
          puzzle: puzzle,
          hintsRemaining: 2,
          shuffleService: const _SwapFirstTwoShuffleService(),
        );

        await _dragTileAndSettle(tester, 0, 1);

        expect(find.byType(PuzzleCompletionAnimation), findsNothing);
        expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);
      },
    );
  });

  testWidgets('solving the puzzle shows the win dialog', (tester) async {
    await _pumpAndStart(
      tester,
      puzzle: puzzle,
      hintsRemaining: 2,
      shuffleService: const _SwapFirstTwoShuffleService(),
    );

    expect(find.text('🎉 Puzzle Solved!'), findsNothing);

    await _dragTileAndSettle(tester, 0, 1);

    expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);
    expect(find.text('Play Again'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('Play Again dismisses the dialog and reshuffles', (
    tester,
  ) async {
    await _pumpAndStart(
      tester,
      puzzle: puzzle,
      hintsRemaining: 2,
      shuffleService: const _SwapFirstTwoShuffleService(),
    );

    await _dragTileAndSettle(tester, 0, 1);

    expect(find.text('🎉 Puzzle Solved!'), findsOneWidget);

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();

    expect(find.text('🎉 Puzzle Solved!'), findsNothing);
  });
}
