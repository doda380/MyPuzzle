import 'dart:io';

import 'package:flutter/material.dart';

import '../models/selected_image.dart';

class PuzzlePreviewCard extends StatelessWidget {
  const PuzzlePreviewCard({
    this.selectedImage,
    super.key,
  });

  final SelectedImage? selectedImage;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: selectedImage == null
            ? CustomPaint(
                painter: _ScenicPuzzlePainter(),
                child: const SizedBox.expand(),
              )
            : Image.file(
                File(selectedImage!.path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _ImagePreviewError();
                },
              ),
      ),
    );
  }
}

class _ImagePreviewError extends StatelessWidget {
  const _ImagePreviewError();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC1A1A2E),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load image',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenicPuzzlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawMountains(canvas, size);
    _drawForest(canvas, size);
    _drawLake(canvas, size);
    _drawPuzzleLines(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF9F8C),
          Color(0xFF8476E8),
          Color(0xFF1563C6),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, skyPaint);

    final sunPaint = Paint()..color = const Color(0xFFFFD36A);
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.48),
      24,
      sunPaint,
    );
  }

  void _drawMountains(Canvas canvas, Size size) {
    final backPaint = Paint()..color = const Color(0xFF604D9F);
    final frontPaint = Paint()..color = const Color(0xFF233878);
    final snowPaint = Paint()..color = const Color(0xFFEFEFFF);

    final backPath = Path()
      ..moveTo(0, size.height * 0.58)
      ..lineTo(size.width * 0.22, size.height * 0.34)
      ..lineTo(size.width * 0.38, size.height * 0.56)
      ..lineTo(size.width * 0.52, size.height * 0.28)
      ..lineTo(size.width * 0.72, size.height * 0.58)
      ..close();
    canvas.drawPath(backPath, backPaint);

    final frontPath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.62)
      ..lineTo(size.width * 0.52, size.height * 0.22)
      ..lineTo(size.width * 0.82, size.height * 0.62)
      ..close();
    canvas.drawPath(frontPath, frontPaint);

    final snowPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.22)
      ..lineTo(size.width * 0.43, size.height * 0.44)
      ..lineTo(size.width * 0.53, size.height * 0.38)
      ..lineTo(size.width * 0.58, size.height * 0.47)
      ..lineTo(size.width * 0.63, size.height * 0.40)
      ..close();
    canvas.drawPath(snowPath, snowPaint);
  }

  void _drawForest(Canvas canvas, Size size) {
    final treePaint = Paint()..color = const Color(0xFF0F2B3C);

    for (var i = 0; i < 26; i++) {
      final x = size.width * i / 25;
      final h = 22.0 + (i % 5) * 7;
      final baseY = size.height * 0.68;
      final tree = Path()
        ..moveTo(x, baseY - h)
        ..lineTo(x - 10, baseY)
        ..lineTo(x + 10, baseY)
        ..close();
      canvas.drawPath(tree, treePaint);
    }
  }

  void _drawLake(Canvas canvas, Size size) {
    final lakeRect = Rect.fromLTWH(
      0,
      size.height * 0.62,
      size.width,
      size.height * 0.38,
    );
    final lakePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xAA0A376D),
          Color(0xDD103E88),
          Color(0xFF111853),
        ],
      ).createShader(lakeRect);

    canvas.drawRect(lakeRect, lakePaint);

    final reflectionPaint = Paint()
      ..color = const Color(0x66F6A06F)
      ..strokeWidth = 2;
    for (var i = 0; i < 8; i++) {
      final y = size.height * (0.72 + i * 0.03);
      canvas.drawLine(
        Offset(size.width * 0.05, y),
        Offset(size.width * 0.48, y + (i.isEven ? 2 : -2)),
        reflectionPaint,
      );
    }
  }

  void _drawPuzzleLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0x9912193F)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    const columns = 6;
    const rows = 4;

    for (var column = 1; column < columns; column++) {
      final x = size.width * column / columns;
      final path = Path()..moveTo(x, 0);

      for (var row = 0; row < rows; row++) {
        final top = size.height * row / rows;
        final middle = top + size.height / rows / 2;
        final radius = size.width * 0.025;

        path
          ..lineTo(x, middle - radius)
          ..cubicTo(
            x + radius,
            middle - radius,
            x + radius,
            middle + radius,
            x,
            middle + radius,
          )
          ..lineTo(x, top + size.height / rows);
      }

      canvas.drawPath(path, linePaint);
    }

    for (var row = 1; row < rows; row++) {
      final y = size.height * row / rows;
      final path = Path()..moveTo(0, y);

      for (var column = 0; column < columns; column++) {
        final left = size.width * column / columns;
        final middle = left + size.width / columns / 2;
        final radius = size.height * 0.035;

        path
          ..lineTo(middle - radius, y)
          ..cubicTo(
            middle - radius,
            y - radius,
            middle + radius,
            y - radius,
            middle + radius,
            y,
          )
          ..lineTo(left + size.width / columns, y);
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
