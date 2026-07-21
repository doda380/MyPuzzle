import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/selected_image.dart';
import '../repositories/image_repository.dart';
import '../services/image_picker_service.dart';
import '../widgets/home_action_card.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/puzzle_preview_card.dart';
import '../widgets/recent_puzzles_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageRepository _imageRepository = ImagePickerRepository(
    ImagePickerService(),
  );

  SelectedImage? _selectedImage;
  bool _isPickingImage = false;

  Future<void> _pickImageFromGallery() async {
    if (_isPickingImage) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final selectedImage = await _imageRepository.pickImageFromGallery();

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImage = selectedImage;
      });

      final message = _selectedImage == null
          ? 'No image selected.'
          : 'Selected ${_selectedImage!.name}. Preview comes next.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the gallery. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundTop,
              AppColors.backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth =
                  constraints.maxWidth.clamp(0.0, 720.0).toDouble();

              return Stack(
                children: [
                  const _BackgroundPuzzlePieces(),
                  Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        children: [
                          const _TopBar(),
                          const SizedBox(height: 12),
                          const _HomeTitle(),
                          const SizedBox(height: 22),
                          const _Tagline(),
                          const SizedBox(height: 28),
                          const PuzzlePreviewCard(),
                          const SizedBox(height: 24),
                          _ActionCards(
                            isPickingImage: _isPickingImage,
                            onGalleryPressed: _pickImageFromGallery,
                          ),
                          const SizedBox(height: 24),
                          const RecentPuzzlesPanel(),
                          const SizedBox(height: 24),
                          const HomeBottomNavigation(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CircleIconButton(
          icon: Icons.menu_rounded,
          onPressed: () {},
        ),
        _CircleIconButton(
          icon: Icons.settings_rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x332B2576),
          border: Border.all(color: const Color(0x554C3DA1), width: 2),
        ),
        child: IconButton(
          color: Colors.white,
          iconSize: 32,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 92,
          top: 10,
          child: Transform.rotate(
            angle: -0.35,
            child: const Icon(
              Icons.extension_rounded,
              color: Color(0xFFFF4BA1),
              size: 42,
            ),
          ),
        ),
        Positioned(
          right: 96,
          top: 14,
          child: Transform.rotate(
            angle: 0.35,
            child: const Icon(
              Icons.extension_rounded,
              color: Color(0xFF37B7FF),
              size: 44,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              'My',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontSize: 58,
                fontWeight: FontWeight.w900,
                height: 0.9,
                shadows: const [
                  Shadow(
                    color: Color(0xAA4B3BB0),
                    offset: Offset(0, 7),
                  ),
                ],
              ),
            ),
            Text(
              'Puzzle',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.gold,
                fontSize: 58,
                fontWeight: FontWeight.w900,
                height: 0.9,
                shadows: const [
                  Shadow(
                    color: Color(0xCCB05D00),
                    offset: Offset(0, 7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Turn any picture\ninto a '),
          TextSpan(
            text: 'fun',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const TextSpan(text: ' puzzle!'),
        ],
      ),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
    );
  }
}

class _ActionCards extends StatelessWidget {
  const _ActionCards({
    required this.isPickingImage,
    required this.onGalleryPressed,
  });

  final bool isPickingImage;
  final VoidCallback onGalleryPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HomeActionCard(
            icon: Icons.camera_alt_rounded,
            title: 'Capture Image',
            description: 'Take a photo and\nmake a puzzle',
            buttonLabel: 'Capture',
            buttonIcon: Icons.camera_alt_rounded,
            gradientColors: const [
              AppColors.purple,
              AppColors.purpleDark,
            ],
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HomeActionCard(
            icon: Icons.photo_library_rounded,
            title: 'Upload from Gallery',
            description: 'Choose a picture from\nyour gallery',
            buttonLabel: 'Upload',
            buttonIcon: Icons.cloud_upload_rounded,
            gradientColors: const [
              AppColors.blue,
              AppColors.blueDark,
            ],
            onPressed: isPickingImage ? null : onGalleryPressed,
          ),
        ),
      ],
    );
  }
}

class _BackgroundPuzzlePieces extends StatelessWidget {
  const _BackgroundPuzzlePieces();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -28,
            top: 180,
            child: Transform.rotate(
              angle: -0.45,
              child: const Icon(
                Icons.extension_rounded,
                size: 96,
                color: Color(0x332F2779),
              ),
            ),
          ),
          Positioned(
            right: -18,
            top: 420,
            child: Transform.rotate(
              angle: 0.45,
              child: const Icon(
                Icons.extension_rounded,
                size: 82,
                color: Color(0x88FFB22E),
              ),
            ),
          ),
          Positioned(
            right: 44,
            bottom: 190,
            child: Transform.rotate(
              angle: 0.35,
              child: const Icon(
                Icons.extension_rounded,
                size: 92,
                color: Color(0x252D2776),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
