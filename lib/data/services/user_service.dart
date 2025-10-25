import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de usuarios (Community Service)
/// Gestiona perfiles de usuarios
class UserService {
  final DioClient _dioClient = DioClient();

  /// Obtener perfil del usuario actual
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      final response = await _dioClient.get(ApiConfig.userProfile);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo perfil');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener perfil de usuario por ID
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dioClient.get(ApiConfig.userById(userId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo perfil');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar perfil del usuario
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? username,
    String? profileImage,
    DateTime? birthDate,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (username != null) data['username'] = username;
      if (profileImage != null) data['profileImage'] = profileImage;
      if (birthDate != null) data['birthDate'] = birthDate.toIso8601String();

      final response = await _dioClient.put(
        ApiConfig.userProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error actualizando perfil');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener todos los usuarios (solo admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _dioClient.get(ApiConfig.allUsers);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo usuarios');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Manejo de errores
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      switch (statusCode) {
        case 400:
          return Exception('Datos inválidos');
        case 401:
          return Exception('No autorizado');
        case 403:
          return Exception('Acceso denegado');
        case 404:
          return Exception('Usuario no encontrado');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
