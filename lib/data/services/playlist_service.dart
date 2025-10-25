import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de playlists (Playback Service)
class PlaylistService {
  final DioClient _dioClient = DioClient();

  /// Crear nueva playlist
  Future<Map<String, dynamic>> createPlaylist({
    required String name,
    required String description,
    required String userId,
    required bool isPublic,
    List<String>? songIds,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.playlists,
        data: {
          'name': name,
          'description': description,
          'userId': userId,
          'isPublic': isPublic,
          if (songIds != null) 'songIds': songIds,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error creando playlist');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener playlist por ID
  Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    try {
      final response = await _dioClient.get(ApiConfig.playlistById(playlistId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo playlist');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener todas las playlists
  Future<List<Map<String, dynamic>>> getAllPlaylists() async {
    try {
      final response = await _dioClient.get(ApiConfig.playlists);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo playlists');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener playlists de un usuario
  Future<List<Map<String, dynamic>>> getPlaylistsByUser(String userId) async {
    try {
      final response = await _dioClient.get(ApiConfig.playlistsByUser(userId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo playlists del usuario');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener playlists públicas
  Future<List<Map<String, dynamic>>> getPublicPlaylists() async {
    try {
      final response = await _dioClient.get(ApiConfig.publicPlaylists);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo playlists públicas');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar playlist
  Future<Map<String, dynamic>> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (isPublic != null) data['isPublic'] = isPublic;

      final response = await _dioClient.put(
        ApiConfig.playlistById(playlistId),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error actualizando playlist');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Eliminar playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      final response = await _dioClient.delete(ApiConfig.playlistById(playlistId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error eliminando playlist');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Añadir canción a playlist
  Future<Map<String, dynamic>> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.addSongToPlaylist(playlistId),
        data: {'songId': songId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Error añadiendo canción a playlist');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Eliminar canción de playlist
  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final response = await _dioClient.delete(
        ApiConfig.removeSongFromPlaylist(playlistId, songId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error eliminando canción de playlist');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reordenar canciones en playlist
  Future<Map<String, dynamic>> reorderPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.reorderPlaylist(playlistId),
        data: {'songIds': songIds},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error reordenando playlist');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener canciones de una playlist
  Future<List<Map<String, dynamic>>> getPlaylistSongs(String playlistId) async {
    try {
      final response = await _dioClient.get(ApiConfig.playlistSongs(playlistId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo canciones de playlist');
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
          return Exception('Playlist no encontrada');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
