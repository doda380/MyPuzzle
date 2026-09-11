class PuzzleTile {
  const PuzzleTile({
    required this.correctIndex,
    required this.currentIndex,
    required this.row,
    required this.column,
  });

  /// Where this tile belongs in the solved puzzle.
  final int correctIndex;

  /// Where this tile currently is.
  final int currentIndex;

  /// Solved-position row within the grid (0-based).
  final int row;

  /// Solved-position column within the grid (0-based).
  final int column;

  bool get isInCorrectPosition => currentIndex == correctIndex;

  PuzzleTile copyWith({int? currentIndex}) {
    return PuzzleTile(
      correctIndex: correctIndex,
      currentIndex: currentIndex ?? this.currentIndex,
      row: row,
      column: column,
    );
  }
}
