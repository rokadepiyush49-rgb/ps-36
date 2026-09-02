import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Camera and gallery access for evidence photos.
class MediaService {
  MediaService(this._picker);

  final ImagePicker _picker;

  /// Field evidence is captured live so the geotag and timestamp are real.
  Future<String?> capturePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 82,
      maxWidth: 2000,
    );
    return file?.path;
  }

  Future<List<String>> pickPhotos({int limit = 4}) async {
    final files = await _picker.pickMultiImage(imageQuality: 82, maxWidth: 2000);
    return files.take(limit).map((f) => f.path).toList();
  }
}

final mediaServiceProvider = Provider<MediaService>(
  (ref) => MediaService(ImagePicker()),
);
