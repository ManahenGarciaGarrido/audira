import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de álbumes (Music Catalog Service)
class AlbumService {
  final DioClient _dioClient = DioClient();

  /// Crear nuevo álbum
  Future<Map<String, dynamic>> createAlbum({
    required String name,
    required String description,
    required String artistId,
    required double price,
    required DateTime releaseDate,
    List<String>? genreIds,
    double? discountPercentage,
    String? coverImagePath,
    ProgressCallback? onUploadProgress,
  }) async {
    try {
      if (coverImagePath != null) {
        final response = await _dioClient.uploadFile(
          ApiConfig.albums,
          coverImagePath,
          fileField: 'coverImage',
          data: {
            'name': name,
            'description': description,
            'artistId': artistId,
            'price': price,
            'releaseDate': releaseDate.toIso8601String(),
            if (genreIds != null) 'genreIds': genreIds,
            if (discountPercentage != null)
              'discountPercentage': discountPercentage,
          },
          onSendProgress: onUploadProgress,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Error creando álbum');
        }
      } else {
        final response = await _dioClient.post(
          ApiConfig.albums,
          data: {
            'name': name,
            'description': description,
            'artistId': artistId,
            'price': price,
            'releaseDate': releaseDate.toIso8601String(),
            if (genreIds != null) 'genreIds': genreIds,
            if (discountPercentage != null)
              'discountPercentage': discountPercentage,
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Error creando álbum');
        }
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener álbum por ID
  Future<Map<String, dynamic>> getAlbum(String albumId) async {
    try {
      final response = await _dioClient.get(ApiConfig.albumById(albumId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo álbum');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener todos los álbumes
  Future<List<Map<String, dynamic>>> getAllAlbums() async {
    try {
      final response = await _dioClient.get(ApiConfig.albums);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo álbumes');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener álbumes de un artista
  Future<List<Map<String, dynamic>>> getAlbumsByArtist(String artistId) async {
    try {
      final response = await _dioClient.get(ApiConfig.albumsByArtist(artistId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo álbumes del artista');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener álbumes por género
  Future<List<Map<String, dynamic>>> getAlbumsByGenre(String genreId) async {
    try {
      final response = await _dioClient.get(ApiConfig.albumsByGenre(genreId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo álbumes del género');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar álbum
  Future<Map<String, dynamic>> updateAlbum({
    required String albumId,
    String? name,
    String? description,
    double? price,
    DateTime? releaseDate,
    List<String>? genreIds,
    double? discountPercentage,
    String? coverImagePath,
    ProgressCallback? onUploadProgress,
  }) async {
    try {
      if (coverImagePath != null) {
        final response = await _dioClient.uploadFile(
          ApiConfig.albumById(albumId),
          coverImagePath,
          fileField: 'coverImage',
          data: {
            if (name != null) 'name': name,
            if (description != null) 'description': description,
            if (price != null) 'price': price,
            if (releaseDate != null) 'releaseDate': releaseDate.toIso8601String(),
            if (genreIds != null) 'genreIds': genreIds,
            if (discountPercentage != null)
              'discountPercentage': discountPercentage,
          },
          onSendProgress: onUploadProgress,
        );

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Error actualizando álbum');
        }
      } else {
        final data = <String, dynamic>{};
        if (name != null) data['name'] = name;
        if (description != null) data['description'] = description;
        if (price != null) data['price'] = price;
        if (releaseDate != null) data['releaseDate'] = releaseDate.toIso8601String();
        if (genreIds != null) data['genreIds'] = genreIds;
        if (discountPercentage != null) data['discountPercentage'] = discountPercentage;

        final response = await _dioClient.put(
          ApiConfig.albumById(albumId),
          data: data,
        );

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Error actualizando álbum');
        }
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Eliminar álbum
  Future<void> deleteAlbum(String albumId) async {
    try {
      final response = await _dioClient.delete(ApiConfig.albumById(albumId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error eliminando álbum');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener álbumes trending
  Future<List<Map<String, dynamic>>> getTrendingAlbums() async {
    try {
      final response = await _dioClient.get(ApiConfig.trendingAlbums);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo álbumes trending');
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
          return Exception('Álbum no encontrado');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
