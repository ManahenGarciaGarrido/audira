import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de canciones (Music Catalog Service)
/// CRUD de canciones y búsqueda
class SongService {
  final DioClient _dioClient = DioClient();

  /// Crear nueva canción
  ///
  /// Parámetros:
  /// - audioFile: Ruta del archivo de audio
  /// - coverImage: Ruta de la imagen de portada (opcional)
  Future<Map<String, dynamic>> createSong({
    required String name,
    required String description,
    required String artistId,
    required double price,
    required int duration, // en segundos
    String? audioUrl,
    String? lyrics,
    int? trackNumber,
    String? albumId,
    List<String>? genreIds,
    String? audioFilePath,
    String? coverImagePath,
    ProgressCallback? onUploadProgress,
  }) async {
    try {
      // Si hay archivos, usar multipart/form-data
      if (audioFilePath != null || coverImagePath != null) {
        final filePaths = <String, String>{};
        if (audioFilePath != null) filePaths['audioFile'] = audioFilePath;
        if (coverImagePath != null) filePaths['coverImage'] = coverImagePath;

        final response = await _dioClient.uploadFiles(
          ApiConfig.songs,
          filePaths,
          data: {
            'name': name,
            'description': description,
            'artistId': artistId,
            'price': price,
            'duration': duration,
            if (audioUrl != null) 'audioUrl': audioUrl,
            if (lyrics != null) 'lyrics': lyrics,
            if (trackNumber != null) 'trackNumber': trackNumber,
            if (albumId != null) 'albumId': albumId,
            if (genreIds != null) 'genreIds': genreIds,
          },
          onSendProgress: onUploadProgress,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Error creando canción');
        }
      } else {
        // Sin archivos, usar JSON
        final response = await _dioClient.post(
          ApiConfig.songs,
          data: {
            'name': name,
            'description': description,
            'artistId': artistId,
            'price': price,
            'duration': duration,
            if (audioUrl != null) 'audioUrl': audioUrl,
            if (lyrics != null) 'lyrics': lyrics,
            if (trackNumber != null) 'trackNumber': trackNumber,
            if (albumId != null) 'albumId': albumId,
            if (genreIds != null) 'genreIds': genreIds,
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Error creando canción');
        }
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener canción por ID
  Future<Map<String, dynamic>> getSong(String songId) async {
    try {
      final response = await _dioClient.get(ApiConfig.songById(songId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo canción');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener todas las canciones
  Future<List<Map<String, dynamic>>> getAllSongs() async {
    try {
      final response = await _dioClient.get(ApiConfig.songs);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo canciones');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener canciones de un artista
  Future<List<Map<String, dynamic>>> getSongsByArtist(String artistId) async {
    try {
      final response = await _dioClient.get(ApiConfig.songsByArtist(artistId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo canciones del artista');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener canciones de un álbum
  Future<List<Map<String, dynamic>>> getSongsByAlbum(String albumId) async {
    try {
      final response = await _dioClient.get(ApiConfig.songsByAlbum(albumId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo canciones del álbum');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener canciones de un género
  Future<List<Map<String, dynamic>>> getSongsByGenre(String genreId) async {
    try {
      final response = await _dioClient.get(ApiConfig.songsByGenre(genreId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo canciones del género');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Buscar canciones
  Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.searchSongs,
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error buscando canciones');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar canción
  Future<Map<String, dynamic>> updateSong({
    required String songId,
    String? name,
    String? description,
    double? price,
    int? duration,
    String? audioUrl,
    String? lyrics,
    int? trackNumber,
    String? albumId,
    List<String>? genreIds,
    String? coverImagePath,
    ProgressCallback? onUploadProgress,
  }) async {
    try {
      if (coverImagePath != null) {
        // Con imagen, usar multipart
        final response = await _dioClient.uploadFile(
          ApiConfig.songById(songId),
          coverImagePath,
          fileField: 'coverImage',
          data: {
            if (name != null) 'name': name,
            if (description != null) 'description': description,
            if (price != null) 'price': price,
            if (duration != null) 'duration': duration,
            if (audioUrl != null) 'audioUrl': audioUrl,
            if (lyrics != null) 'lyrics': lyrics,
            if (trackNumber != null) 'trackNumber': trackNumber,
            if (albumId != null) 'albumId': albumId,
            if (genreIds != null) 'genreIds': genreIds,
          },
          onSendProgress: onUploadProgress,
        );

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Error actualizando canción');
        }
      } else {
        // Sin imagen, usar JSON
        final data = <String, dynamic>{};
        if (name != null) data['name'] = name;
        if (description != null) data['description'] = description;
        if (price != null) data['price'] = price;
        if (duration != null) data['duration'] = duration;
        if (audioUrl != null) data['audioUrl'] = audioUrl;
        if (lyrics != null) data['lyrics'] = lyrics;
        if (trackNumber != null) data['trackNumber'] = trackNumber;
        if (albumId != null) data['albumId'] = albumId;
        if (genreIds != null) data['genreIds'] = genreIds;

        final response = await _dioClient.put(
          ApiConfig.songById(songId),
          data: data,
        );

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Error actualizando canción');
        }
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Eliminar canción
  Future<void> deleteSong(String songId) async {
    try {
      final response = await _dioClient.delete(ApiConfig.songById(songId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error eliminando canción');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener canciones trending
  Future<List<Map<String, dynamic>>> getTrendingSongs() async {
    try {
      final response = await _dioClient.get(ApiConfig.trendingSongs);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo canciones trending');
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
          return Exception('Canción no encontrada');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
