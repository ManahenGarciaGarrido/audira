import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de géneros musicales (Music Catalog Service)
class GenreService {
  final DioClient _dioClient = DioClient();

  /// Obtener todos los géneros
  Future<List<Map<String, dynamic>>> getAllGenres() async {
    try {
      final response = await _dioClient.get(ApiConfig.genres);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo géneros');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener género por ID
  Future<Map<String, dynamic>> getGenre(String genreId) async {
    try {
      final response = await _dioClient.get(ApiConfig.genreById(genreId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo género');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Crear nuevo género (solo admin)
  Future<Map<String, dynamic>> createGenre({
    required String name,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.genres,
        data: {'name': name},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error creando género');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar género (solo admin)
  Future<Map<String, dynamic>> updateGenre({
    required String genreId,
    required String name,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.genreById(genreId),
        data: {'name': name},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error actualizando género');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Eliminar género (solo admin)
  Future<void> deleteGenre(String genreId) async {
    try {
      final response = await _dioClient.delete(ApiConfig.genreById(genreId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error eliminando género');
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
          return Exception('Género no encontrado');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
