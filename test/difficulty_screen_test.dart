import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_puzzle/models/selected_image.dart';
import 'package:photo_puzzle/screens/difficulty_screen.dart';
import 'package:photo_puzzle/screens/puzzle_grid_screen.dart';
import 'package:photo_puzzle/widgets/puzzle_tile_view.dart';

void main() {
  const image = SelectedImage(
    path: '/tmp/does-not-exist.jpg',
    name: 'photo.jpg',
  );

  testWidgets('shows Easy, Medium and Hard difficulty options', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DifficultyScreen(
          selectedImage: image,
          hintsRemaining: 2,
          onHintsChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('3 x 3 · 9 pieces'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('4 x 4 · 16 pieces'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('5 x 5 · 25 pieces'), findsOneWidget);
  });

  testWidgets(
    'choosing Medium opens the puzzle screen, ready to start a 4x4 grid',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DifficultyScreen(
            selectedImage: image,
            hintsRemaining: 2,
            onHintsChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      expect(find.byType(PuzzleGridScreen), findsOneWidget);
      // Tiles aren't shuffled into view until the player taps Start.
      expect(find.byType(PuzzleTileView), findsNothing);
      expect(find.text('Start Puzzle'), findsOneWidget);

      await tester.tap(find.text('Start Puzzle'));
      await tester.pump();

      expect(find.byType(PuzzleTileView), findsNWidgets(16));
    },
  );

  testWidgets('carries the current hint count through untouched', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DifficultyScreen(
          selectedImage: image,
          hintsRemaining: 1,
          onHintsChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Puzzle'));
    await tester.pump();

    // Choosing a difficulty must not reset the session's hint count.
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('back button returns without picking a difficulty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DifficultyScreen(
                      selectedImage: image,
                      hintsRemaining: 2,
                      onHintsChanged: (_) {},
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(DifficultyScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(DifficultyScreen), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
