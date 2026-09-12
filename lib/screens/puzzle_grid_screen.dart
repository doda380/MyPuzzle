import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/puzzle.dart';
import '../models/puzzle_tile.dart';
import '../services/puzzle_shuffle_service.dart';
import '../widgets/puzzle_completion_animation.dart';
import '../widgets/puzzle_tile_view.dart';
import '../widgets/puzzle_win_dialog.dart';

/// Shows the original selected image full-screen first, so the player can
/// clearly see the whole photo before starting. Once they tap "Start
/// Puzzle", the image is divided into shuffled, draggable tiles. Drag a
/// tile onto another to swap the two; a hint button reveals the original
/// image as a reference while solving. Hints persist across puzzles for the
/// session (never reset on a new puzzle): a new install starts with
/// [startingHints], using one always costs exactly 1, and solving a puzzle
/// always rewards exactly +1, with no upper limit. Once every tile is back
/// in its correct position, a one-shot [PuzzleCompletionAnimation] plays
/// over the board before the win dialog appears.
class PuzzleGridScreen extends StatefulWidget {
  const PuzzleGridScreen({
    required this.puzzle,
    required this.hintsRemaining,
    required this.onHintsChanged,
    this.shuffleService = const PuzzleShuffleService(),
    super.key,
  });

  final Puzzle puzzle;
  final PuzzleShuffleService shuffleService;

  /// Hints carried over from the rest of the session; a fresh puzzle never
  /// resets this back down to [startingHints] on its own.
  final int hintsRemaining;
  final ValueChanged<int> onHintsChanged;

  /// Hints a brand-new session starts with. Not a ceiling: winning can take
  /// the count above this.
  static const startingHints = 2;

  @override
  State<PuzzleGridScreen> createState() => _PuzzleGridScreenState();
}

class _PuzzleGridScreenState extends State<PuzzleGridScreen> {
  /// Null until the player taps "Start Puzzle"; the tiles are only
  /// shuffled once gameplay actually begins.
  Puzzle? _puzzle;

  /// Mirrors [PuzzleGridScreen.hintsRemaining] locally so the UI can update
  /// instantly; every change is reported back via [PuzzleGridScreen.onHintsChanged]
  /// so it keeps persisting once this screen is gone.
  late int _hintsRemaining = widget.hintsRemaining;

  /// True while the one-shot completion celebration is playing, right after
  /// a solve is detected and before the win dialog appears. Only ever set
  /// from [_swapTiles]'s solve check, never from a rebuild, so it can't
  /// replay on navigation or unrelated state changes.
  bool _isCelebrating = false;

  void _startPuzzle() {
    setState(() {
      _puzzle = widget.shuffleService.shuffle(widget.puzzle);
    });
  }

  void _handleTileDropped(int fromCurrentIndex, int toCurrentIndex) {
    if (fromCurrentIndex == toCurrentIndex) {
      return;
    }

    _swapTiles(fromCurrentIndex, toCurrentIndex);
  }

  void _swapTiles(int firstCurrentIndex, int secondCurrentIndex) {
    final puzzle = _puzzle;
    if (puzzle == null) {
      return;
    }

    final swappedTiles = [
      for (final tile in puzzle.tiles)
        if (tile.currentIndex == firstCurrentIndex)
          tile.copyWith(currentIndex: secondCurrentIndex)
        else if (tile.currentIndex == secondCurrentIndex)
          tile.copyWith(currentIndex: firstCurrentIndex)
        else
          tile,
    ];

    final swappedPuzzle = puzzle.copyWith(tiles: swappedTiles);

    setState(() {
      _puzzle = swappedPuzzle;
    });

    if (swappedPuzzle.isSolved) {
      _rewardHint();
      setState(() {
        _isCelebrating = true;
      });
    }
  }

  void _handleCelebrationFinished() {
    setState(() {
      _isCelebrating = false;
    });
    _showWinDialog();
  }

  void _rewardHint() {
    setState(() {
      _hintsRemaining++;
    });
    widget.onHintsChanged(_hintsRemaining);
  }

  void _reshuffle() {
    setState(() {
      _puzzle = widget.shuffleService.shuffle(widget.puzzle);
    });
  }

