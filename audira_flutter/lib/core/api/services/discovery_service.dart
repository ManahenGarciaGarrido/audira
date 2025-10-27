import '../api_client.dart';
import '../../models/song.dart';
import '../../models/album.dart';

class DiscoveryService {
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Search songs
  Future<ApiResponse<List<Song>>> searchSongs(String query) async {
    try {
      final response = await _apiClient.get(
        '/api/discovery/search/songs',
        queryParams: {'query': query},
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final songs = data.map((json) => Song.fromJson(json)).toList();
        return ApiResponse.success(songs);
      }

      return ApiResponse.error(response.error ?? 'Failed to search songs');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Search albums
  Future<ApiResponse<List<Album>>> searchAlbums(String query) async {
    try {
      final response = await _apiClient.get(
        '/api/discovery/search/albums',
        queryParams: {'query': query},
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final albums = data.map((json) => Album.fromJson(json)).toList();
        return ApiResponse.success(albums);
      }

      return ApiResponse.error(response.error ?? 'Failed to search albums');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get trending songs
  Future<ApiResponse<List<Song>>> getTrendingSongs({int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '/api/discovery/trending/songs',
        queryParams: {'limit': limit.toString()},
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final songs = data.map((json) => Song.fromJson(json)).toList();
        return ApiResponse.success(songs);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch trending songs');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get trending albums
  Future<ApiResponse<List<Album>>> getTrendingAlbums({int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '/api/discovery/trending/albums',
        queryParams: {'limit': limit.toString()},
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final albums = data.map((json) => Album.fromJson(json)).toList();
        return ApiResponse.success(albums);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch trending albums');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get recommendations for user
  Future<ApiResponse<Map<String, dynamic>>> getRecommendations(int userId) async {
    try {
      final response = await _apiClient.get(
        '/api/discovery/recommendations',
        queryParams: {'userId': userId.toString()},
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch recommendations');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
