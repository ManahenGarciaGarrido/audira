class FileUploadResponse {
  final String? fileUrl;
  final String? filePath;
  final int? songId;
  final int? productId;
  final String? message;

  FileUploadResponse({
    this.fileUrl,
    this.filePath,
    this.songId,
    this.productId,
    this.message,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      fileUrl: json['fileUrl'] as String?,
      filePath: json['filePath'] as String?,
      songId: json['songId'] as int?,
      productId: json['productId'] as int?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileUrl': fileUrl,
      'filePath': filePath,
      'songId': songId,
      'productId': productId,
      'message': message,
    };
  }
}

class ImageCompressionStats {
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final String message;

  ImageCompressionStats({
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.message,
  });

  factory ImageCompressionStats.fromJson(Map<String, dynamic> json) {
    return ImageCompressionStats(
      originalSize: json['originalSize'] as int,
      compressedSize: json['compressedSize'] as int,
      compressionRatio: (json['compressionRatio'] as num).toDouble(),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressionRatio': compressionRatio,
      'message': message,
    };
  }

  String get originalSizeFormatted => _formatBytes(originalSize);
  String get compressedSizeFormatted => _formatBytes(compressedSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
