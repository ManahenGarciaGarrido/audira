import '../api_client.dart';
import '../../../config/constants.dart';
import '../../models/playlist.dart';

class PlaylistService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<Playlist>>> getUserPlaylists(int userId) async {
    final response = await _apiClient.get('${AppConstants.playlistsUrl}/user/$userId');
    if (response.success && response.data != null) {
      final playlists = (response.data as List).map((json) => Playlist.fromJson(json)).toList();
      return ApiResponse(success: true, data: playlists);
    }
    return ApiResponse(success: false, error: response.error);
  }

  Future<ApiResponse<Playlist>> getPlaylistById(int id) async {
    final response = await _apiClient.get('${AppConstants.playlistsUrl}/$id');
    if (response.success && response.data != null) {
      return ApiResponse(success: true, data: Playlist.fromJson(response.data));
    }
    return ApiResponse(success: false, error: response.error);
  }

  Future<ApiResponse<Playlist>> createPlaylist(Map<String, dynamic> playlistData) async {
    final response = await _apiClient.post(AppConstants.playlistsUrl, body: playlistData);
    if (response.success && response.data != null) {
      return ApiResponse(success: true, data: Playlist.fromJson(response.data));
    }
    return ApiResponse(success: false, error: response.error);
  }

  Future<ApiResponse<Playlist>> addSongToPlaylist(int playlistId, int songId) async {
    final response = await _apiClient.post(
      '${AppConstants.playlistsUrl}/$playlistId/songs',
      queryParameters: {'songId': songId.toString()},
    );
    if (response.success && response.data != null) {
      return ApiResponse(success: true, data: Playlist.fromJson(response.data));
    }
    return ApiResponse(success: false, error: response.error);
  }

  Future<ApiResponse<void>> removeSongFromPlaylist(int playlistId, int songId) async {
    return await _apiClient.delete('${AppConstants.playlistsUrl}/$playlistId/songs/$songId');
  }

  Future<ApiResponse<void>> deletePlaylist(int playlistId) async {
    return await _apiClient.delete('${AppConstants.playlistsUrl}/$playlistId');
  }
}
