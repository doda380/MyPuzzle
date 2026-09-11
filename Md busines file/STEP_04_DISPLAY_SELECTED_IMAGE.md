# Step 4: Display the Selected Image

## Goal

Implement **Step 4 only** of the Flutter photo puzzle game: after the player selects an image from the gallery, show that selected image in the existing preview area on the Home Screen.

Do not implement puzzle slicing, puzzle grid rendering, shuffling, tile swapping, difficulty selection, camera support, timers, counters, or win logic in this phase.

## Current Context

The app already has:

- A Flutter project scaffold.
- A Home Screen UI.
- Gallery selection using `image_picker`.
- A `SelectedImage` model containing:
  - `path`
  - `name`
- Home Screen state that stores the selected image in `_selectedImage`.

Relevant files:

```text
lib/
  models/
    selected_image.dart
  repositories/
    image_repository.dart
  services/
    image_picker_service.dart
  screens/
    home_screen.dart
  widgets/
    puzzle_preview_card.dart
```

## Required Behavior

When no image is selected:

- Keep showing the existing illustrated puzzle preview placeholder.

When an image is selected from the gallery:

- Replace the placeholder preview with the selected image.
- Display the image inside the existing preview card.
- Preserve the rounded corners and white border.
- Use `BoxFit.cover` so the image fills the preview area cleanly.
- Handle image loading errors gracefully with a simple fallback message/icon.

## Required File Changes

### 1. Update `lib/widgets/puzzle_preview_card.dart`

Convert `PuzzlePreviewCard` from a fixed placeholder widget into a reusable preview widget that accepts an optional `SelectedImage`.

Expected public API:

```dart
class PuzzlePreviewCard extends StatelessWidget {
  const PuzzlePreviewCard({
    this.selectedImage,
    super.key,
  });

  final SelectedImage? selectedImage;
}
```

Implementation logic:

- Import `dart:io`.
- Import `../models/selected_image.dart`.
- Keep the existing `AspectRatio`, rounded clipping, border, and placeholder painter.
- Inside the card:
  - If `selectedImage == null`, render the existing `CustomPaint`.
  - If `selectedImage != null`, render:

```dart
Image.file(
  File(selectedImage!.path),
  width: double.infinity,
  height: double.infinity,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return const _ImagePreviewError();
  },
)
```

Add a private `_ImagePreviewError` widget in the same file. Keep it simple:

- Dark translucent background.
- Broken image or image-not-supported icon.
- Text such as `Could not load image`.

Do not add a new screen yet.

### 2. Update `lib/screens/home_screen.dart`

Pass the stored selected image into the preview card.

Change:

```dart
const PuzzlePreviewCard(),
```

To:

```dart
PuzzlePreviewCard(selectedImage: _selectedImage),
```

Keep the current gallery picking flow and snackbar behavior.

## Expected Folder Structure After This Step

No new folders are required.

Only these existing files should change:

```text
lib/
  screens/
    home_screen.dart
  widgets/
    puzzle_preview_card.dart
```

## Acceptance Criteria

- The app starts on the Home Screen.
- Before selecting an image, the preview card still shows the existing illustrated placeholder.
- Tapping `Upload` opens the gallery.
- After selecting an image, the preview card displays that image.
- The image keeps the existing preview card shape:
  - rounded corners
  - white border
  - same aspect ratio
- If the image cannot be loaded, the UI shows a clean fallback instead of crashing.
- No puzzle tile logic is added yet.
- No camera logic is added yet.

## Verification Commands

Run:

```powershell
flutter analyze
flutter test
flutter run
```

If running on Android emulator, make sure an emulator is already started or available through Android Studio Device Manager.

## Important Boundaries

This is still part of the step-by-step workflow.

Only implement:

- selected image preview display
- preview fallback for load errors

Do not implement:

- image cropping
- tile splitting
- grid rendering
- shuffling
- swapping
- difficulty selection
- camera capture
- puzzle-solving logic
