// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../../config/constants.dart';
import '../models/user.dart';
import '../models/artist.dart';

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json;
    final role = userJson['role'] as String;

    User user;
    if (role == AppConstants.roleArtist) {
      user = Artist.fromJson(userJson);
    } else {
      user = User.fromJson(userJson);
    }

    return AuthResponse(
      token: json['token'] as String,
      user: user,
    );
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String username,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? artistName,
  }) async {
    try {
      final body = {
        'email': email,
        'username': username,
        'password': password,
        'role': role,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (artistName != null && role == AppConstants.roleArtist)
          'artistName': artistName,
      };

      final response = await _apiClient.post(
        AppConstants.authRegisterUrl,
        body: body,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final authResponse =
            AuthResponse.fromJson(response.data as Map<String, dynamic>);
        await _saveAuthData(authResponse);

        return ApiResponse(
          success: true,
          data: authResponse,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Error al registrar: $e',
      );
    }
  }

  Future<ApiResponse<AuthResponse>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final body = {
        'email': emailOrUsername,
        'password': password,
      };

      final response = await _apiClient.post(
        AppConstants.authLoginUrl,
        body: body,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final authResponse =
            AuthResponse.fromJson(response.data as Map<String, dynamic>);
        await _saveAuthData(authResponse);

        return ApiResponse(
          success: true,
          data: authResponse,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Error al iniciar sesión: $e',
      );
    }
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _storage.write(
      key: AppConstants.authTokenKey,
      value: authResponse.token,
    );
    await _storage.write(
      key: AppConstants.userIdKey,
      value: authResponse.user.id.toString(),
    );
    await _storage.write(
      key: AppConstants.userRoleKey,
      value: authResponse.user.role,
    );
    await _storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(authResponse.user.toJson()),
    );
  }

  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: AppConstants.userDataKey);
      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        final role = userJson['role'] as String;

        if (role == AppConstants.roleArtist) {
          return Artist.fromJson(userJson);
        }
        return User.fromJson(userJson);
      }
    } catch (e) {}
    return null;
  }

  Future<String?> getCurrentUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }

  Future<String?> getCurrentUserRole() async {
    return await _storage.read(key: AppConstants.userRoleKey);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.authTokenKey);
    await _storage.delete(key: AppConstants.userIdKey);
    await _storage.delete(key: AppConstants.userRoleKey);
    await _storage.delete(key: AppConstants.userDataKey);
  }

  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _apiClient.get(AppConstants.userProfileUrl);

      if (response.success && response.data != null) {
        final userJson = response.data as Map<String, dynamic>;
        final role = userJson['role'] as String;

        User user;
        if (role == AppConstants.roleArtist) {
          user = Artist.fromJson(userJson);
        } else {
          user = User.fromJson(userJson);
        }

        // Update stored user data
        await _storage.write(
          key: AppConstants.userDataKey,
          value: jsonEncode(user.toJson()),
        );

        return ApiResponse(
          success: true,
          data: user,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Error al obtener perfil: $e',
      );
    }
  }

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put(
        AppConstants.userProfileUrl,
        body: updates,
      );

      if (response.success && response.data != null) {
        final userJson = response.data as Map<String, dynamic>;
        final role = userJson['role'] as String;

        User user;
        if (role == AppConstants.roleArtist) {
          user = Artist.fromJson(userJson);
        } else {
          user = User.fromJson(userJson);
        }

        // Update stored user data
        await _storage.write(
          key: AppConstants.userDataKey,
          value: jsonEncode(user.toJson()),
        );

        return ApiResponse(
          success: true,
          data: user,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Error al actualizar perfil: $e',
      );
    }
  }
}
