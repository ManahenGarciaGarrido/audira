import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de autenticación
/// Gestiona login, registro, logout y tokens JWT
class AuthService {
  final DioClient _dioClient = DioClient();

  /// Registrar nuevo usuario
  ///
  /// Returns: Usuario registrado con token JWT
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role, // 'USER', 'ARTIST', 'ADMIN'
    DateTime? birthDate,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.authRegister,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role.toUpperCase(),
          if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Guardar token
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }

        // Guardar user ID
        if (data['id'] != null || data['userId'] != null) {
          final userId = data['id'] ?? data['userId'];
          await _saveUserId(userId.toString());
        }

        return data;
      } else {
        throw Exception('Error en registro: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Login de usuario
  ///
  /// Returns: Usuario autenticado con token JWT
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Guardar token
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }

        // Guardar user ID
        if (data['id'] != null || data['userId'] != null) {
          final userId = data['id'] ?? data['userId'];
          await _saveUserId(userId.toString());
        }

        return data;
      } else {
        throw Exception('Error en login: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout - Limpiar tokens y datos locales
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConfig.tokenKey);
      await prefs.remove(ApiConfig.refreshTokenKey);
      await prefs.remove(ApiConfig.userIdKey);
    } catch (e) {
      print('Error en logout: $e');
      rethrow;
    }
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConfig.tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtener token actual
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(ApiConfig.tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Obtener user ID actual
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(ApiConfig.userIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Guardar token en local storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);
  }

  /// Guardar user ID en local storage
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.userIdKey, userId);
  }

  /// Manejo de errores de Dio
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      switch (statusCode) {
        case 400:
          return Exception('Datos inválidos: ${data['message'] ?? 'Error de validación'}');
        case 401:
          return Exception('Credenciales incorrectas');
        case 403:
          return Exception('Acceso denegado');
        case 404:
          return Exception('Usuario no encontrado');
        case 409:
          return Exception('El usuario ya existe');
        case 500:
          return Exception('Error del servidor');
        default:
          return Exception('Error: ${data['message'] ?? e.message}');
      }
    } else {
      // Error de red
      return Exception('Error de conexión: ${e.message}');
    }
  }
}
