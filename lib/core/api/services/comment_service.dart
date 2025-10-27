import '../api_client.dart';
import '../../models/comment.dart';

class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  CommentService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Create a new comment
  Future<ApiResponse<Comment>> createComment({
    required int userId,
    required String entityType,
    required int entityId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/comments',
        body: {
          'userId': userId,
          'entityType': entityType,
          'entityId': entityId,
          'content': content,
          if (parentCommentId != null) 'parentCommentId': parentCommentId,
        },
      );

      if (response.success && response.data != null) {
        final comment = Comment.fromJson(response.data);
        return ApiResponse.success(comment);
      }

      return ApiResponse.error(response.error ?? 'Failed to create comment');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get comments for an entity (song/album/artist)
  Future<ApiResponse<List<Comment>>> getEntityComments({
    required String entityType,
    required int entityId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/comments/entity/$entityType/$entityId',
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final comments = data.map((json) => Comment.fromJson(json)).toList();
        return ApiResponse.success(comments);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch comments');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get user's comments
  Future<ApiResponse<List<Comment>>> getUserComments(int userId) async {
    try {
      final response = await _apiClient.get('/api/comments/user/$userId');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final comments = data.map((json) => Comment.fromJson(json)).toList();
        return ApiResponse.success(comments);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch user comments');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Update a comment
  Future<ApiResponse<Comment>> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/comments/$commentId',
        body: {'content': content},
      );

      if (response.success && response.data != null) {
        final comment = Comment.fromJson(response.data);
        return ApiResponse.success(comment);
      }

      return ApiResponse.error(response.error ?? 'Failed to update comment');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Delete a comment
  Future<ApiResponse<void>> deleteComment(int commentId) async {
    try {
      final response = await _apiClient.delete('/api/comments/$commentId');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to delete comment');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Like a comment
  Future<ApiResponse<void>> likeComment(int commentId) async {
    try {
      final response = await _apiClient.post('/api/comments/$commentId/like');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to like comment');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Unlike a comment
  Future<ApiResponse<void>> unlikeComment(int commentId) async {
    try {
      final response = await _apiClient.delete('/api/comments/$commentId/like');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to unlike comment');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
