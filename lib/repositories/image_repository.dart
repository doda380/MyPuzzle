import '../models/selected_image.dart';
import '../services/image_picker_service.dart';

abstract class ImageRepository {
  Future<SelectedImage?> pickImageFromGallery();
}

class ImagePickerRepository implements ImageRepository {
  const ImagePickerRepository(this._imagePickerService);

  final ImagePickerService _imagePickerService;

  @override
  Future<SelectedImage?> pickImageFromGallery() async {
    final image = await _imagePickerService.pickImageFromGallery();

    if (image == null) {
      return null;
    }

    return SelectedImage(
      path: image.path,
      name: image.name,
    );
  }
}
