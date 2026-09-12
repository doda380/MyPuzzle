import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class PuzzleWinDialog extends StatelessWidget {
  const PuzzleWinDialog({
    required this.onPlayAgain,
    required this.onBackToHome,
    super.key,
  });

  final VoidCallback onPlayAgain;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: const Icon(
        Icons.emoji_events_rounded,
        color: AppColors.gold,
        size: 48,
      ),
      title: Text(
        '🎉 Puzzle Solved!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Text(
        'Great job!',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: onBackToHome,
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: onPlayAgain,
          style: FilledButton.styleFrom(backgroundColor: AppColors.purple),
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}
