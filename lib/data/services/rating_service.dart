import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de calificaciones (Community Service)
class RatingService {
  final DioClient _dioClient = DioClient();

  /// Crear o actualizar calificación
  ///
  /// entityType: 'song', 'album', 'artist', etc.
  Future<Map<String, dynamic>> createOrUpdateRating({
    required String userId,
    required String entityType,
    required String entityId,
    required double rating, // 1.0 - 5.0
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.ratings,
        data: {
          'userId': userId,
          'entityType': entityType,
          'entityId': entityId,
          'rating': rating,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error creando calificación');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener calificaciones de un usuario
  Future<List<Map<String, dynamic>>> getRatingsByUser(String userId) async {
    try {
      final response = await _dioClient.get(ApiConfig.ratingsByUser(userId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo calificaciones del usuario');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener calificaciones de una entidad
  Future<List<Map<String, dynamic>>> getRatingsByEntity({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.ratingsByEntity(entityType, entityId),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo calificaciones de la entidad');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener promedio de calificación de una entidad
  Future<Map<String, dynamic>> getRatingAverage({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.ratingsAverage(entityType, entityId),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo promedio de calificación');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener calificación específica del usuario para una entidad
  Future<Map<String, dynamic>?> getUserEntityRating({
    required String userId,
    required String entityType,
    required String entityId,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.userEntityRating(userId, entityType, entityId),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        return null; // Usuario no ha calificado esta entidad
      } else {
        throw Exception('Error obteniendo calificación');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  /// Eliminar calificación
  Future<void> deleteRating(String ratingId) async {
    try {
      final response = await _dioClient.delete(ApiConfig.deleteRating(ratingId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error eliminando calificación');
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
          return Exception('Calificación no encontrada');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
