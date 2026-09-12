import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/puzzle_tile.dart';
import 'puzzle_tile_view.dart';

/// Plays a one-shot celebration sequence over the already-solved puzzle
/// board: the tile seams merge away, the complete original image is
/// revealed, then a bounce/glow/confetti/achievement beat plays before
/// [onCompleted] fires (the caller shows the existing win dialog then).
///
/// Driven by a single [AnimationController] so the sequence is deterministic
/// and runs exactly once for the lifetime of this widget instance.
class PuzzleCompletionAnimation extends StatefulWidget {
  const PuzzleCompletionAnimation({
    required this.imagePath,
    required this.gridSize,
    required this.orderedTiles,
    required this.onCompleted,
    super.key,
  });

  final String imagePath;
  final int gridSize;

  /// The solved tiles, already sorted into their correct grid order.
  final List<PuzzleTile> orderedTiles;
  final VoidCallback onCompleted;

  @override
  State<PuzzleCompletionAnimation> createState() =>
      _PuzzleCompletionAnimationState();
}

class _PuzzleCompletionAnimationState extends State<PuzzleCompletionAnimation>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2600);
  static const _gridSpacing = 2.0;
  static const _particleCount = 18;

  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      _particleCount,
      (_) => _ConfettiParticle.random(),
    );
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Progress of the sub-phase spanning [start, end] of the overall timeline
  /// (both in 0..1), clamped to 0..1.
  double _phase(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        final assembleT = Curves.easeInOut.transform(_phase(t, 0, 0.20));
        final revealT = Curves.easeInOut.transform(_phase(t, 0.20, 0.35));
        final popPhase = _phase(t, 0.35, 0.52);
        final popT = math.sin(math.pi * popPhase);
        final confettiT = _phase(t, 0.35, 1);
        final badgeT = Curves.easeOutBack.transform(_phase(t, 0.45, 0.68));

        final spacing = (1 - assembleT) * _gridSpacing;
        final tileScale = 1 + 0.04 * (1 - assembleT);

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 1 - revealT,
                child: Transform.scale(
                  scale: tileScale,
                  child: _AssembledTileGrid(
                    imagePath: widget.imagePath,
                    gridSize: widget.gridSize,
                    orderedTiles: widget.orderedTiles,
                    spacing: spacing,
                  ),
                ),
              ),
            ),
            if (revealT > 0)
              Positioned.fill(
                child: Opacity(
                  opacity: revealT,
                  child: Transform.scale(
                    scale: 1 + 0.08 * popT,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(
                              alpha: 0.55 * popT,
                            ),
                            blurRadius: 36,
                            spreadRadius: 4 * popT,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const ColoredBox(color: Color(0xFF1A1A2E));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (confettiT > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: confettiT,
                    ),
                  ),
                ),
              ),
            if (badgeT > 0)
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: badgeT.clamp(0, 1),
                    child: Transform.scale(
                      scale: 0.7 + 0.3 * badgeT,
                      child: const _AchievementBadge(),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AssembledTileGrid extends StatelessWidget {
  const _AssembledTileGrid({
    required this.imagePath,
    required this.gridSize,
    required this.orderedTiles,
    required this.spacing,
  });

  final String imagePath;
  final int gridSize;
  final List<PuzzleTile> orderedTiles;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orderedTiles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemBuilder: (context, index) {
          final tile = orderedTiles[index];

          return PuzzleTileView(
            imagePath: imagePath,
            row: tile.row,
            column: tile.column,
            gridSize: gridSize,
          );
        },
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE61A1440),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.gold,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Puzzle Completed!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+1 Hint',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotationSpeed,
    required this.startDelay,
  });

  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rotationSpeed;
  final double startDelay;

  static final _colors = [
    AppColors.gold,
    AppColors.purple,
    AppColors.blue,
    const Color(0xFFFF4BA1),
  ];

  factory _ConfettiParticle.random() {
    final random = math.Random();
    return _ConfettiParticle(
      vx: (random.nextDouble() * 2 - 1) * 0.9,
      vy: -(random.nextDouble() * 0.5 + 0.4),
      color: _colors[random.nextInt(_colors.length)],
      size: 6 + random.nextDouble() * 6,
      rotationSpeed: random.nextDouble() * 2 - 1,
      startDelay: random.nextDouble() * 0.25,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.35);

    for (final particle in particles) {
      final localT = ((progress - particle.startDelay) /
              (1 - particle.startDelay))
          .clamp(0.0, 1.0);
      if (localT <= 0) {
        continue;
      }

      final opacity = (1 - localT).clamp(0.0, 1.0);
      if (opacity <= 0) {
        continue;
      }

      final dx = particle.vx * size.width * 0.5 * localT;
      final dy =
          particle.vy * size.height * 0.5 * localT +
          0.9 * size.height * localT * localT;

      canvas.save();
      canvas.translate(center.dx + dx, center.dy + dy);
      canvas.rotate(particle.rotationSpeed * localT * 2 * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = particle.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
