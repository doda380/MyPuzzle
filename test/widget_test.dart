import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:photo_puzzle/main.dart';

void main() {
  testWidgets('shows the home screen', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const PhotoPuzzleApp());

    expect(find.text('My'), findsOneWidget);
    expect(find.text('Puzzle'), findsOneWidget);
    expect(find.text('Upload from Gallery'), findsOneWidget);
  });
}
