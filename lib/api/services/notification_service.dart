import '../client/api_client.dart';
import '../constants/api_constants.dart';
import '../../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  // Get Notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.customerNotifications,
        requiresAuth: true,
      );

      final List<dynamic> notificationsJson =
          response['data'] ?? response['notifications'] ?? [];
      return notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Mark Notification as Read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.post(
        '${ApiConstants.markNotificationRead}/$notificationId',
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Mark All Notifications as Read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.post(
        ApiConstants.markAllNotificationsRead,
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