  Future<void> _showWinDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PuzzleWinDialog(
        onPlayAgain: () {
          Navigator.of(dialogContext).pop();
          _reshuffle();
        },
        onBackToHome: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _handleHintTap() async {
    if (_hintsRemaining <= 0) {
      return;
    }

    setState(() {
      _hintsRemaining--;
    });
    widget.onHintsChanged(_hintsRemaining);

    await _showPreview();
  }

  Future<void> _showPreview() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: _FullImageView(imagePath: widget.puzzle.sourceImage.path),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox.square(
                    dimension: 48,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x99000000),
                      ),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close preview',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;
    final orderedTiles = puzzle == null
        ? const <PuzzleTile>[]
        : (List<PuzzleTile>.of(puzzle.tiles)
            ..sort((a, b) => a.currentIndex.compareTo(b.currentIndex)));

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                _PuzzleGridAppBar(
                  imageName: widget.puzzle.sourceImage.name,
                  hintsRemaining: puzzle == null ? null : _hintsRemaining,
                  onHint: _handleHintTap,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: puzzle == null
                      ? _StartPuzzleView(
                          imagePath: widget.puzzle.sourceImage.path,
                          gridSize: widget.puzzle.gridSize,
                          onStart: _startPuzzle,
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _isCelebrating
                                ? PuzzleCompletionAnimation(
                                    imagePath: puzzle.sourceImage.path,
                                    gridSize: puzzle.gridSize,
                                    orderedTiles: orderedTiles,
                                    onCompleted: _handleCelebrationFinished,
                                  )
                                : _PuzzleGrid(
                                    gridSize: puzzle.gridSize,
                                    imagePath: puzzle.sourceImage.path,
                                    orderedTiles: orderedTiles,
                                    onTileDropped: _handleTileDropped,
                                  ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PuzzleGridAppBar extends StatelessWidget {
  const _PuzzleGridAppBar({
    required this.imageName,
    required this.hintsRemaining,
    required this.onHint,
  });

  final String imageName;

  /// Null hides the hint button entirely (before the puzzle has started);
  /// otherwise the number of hints left for the current puzzle.
  final int? hintsRemaining;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solve the Puzzle',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                imageName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (hintsRemaining != null) ...[
          const SizedBox(width: 12),
          _HintButton(hintsRemaining: hintsRemaining!, onTap: onHint),
        ],
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x332B2576),
          border: Border.all(color: const Color(0x554C3DA1), width: 2),
        ),
        child: IconButton(
          color: Colors.white,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

/// Shows the hint (original-image preview) action with the remaining hint
/// count next to the icon, e.g. "👁 2". Greys out and stops responding to
/// taps once no hints are left.
class _HintButton extends StatelessWidget {
  const _HintButton({required this.hintsRemaining, required this.onTap});

  final int hintsRemaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasHintsLeft = hintsRemaining > 0;

    return Opacity(
      opacity: hasHintsLeft ? 1 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: hasHintsLeft ? onTap : null,
          child: Tooltip(
            message: hasHintsLeft
                ? 'Hint ($hintsRemaining left)'
                : 'No hints left',
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: const Color(0x332B2576),
                border: Border.all(color: const Color(0x554C3DA1), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$hintsRemaining',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullImageView extends StatelessWidget {
  const _FullImageView({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(imagePath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            color: Colors.white,
            size: 48,
          ),
        );
      },
    );
  }
}

class _StartPuzzleView extends StatelessWidget {
  const _StartPuzzleView({
    required this.imagePath,
    required this.gridSize,
    required this.onStart,
  });

  final String imagePath;
  final int gridSize;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _FullImageView(imagePath: imagePath),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Ready to solve this $gridSize x $gridSize puzzle?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              'Start Puzzle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PuzzleGrid extends StatelessWidget {
  const _PuzzleGrid({
    required this.gridSize,
    required this.imagePath,
    required this.orderedTiles,
    required this.onTileDropped,
  });

  static const _spacing = 2.0;

  final int gridSize;
  final String imagePath;
  final List<PuzzleTile> orderedTiles;
  final void Function(int fromCurrentIndex, int toCurrentIndex) onTileDropped;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize =
              (constraints.maxWidth - _spacing * (gridSize - 1)) / gridSize;

          return GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderedTiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: _spacing,
              mainAxisSpacing: _spacing,
            ),
            itemBuilder: (context, index) {
              final tile = orderedTiles[index];

              return _DraggablePuzzleTile(
                tile: tile,
                imagePath: imagePath,
                gridSize: gridSize,
                cellSize: cellSize,
                onTileDropped: onTileDropped,
              );
            },
          );
        },
      ),
    );
  }
}

class _DraggablePuzzleTile extends StatelessWidget {
  const _DraggablePuzzleTile({
    required this.tile,
    required this.imagePath,
    required this.gridSize,
    required this.cellSize,
    required this.onTileDropped,
  });

  final PuzzleTile tile;
  final String imagePath;
  final int gridSize;
  final double cellSize;
  final void Function(int fromCurrentIndex, int toCurrentIndex) onTileDropped;

  @override
  Widget build(BuildContext context) {
    final tileView = PuzzleTileView(
      imagePath: imagePath,
      row: tile.row,
      column: tile.column,
      gridSize: gridSize,
    );

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != tile.currentIndex,
      onAcceptWithDetails: (details) =>
          onTileDropped(details.data, tile.currentIndex),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDropTarget ? AppColors.gold : Colors.transparent,
              width: 3,
            ),
          ),
          child: Draggable<int>(
            data: tile.currentIndex,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: cellSize,
                height: cellSize,
                child: Opacity(opacity: 0.85, child: tileView),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: tileView),
            child: tileView,
          ),
        );
      },
    );
  }
}
