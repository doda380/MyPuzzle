import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const PhotoPuzzleApp());
}

class PhotoPuzzleApp extends StatelessWidget {
  const PhotoPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
