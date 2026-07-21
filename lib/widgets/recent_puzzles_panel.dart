import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class RecentPuzzlesPanel extends StatelessWidget {
  const RecentPuzzlesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x55201A5F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.panelBorder, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 17,
                        backgroundColor: AppColors.purple,
                        child: Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Recent Puzzles',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No puzzles yet\nCreate your first puzzle!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Transform.rotate(
              angle: 0.35,
              child: const Icon(
                Icons.extension_rounded,
                color: Color(0x252D2776),
                size: 82,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
