import '../api_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get user's notifications
  Future<ApiResponse<List<dynamic>>> getUserNotifications(int userId) async {
    try {
      final response = await _apiClient.get('/api/notifications/user/$userId');

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as List<dynamic>);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch notifications');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get unread notifications count
  Future<ApiResponse<int>> getUnreadCount(int userId) async {
    try {
      final response = await _apiClient.get('/api/notifications/user/$userId/unread/count');

      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as int);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch unread count');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Mark notification as read
  Future<ApiResponse<void>> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.patch('/api/notifications/$notificationId/read');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to mark notification as read');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Mark all notifications as read
  Future<ApiResponse<void>> markAllAsRead(int userId) async {
    try {
      final response = await _apiClient.patch('/api/notifications/user/$userId/read-all');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to mark all notifications as read');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Delete notification
  Future<ApiResponse<void>> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.delete('/api/notifications/$notificationId');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to delete notification');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Delete all notifications for user
  Future<ApiResponse<void>> deleteAllNotifications(int userId) async {
    try {
      final response = await _apiClient.delete('/api/notifications/user/$userId');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to delete all notifications');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
