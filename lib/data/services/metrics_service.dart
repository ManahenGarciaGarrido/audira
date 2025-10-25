import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de métricas y estadísticas (Community Service)
/// Gestiona métricas de artistas, canciones y usuarios
class MetricsService {
  final DioClient _dioClient = DioClient();

  // ==================== ARTIST METRICS ====================

  /// Obtener métricas de artista
  Future<Map<String, dynamic>> getArtistMetrics(String artistId) async {
    try {
      final response = await _dioClient.get(ApiConfig.artistMetrics(artistId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo métricas de artista');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Incrementar reproducciones de artista
  Future<Map<String, dynamic>> incrementArtistPlays(String artistId) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.incrementArtistPlays(artistId),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error incrementando reproducciones');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Incrementar oyentes únicos de artista
  Future<Map<String, dynamic>> incrementArtistListeners(String artistId) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.incrementArtistListeners(artistId),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error incrementando oyentes');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Incrementar seguidores de artista
  Future<Map<String, dynamic>> incrementArtistFollowers(String artistId) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.incrementArtistFollowers(artistId),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error incrementando seguidores');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Decrementar seguidores de artista
  Future<Map<String, dynamic>> decrementArtistFollowers(String artistId) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.decrementArtistFollowers(artistId),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error decrementando seguidores');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Registrar venta de artista
  Future<Map<String, dynamic>> recordArtistSale({
    required String artistId,
    required double amount,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.artistSales(artistId),
        data: {'amount': amount},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error registrando venta');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== SONG METRICS ====================

  /// Obtener métricas de canción
  Future<Map<String, dynamic>> getSongMetrics(String songId) async {
    try {
      final response = await _dioClient.get(ApiConfig.songMetrics(songId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo métricas de canción');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Incrementar reproducciones de canción
  Future<Map<String, dynamic>> incrementSongPlays(String songId) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.incrementSongPlays(songId),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error incrementando reproducciones');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== USER METRICS ====================

  /// Obtener métricas de usuario
  Future<Map<String, dynamic>> getUserMetrics(String userId) async {
    try {
      final response = await _dioClient.get(ApiConfig.userMetrics(userId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo métricas de usuario');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GLOBAL METRICS ====================

  /// Obtener métricas globales de la plataforma
  Future<Map<String, dynamic>> getGlobalMetrics() async {
    try {
      final response = await _dioClient.get(ApiConfig.globalMetrics);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo métricas globales');
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
          return Exception('Métrica no encontrada');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
