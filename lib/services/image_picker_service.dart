import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickImageFromGallery() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
  }
}
