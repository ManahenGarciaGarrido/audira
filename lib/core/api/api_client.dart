import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../config/constants.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({required this.success, this.data, this.error, this.statusCode});

  void operator [](String other) {}
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  final String baseUrl = AppConstants.apiGatewayUrl;

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }

  Map<String, String> _getHeaders({bool includeAuth = true, String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await _getAuthToken();
        if (token == null) {
          return ApiResponse(
            success: false,
            error: AppConstants.errorUnauthorizedMessage,
            statusCode: 401,
          );
        }
      }

      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: _getHeaders(includeAuth: requiresAuth, token: token),
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: '${AppConstants.errorNetworkMessage}: $e',
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await _getAuthToken();
        if (token == null) {
          return ApiResponse(
            success: false,
            error: AppConstants.errorUnauthorizedMessage,
            statusCode: 401,
          );
        }
      }

      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await http.post(
        uri,
        headers: _getHeaders(includeAuth: requiresAuth, token: token),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: '${AppConstants.errorNetworkMessage}: $e',
      );
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await _getAuthToken();
        if (token == null) {
          return ApiResponse(
            success: false,
            error: AppConstants.errorUnauthorizedMessage,
            statusCode: 401,
          );
        }
      }

      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await http.put(
        uri,
        headers: _getHeaders(includeAuth: requiresAuth, token: token),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: '${AppConstants.errorNetworkMessage}: $e',
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await _getAuthToken();
        if (token == null) {
          return ApiResponse(
            success: false,
            error: AppConstants.errorUnauthorizedMessage,
            statusCode: 401,
          );
        }
      }

      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await http.delete(
        uri,
        headers: _getHeaders(includeAuth: requiresAuth, token: token),
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: '${AppConstants.errorNetworkMessage}: $e',
      );
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await _getAuthToken();
        if (token == null) {
          return ApiResponse(
            success: false,
            error: AppConstants.errorUnauthorizedMessage,
            statusCode: 401,
          );
        }
      }

      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await http.patch(
        uri,
        headers: _getHeaders(includeAuth: requiresAuth, token: token),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: '${AppConstants.errorNetworkMessage}: $e',
      );
    }
  }

  /// Upload file with multipart/form-data
  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required File file,
    required String fileFieldName,
    Map<String, String>? fields,
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
    String? contentType,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await _getAuthToken();
        if (token == null) {
          return ApiResponse(
            success: false,
            error: AppConstants.errorUnauthorizedMessage,
            statusCode: 401,
          );
        }
      }

      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final request = http.MultipartRequest('POST', uri);

      // Add auth header if needed
      if (requiresAuth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add the file
      final mimeType = contentType ?? _getMimeType(file.path);
      final mimeTypeData = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      // Add additional fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: '${AppConstants.errorNetworkMessage}: $e',
      );
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();

    // Audio types
    if (ext == 'mp3') return 'audio/mpeg';
    if (ext == 'wav') return 'audio/wav';
    if (ext == 'flac') return 'audio/flac';
    if (ext == 'midi' || ext == 'mid') return 'audio/midi';
    if (ext == 'ogg') return 'audio/ogg';
    if (ext == 'aac') return 'audio/aac';

    // Image types
    if (ext == 'jpg' || ext == 'jpeg') return 'image/jpeg';
    if (ext == 'png') return 'image/png';
    if (ext == 'gif') return 'image/gif';
    if (ext == 'webp') return 'image/webp';

    return 'application/octet-stream';
  }

  ApiResponse<T> _handleResponse<T>(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        final data =
            response.body.isNotEmpty ? jsonDecode(response.body) : null;
        return ApiResponse(
          success: true,
          data: data as T?,
          statusCode: statusCode,
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          error: 'Error al parsear respuesta: $e',
          statusCode: statusCode,
        );
      }
    } else if (statusCode == 401) {
      return ApiResponse(
        success: false,
        error: AppConstants.errorUnauthorizedMessage,
        statusCode: statusCode,
      );
    } else if (statusCode >= 500) {
      return ApiResponse(
        success: false,
        error: AppConstants.errorServerMessage,
        statusCode: statusCode,
      );
    } else {
      String errorMessage = AppConstants.errorUnknownMessage;
      try {
        final errorData = jsonDecode(response.body);
        errorMessage =
            errorData['message'] ?? errorData['error'] ?? errorMessage;
      } catch (e) {
        // Si no se puede parsear el error, usar el mensaje por defecto
      }
      return ApiResponse(
        success: false,
        error: errorMessage,
        statusCode: statusCode,
      );
    }
  }
}
