import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerServices {
  final ImagePicker _imagePicker = ImagePicker();

  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        return image;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<XFile?> takeImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        return image;
      }
    } catch (e) {
      rethrow;
    }
    return XFile('');
  }

  Future<XFile?> pickFile() async {
    try {
      final file = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (file != null && file.files.isNotEmpty) {
        return XFile(file.files.first.path!);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<XFile?> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        return video;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<XFile?> takeVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );
      if (video != null) {
        return video;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
