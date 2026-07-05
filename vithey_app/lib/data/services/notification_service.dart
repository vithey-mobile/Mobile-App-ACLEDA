import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';

class NotificationService {
  NotificationService(this._api);

  final ApiService _api;

  Future<int> fetchUnreadCount() async {
    final response = await _api.get<int>(
      ApiEndpoints.notificationsUnreadCount,
      fromJson: (json) {
        final data = json as Map<String, dynamic>? ?? {};
        return data['count'] as int? ?? data['unread_count'] as int? ?? 0;
      },
    );
    if (!response.isSuccess || response.data == null) return 0;
    return response.data!;
  }

  Future<void> markRead(String notificationId) async {
    final response = await _api.patch<void>(
      ApiEndpoints.notificationRead(notificationId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw NotificationServiceException(response.error?.message ?? 'Failed to mark read');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final response = await _api.delete<void>(
      ApiEndpoints.notificationById(notificationId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw NotificationServiceException(response.error?.message ?? 'Failed to delete');
    }
  }
}

class NotificationServiceException implements Exception {
  NotificationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
