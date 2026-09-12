import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.gradientColors,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final IconData buttonIcon;
  final List<Color> gradientColors;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sized from whichever dimension is tighter. The card's height is
        // flex-driven by the home screen (not an aspect ratio), so it can
        // end up shorter than the "reference" size these constants were
        // tuned for -- heightScale shrinks everything together so the
        // content never overflows a short card.
        const referenceHeight = 280.0;
        final heightScale = constraints.maxHeight.isFinite
            ? (constraints.maxHeight / referenceHeight).clamp(0.5, 1.15)
            : 1.0;

        double sized(double reference, double min, double max) {
          return (reference * heightScale).clamp(min, max).toDouble();
        }

        final iconBadgeSize = sized(72, 36, 80).clamp(
          0.0,
          constraints.maxWidth * 0.5,
        );
        final iconSize = iconBadgeSize * 0.55;
        final titleSize = sized(22, 12, 24);
        final bodySize = sized(15, 9, 16);
        final buttonHeight = sized(50, 30, 54);
        final iconGap = sized(12, 4, 12);
        final textGap = sized(8, 4, 8);
        final cardPadding = sized(12, 6, 12);

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            border: Border.all(color: Colors.white24, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconBadge(
                  icon: icon,
                  size: iconBadgeSize,
                  iconSize: iconSize,
                ),
                SizedBox(height: iconGap),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                ),
                SizedBox(height: textGap),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: bodySize,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                ),
                SizedBox(height: iconGap),
                _ActionButton(
                  icon: buttonIcon,
                  label: buttonLabel,
                  height: buttonHeight,
                  onPressed: onPressed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(
          icon,
          color: AppColors.purpleDark,
          size: iconSize,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.height,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final double height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0x443B82F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: height * 0.44),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: height * 0.38,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}
