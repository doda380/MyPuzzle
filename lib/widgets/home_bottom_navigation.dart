import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x66201A5F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.panelBorder, width: 1.5),
      ),
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: _NavigationItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: true,
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.extension_rounded,
                label: 'My Puzzles',
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.star_rounded,
                label: 'Achievements',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0x663F2C92) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.textMuted,
            size: 34,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
