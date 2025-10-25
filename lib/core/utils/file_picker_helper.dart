import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Helper para seleccionar y manejar archivos
class FilePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Seleccionar imagen desde galería
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error seleccionando imagen: $e');
      return null;
    }
  }

  /// Seleccionar imagen desde cámara
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error tomando foto: $e');
      return null;
    }
  }

  /// Seleccionar múltiples imágenes
  static Future<List<File>?> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultipleMedia(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        return images.map((xFile) => File(xFile.path)).toList();
      }
      return null;
    } catch (e) {
      print('Error seleccionando múltiples imágenes: $e');
      return null;
    }
  }

  /// Seleccionar archivo de audio
  static Future<File?> pickAudioFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error seleccionando archivo de audio: $e');
      return null;
    }
  }

  /// Seleccionar archivo personalizado con extensiones específicas
  static Future<File?> pickCustomFile({
    required List<String> allowedExtensions,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error seleccionando archivo: $e');
      return null;
    }
  }

  /// Obtener información del archivo
  static Map<String, dynamic> getFileInfo(File file) {
    final fileStat = file.statSync();
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last;
    final fileSizeInBytes = fileStat.size;
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    return {
      'name': fileName,
      'extension': fileExtension,
      'path': file.path,
      'sizeInBytes': fileSizeInBytes,
      'sizeInMB': fileSizeInMB.toStringAsFixed(2),
    };
  }

  /// Validar tamaño de archivo (en MB)
  static bool validateFileSize(File file, double maxSizeInMB) {
    final fileInfo = getFileInfo(file);
    final fileSizeInMB = double.parse(fileInfo['sizeInMB']);
    return fileSizeInMB <= maxSizeInMB;
  }

  /// Validar extensión de archivo
  static bool validateFileExtension(File file, List<String> allowedExtensions) {
    final fileInfo = getFileInfo(file);
    final extension = fileInfo['extension'].toString().toLowerCase();
    return allowedExtensions
        .map((e) => e.toLowerCase())
        .contains(extension);
  }
}
