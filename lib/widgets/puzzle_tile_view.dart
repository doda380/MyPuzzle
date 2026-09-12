import 'dart:io';

import 'package:flutter/material.dart';

/// Renders the single [gridSize] x [gridSize] fragment of the image at
/// [imagePath] that belongs at ([row], [column]), by laying out the full
/// image oversized inside a clipped viewport and aligning it so only that
/// fragment is visible.
class PuzzleTileView extends StatelessWidget {
  const PuzzleTileView({
    required this.imagePath,
    required this.row,
    required this.column,
    required this.gridSize,
    super.key,
  });

  final String imagePath;
  final int row;
  final int column;
  final int gridSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth;
        final tileHeight = constraints.maxHeight;

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment(_axisAlignment(column), _axisAlignment(row)),
            minWidth: tileWidth * gridSize,
            maxWidth: tileWidth * gridSize,
            minHeight: tileHeight * gridSize,
            maxHeight: tileHeight * gridSize,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(color: Color(0xFF1A1A2E));
              },
            ),
          ),
        );
      },
    );
  }

  double _axisAlignment(int position) {
    if (gridSize <= 1) {
      return 0;
    }

    return -1 + (2 * position / (gridSize - 1));
  }
}
