import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/selected_image.dart';
import '../services/puzzle_tile_service.dart';
import 'puzzle_grid_screen.dart';

class _DifficultyOption {
  const _DifficultyOption({
    required this.label,
    required this.gridSize,
    required this.subtitle,
  });

  final String label;
  final int gridSize;
  final String subtitle;
}

const _difficultyOptions = [
  _DifficultyOption(label: 'Easy', gridSize: 3, subtitle: '3 x 3 · 9 pieces'),
  _DifficultyOption(
    label: 'Medium',
    gridSize: 4,
    subtitle: '4 x 4 · 16 pieces',
  ),
  _DifficultyOption(label: 'Hard', gridSize: 5, subtitle: '5 x 5 · 25 pieces'),
];

/// Lets the player choose how many pieces to split [selectedImage] into.
/// The full photo is shown next, before the puzzle actually starts.
class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({
    required this.selectedImage,
    required this.hintsRemaining,
    required this.onHintsChanged,
    this.puzzleTileService = const PuzzleTileService(),
    super.key,
  });

  final SelectedImage selectedImage;

  /// Hints carried over from the rest of the session; passed straight
  /// through to the puzzle screen without being reset here.
  final int hintsRemaining;
  final ValueChanged<int> onHintsChanged;
  final PuzzleTileService puzzleTileService;

  void _selectDifficulty(BuildContext context, int gridSize) {
    final puzzle = puzzleTileService.buildPuzzle(
      selectedImage,
      gridSize: gridSize,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PuzzleGridScreen(
          puzzle: puzzle,
          hintsRemaining: hintsRemaining,
          onHintsChanged: onHintsChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.square(
                  dimension: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x332B2576),
                      border: Border.all(
                        color: const Color(0x554C3DA1),
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Choose a Difficulty',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick how many pieces to split your photo into.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 28),
                for (final option in _difficultyOptions) ...[
                  _DifficultyCard(
                    label: option.label,
                    subtitle: option.subtitle,
                    onTap: () => _selectDifficulty(context, option.gridSize),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x55201A5F),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.panelBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
