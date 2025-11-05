import 'dart:io';

import '../api_client.dart';
import '../../../config/constants.dart';
import '../../models/file_upload_response.dart';

class FileUploadService {
  final ApiClient _apiClient = ApiClient();

  /// Upload an audio file
  /// Supports: MP3, WAV, FLAC, MIDI, OGG, AAC
  /// Max size: 50MB
  Future<ApiResponse<FileUploadResponse>> uploadAudioFile(
    File audioFile, {
    int? songId,
  }) async {
    final fields = <String, String>{};
    if (songId != null) {
      fields['songId'] = songId.toString();
    }

    final response = await _apiClient.postMultipart(
      AppConstants.fileUploadAudioUrl,
      file: audioFile,
      fileFieldName: 'file',
      fields: fields,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      try {
        return ApiResponse(
          success: true,
          data: FileUploadResponse.fromJson(
            response.data as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          error: 'Error al parsear respuesta: $e',
        );
      }
    }
    return ApiResponse(success: false, error: response.error);
  }

  /// Upload a profile image
  /// Supports: JPG, PNG, GIF, WEBP
  /// Max size: 5MB
  Future<ApiResponse<FileUploadResponse>> uploadProfileImage(
    File imageFile, {
    int? userId,
  }) async {
    final fields = <String, String>{};
    if (userId != null) {
      fields['userId'] = userId.toString();
    }

    final response = await _apiClient.postMultipart(
      AppConstants.fileUploadProfileImageUrl,
      file: imageFile,
      fileFieldName: 'file',
      fields: fields,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      try {
        return ApiResponse(
          success: true,
          data: FileUploadResponse.fromJson(
            response.data as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          error: 'Error al parsear respuesta: $e',
        );
      }
    }
    return ApiResponse(success: false, error: response.error);
  }

  /// Upload a banner image
  /// Supports: JPG, PNG, GIF, WEBP
  /// Max size: 10MB
  Future<ApiResponse<FileUploadResponse>> uploadBannerImage(
    File imageFile, {
    int? userId,
  }) async {
    final fields = <String, String>{};
    if (userId != null) {
      fields['userId'] = userId.toString();
    }

    final response = await _apiClient.postMultipart(
      AppConstants.fileUploadBannerImageUrl,
      file: imageFile,
      fileFieldName: 'file',
      fields: fields,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      try {
        return ApiResponse(
          success: true,
          data: FileUploadResponse.fromJson(
            response.data as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          error: 'Error al parsear respuesta: $e',
        );
      }
    }
    return ApiResponse(success: false, error: response.error);
  }

  /// Upload a cover image (for albums, songs, etc.)
  /// Supports: JPG, PNG, GIF, WEBP
  /// Max size: 10MB
  Future<ApiResponse<FileUploadResponse>> uploadCoverImage(
    File imageFile, {
    int? productId,
  }) async {
    final fields = <String, String>{};
    if (productId != null) {
      fields['productId'] = productId.toString();
    }

    final response = await _apiClient.postMultipart(
      AppConstants.fileUploadCoverImageUrl,
      file: imageFile,
      fileFieldName: 'file',
      fields: fields,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      try {
        return ApiResponse(
          success: true,
          data: FileUploadResponse.fromJson(
            response.data as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          error: 'Error al parsear respuesta: $e',
        );
      }
    }
    return ApiResponse(success: false, error: response.error);
  }

  /// Compress an image
  /// Returns the compressed image as bytes
  Future<ApiResponse<List<int>>> compressImage(
    File imageFile, {
    double quality = 0.8,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final fields = <String, String>{
      'quality': quality.toString(),
    };

    if (maxWidth != null) {
      fields['maxWidth'] = maxWidth.toString();
    }
    if (maxHeight != null) {
      fields['maxHeight'] = maxHeight.toString();
    }

    final response = await _apiClient.postMultipart(
      AppConstants.fileCompressImageUrl,
      file: imageFile,
      fileFieldName: 'file',
      fields: fields,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      try {
        // The response is binary data, not JSON
        // In this case we need to handle it differently
        // For now, return an error indicating this needs special handling
        return ApiResponse(
          success: false,
          error: 'Use compressImageRaw for binary responses',
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          error: 'Error al comprimir imagen: $e',
        );
      }
    }
    return ApiResponse(success: false, error: response.error);
  }

  /// Get image compression statistics
  /// Returns optimization stats without actually saving the file
  Future<ApiResponse<ImageCompressionStats>> getImageCompressionStats(
    File imageFile, {
    double quality = 0.8,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final fields = <String, String>{
      'quality': quality.toString(),
    };

    if (maxWidth != null) {
      fields['maxWidth'] = maxWidth.toString();
    }
    if (maxHeight != null) {
      fields['maxHeight'] = maxHeight.toString();
    }

    final response = await _apiClient.postMultipart(
      AppConstants.fileOptimizeImageUrl,
      file: imageFile,
      fileFieldName: 'file',
      fields: fields,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      try {
        return ApiResponse(
          success: true,
          data: ImageCompressionStats.fromJson(
            response.data as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          error: 'Error al parsear estadísticas: $e',
        );
      }
    }
    return ApiResponse(success: false, error: response.error);
  }

  /// Build the complete URL for a file
  String getFileUrl(String filePath) {
    return '${AppConstants.apiGatewayUrl}${AppConstants.fileServeUrl}/$filePath';
  }

  /// Check if a file is a valid audio file
  bool isValidAudioFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'flac', 'midi', 'mid', 'ogg', 'aac'].contains(ext);
  }

  /// Check if a file is a valid image file
  bool isValidImageFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  /// Get the max allowed size for audio files (in bytes)
  int get maxAudioFileSize => 50 * 1024 * 1024; // 50MB

  /// Get the max allowed size for profile images (in bytes)
  int get maxProfileImageSize => 5 * 1024 * 1024; // 5MB

  /// Get the max allowed size for banner/cover images (in bytes)
  int get maxBannerImageSize => 10 * 1024 * 1024; // 10MB
}
