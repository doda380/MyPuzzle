import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/puzzle.dart';
import '../models/puzzle_tile.dart';
import '../services/puzzle_shuffle_service.dart';
import '../widgets/puzzle_tile_view.dart';
import '../widgets/puzzle_win_dialog.dart';

/// Displays the puzzle tiles shuffled into a playable grid. Tapping a tile
/// selects it; tapping a second tile swaps the two. Once every tile is back
/// in its correct position, a win dialog is shown.
class PuzzleGridScreen extends StatefulWidget {
  const PuzzleGridScreen({
    required this.puzzle,
    this.shuffleService = const PuzzleShuffleService(),
    super.key,
  });

  final Puzzle puzzle;
  final PuzzleShuffleService shuffleService;

  @override
  State<PuzzleGridScreen> createState() => _PuzzleGridScreenState();
}

class _PuzzleGridScreenState extends State<PuzzleGridScreen> {
  late Puzzle _puzzle;
  int? _selectedCurrentIndex;

  @override
  void initState() {
    super.initState();
    _puzzle = widget.shuffleService.shuffle(widget.puzzle);
  }

  void _handleTileTap(PuzzleTile tappedTile) {
    final selected = _selectedCurrentIndex;

    if (selected == null) {
      setState(() => _selectedCurrentIndex = tappedTile.currentIndex);
      return;
    }

    if (selected == tappedTile.currentIndex) {
      setState(() => _selectedCurrentIndex = null);
      return;
    }

    _swapTiles(selected, tappedTile.currentIndex);
  }

  void _swapTiles(int firstCurrentIndex, int secondCurrentIndex) {
    final swappedTiles = [
      for (final tile in _puzzle.tiles)
        if (tile.currentIndex == firstCurrentIndex)
          tile.copyWith(currentIndex: secondCurrentIndex)
        else if (tile.currentIndex == secondCurrentIndex)
          tile.copyWith(currentIndex: firstCurrentIndex)
        else
          tile,
    ];

    final swappedPuzzle = _puzzle.copyWith(tiles: swappedTiles);

    setState(() {
      _puzzle = swappedPuzzle;
      _selectedCurrentIndex = null;
    });

    if (swappedPuzzle.isSolved) {
      _showWinDialog();
    }
  }

  void _reshuffle() {
    setState(() {
      _puzzle = widget.shuffleService.shuffle(widget.puzzle);
      _selectedCurrentIndex = null;
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

  @override
  Widget build(BuildContext context) {
    final orderedTiles = List<PuzzleTile>.of(_puzzle.tiles)
      ..sort((a, b) => a.currentIndex.compareTo(b.currentIndex));

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
                _PuzzleGridAppBar(imageName: _puzzle.sourceImage.name),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _PuzzleGrid(
                        gridSize: _puzzle.gridSize,
                        imagePath: _puzzle.sourceImage.path,
                        orderedTiles: orderedTiles,
                        selectedIndex: _selectedCurrentIndex,
                        onTileTap: _handleTileTap,
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
  const _PuzzleGridAppBar({required this.imageName});

  final String imageName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox.square(
          dimension: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x332B2576),
              border: Border.all(color: const Color(0x554C3DA1), width: 2),
            ),
            child: IconButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
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
      ],
    );
  }
}

class _PuzzleGrid extends StatelessWidget {
  const _PuzzleGrid({
    required this.gridSize,
    required this.imagePath,
    required this.orderedTiles,
    required this.selectedIndex,
    required this.onTileTap,
  });

  final int gridSize;
  final String imagePath;
  final List<PuzzleTile> orderedTiles;
  final int? selectedIndex;
  final ValueChanged<PuzzleTile> onTileTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderedTiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            final tile = orderedTiles[index];
            final isSelected = tile.currentIndex == selectedIndex;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTileTap(tile),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.gold : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: PuzzleTileView(
                  imagePath: imagePath,
                  row: tile.row,
                  column: tile.column,
                  gridSize: gridSize,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
