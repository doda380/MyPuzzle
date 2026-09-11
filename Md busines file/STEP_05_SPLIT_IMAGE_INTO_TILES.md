# Step 5: Split the Image Into Puzzle Tiles

## Purpose

This phase defines how the selected photo becomes the foundation of the puzzle.

After the player chooses an image, the app should prepare that image as a set of equal puzzle pieces. These pieces are not shown as a playable grid yet. This step only prepares the puzzle content for the next phase.

## Player Experience

The player has already selected a photo from the gallery.

The app should then prepare the image so it can later become a puzzle. The player should feel that the image has been accepted and is ready for the next stage.

For now, the app can show a simple confirmation message, such as:

```text
Image prepared as 9 tiles.
```

The selected image preview should remain visible.

## Business Logic

The selected image must be divided into a fixed number of equal pieces.

For this phase, use a temporary default difficulty:

```text
3x3
```

That means the image should be prepared as:

```text
9 total puzzle tiles
```

Each tile must represent one part of the original image.

The tiles should be created in the correct solved order.

For example, in a `3x3` puzzle:

```text
Tile 1: top-left
Tile 2: top-center
Tile 3: top-right
Tile 4: middle-left
Tile 5: center
Tile 6: middle-right
Tile 7: bottom-left
Tile 8: bottom-center
Tile 9: bottom-right
```

At the end of this step, every tile should know:

- Which part of the original image it represents.
- Where it belongs in the solved puzzle.
- Where it currently is.

For this phase, each tile starts in its correct position.

## Rules

- The full selected image must be used.
- The image must be divided evenly.
- The tile count must match the selected grid size.
- For `3x3`, the result must be `9` tiles.
- Tiles must be prepared in solved order.
- No tile should be shuffled yet.
- No tile should be swapped yet.
- No puzzle-solving check should happen yet.

## Success Criteria

This phase is complete when:

- The app can take a selected image and prepare it as puzzle tile data.
- A `3x3` image produces exactly `9` tiles.
- Each tile has a clear original position.
- Each tile has a clear current position.
- All tiles start in the correct order.
- The selected image preview still works.
- The app confirms that the image was prepared successfully.

## What Should Not Be Included

Do not implement:

- Puzzle grid display.
- Puzzle piece UI.
- Tile shuffling.
- Tile swapping.
- Difficulty selection.
- Solved puzzle checking.
- Win dialog.
- Move counter.
- Timer.
- Camera support.

Those belong to later phases.

## Expected Result

After this phase, the app should be ready for the next step:

```text
Step 6: Display puzzle pieces in a grid.
```

The important outcome is that the app now understands the selected image as a complete set of puzzle pieces, even though the player cannot interact with those pieces yet.
