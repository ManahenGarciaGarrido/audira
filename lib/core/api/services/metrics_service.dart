import '../api_client.dart';

class MetricsService {
  static final MetricsService _instance = MetricsService._internal();
  factory MetricsService() => _instance;
  MetricsService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get user metrics/statistics
  Future<ApiResponse<Map<String, dynamic>>> getUserMetrics(int userId) async {
    try {
      final response = await _apiClient.get('/api/metrics/users/$userId');

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch user metrics');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get artist metrics/statistics
  Future<ApiResponse<Map<String, dynamic>>> getArtistMetrics(int artistId) async {
    try {
      final response = await _apiClient.get('/api/metrics/artists/$artistId');

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch artist metrics');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get song metrics/statistics
  Future<ApiResponse<Map<String, dynamic>>> getSongMetrics(int songId) async {
    try {
      final response = await _apiClient.get('/api/metrics/songs/$songId');

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch song metrics');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get global platform metrics/statistics
  Future<ApiResponse<Map<String, dynamic>>> getGlobalMetrics() async {
    try {
      final response = await _apiClient.get('/api/metrics/global');

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch global metrics');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get top songs
  Future<ApiResponse<List<dynamic>>> getTopSongs({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/metrics/songs/top',
        queryParams: {'limit': limit.toString()},
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as List<dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch top songs');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get top artists
  Future<ApiResponse<List<dynamic>>> getTopArtists({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/metrics/artists/top',
        queryParams: {'limit': limit.toString()},
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as List<dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch top artists');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get user listening history with metrics
  Future<ApiResponse<List<dynamic>>> getUserListeningHistory(
    int userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '/api/metrics/users/$userId/history',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as List<dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch listening history');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get artist's top songs
  Future<ApiResponse<List<dynamic>>> getArtistTopSongs(
    int artistId, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/metrics/artists/$artistId/top-songs',
        queryParams: {'limit': limit.toString()},
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as List<dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch artist top songs');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
