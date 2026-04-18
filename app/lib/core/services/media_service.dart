import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickFromGalleryAsWebP() async {
    return _pickAndConvertToWebP(ImageSource.gallery);
  }

  Future<XFile?> pickFromCameraAsWebP() async {
    return _pickAndConvertToWebP(ImageSource.camera);
  }

  Future<XFile?> _pickAndConvertToWebP(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      final inputPath = pickedFile.path;
      final dir = await getTemporaryDirectory();

      final outputPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.webp';

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        inputPath,
        outputPath,
        quality: 70,
        format: CompressFormat.webp,
      );

      return result;
    } catch (e) {
      print('Error converting to WebP: $e');
      return null;
    }
  }
}
