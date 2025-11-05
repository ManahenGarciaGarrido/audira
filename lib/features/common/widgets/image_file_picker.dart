import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/services/file_upload_service.dart';
import '../../../core/models/file_upload_response.dart';

enum ImageUploadType {
  profile,
  banner,
  cover,
}

/// Widget for picking and uploading image files
/// Supports: JPG, PNG, GIF, WEBP
class ImageFilePicker extends StatefulWidget {
  final ImageUploadType uploadType;
  final Function(FileUploadResponse) onUploadComplete;
  final Function(String)? onUploadError;
  final int? userId;
  final int? productId;
  final String? buttonText;
  final bool showPreview;
  final double? previewHeight;

  ImageFilePicker({
    super.key,
    required this.uploadType,
    required this.onUploadComplete,
    this.onUploadError,
    this.userId,
    this.productId,
    String? buttonText,
    this.showPreview = true,
    this.previewHeight,
  }) : buttonText = buttonText ?? _getDefaultButtonText(uploadType);

  static String _getDefaultButtonText(ImageUploadType type) {
    switch (type) {
      case ImageUploadType.profile:
        return 'Seleccionar Foto de Perfil';
      case ImageUploadType.banner:
        return 'Seleccionar Banner';
      case ImageUploadType.cover:
        return 'Seleccionar Portada';
    }
  }

  @override
  State<ImageFilePicker> createState() => _ImageFilePickerState();
}

class _ImageFilePickerState extends State<ImageFilePicker> {
  final FileUploadService _fileUploadService = FileUploadService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      // Pick image
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: widget.uploadType == ImageUploadType.profile ? 1024 : 2048,
        maxHeight: widget.uploadType == ImageUploadType.profile ? 1024 : 2048,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final file = File(pickedFile.path);
      _selectedImage = file;

      // Validate file
      if (!_fileUploadService.isValidImageFile(file)) {
        _showError('Formato de imagen no válido');
        return;
      }

      // Check file size
      final fileSize = await file.length();
      final maxSize = widget.uploadType == ImageUploadType.profile
          ? _fileUploadService.maxProfileImageSize
          : _fileUploadService.maxBannerImageSize;

      if (fileSize > maxSize) {
        final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(0);
        _showError('El archivo excede el tamaño máximo de ${maxSizeMB}MB');
        return;
      }

      setState(() {
        _isUploading = true;
      });

      // Upload file based on type
      late ApiResponse<FileUploadResponse> response;

      switch (widget.uploadType) {
        case ImageUploadType.profile:
          response = await _fileUploadService.uploadProfileImage(
            file,
            userId: widget.userId,
          );
          break;
        case ImageUploadType.banner:
          response = await _fileUploadService.uploadBannerImage(
            file,
            userId: widget.userId,
          );
          break;
        case ImageUploadType.cover:
          response = await _fileUploadService.uploadCoverImage(
            file,
            productId: widget.productId,
          );
          break;
      }

      setState(() {
        _isUploading = false;
      });

      if (response.success && response.data != null) {
        setState(() {
          _uploadedImageUrl = response.data!.fileUrl;
        });

        widget.onUploadComplete(response.data!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen subida exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final error = response.error ?? 'Error al subir imagen';
        _showError(error);
        widget.onUploadError?.call(error);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      final error = 'Error al procesar imagen: $e';
      _showError(error);
      widget.onUploadError?.call(error);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera, color: AppTheme.primaryBlue),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppTheme.primaryBlue),
                title: const Text('Seleccionar de Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showPreview && (_selectedImage != null || _uploadedImageUrl != null)) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: widget.previewHeight ?? 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : _uploadedImageUrl != null
                    ? Image.network(
                        _uploadedImageUrl!,
                        height: widget.previewHeight ?? 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: widget.previewHeight ?? 200,
                            color: AppTheme.backgroundBlack,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: widget.previewHeight ?? 200,
                            color: AppTheme.backgroundBlack,
                            child: const Icon(Icons.error),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _showImageSourceDialog,
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.image),
          label: Text(
            _isUploading ? 'Subiendo...' : widget.buttonText!,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
