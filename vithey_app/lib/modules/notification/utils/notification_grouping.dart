import 'package:aub_connect_app/data/models/app_notification_model.dart';

class NotificationSection {
  const NotificationSection({required this.title, required this.items});

  final String title;
  final List<AppNotification> items;
}

/// Groups notifications Facebook-style for the All filter.
List<NotificationSection> groupNotifications(List<AppNotification> notifications) {
  if (notifications.isEmpty) return [];

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final yesterdayStart = todayStart.subtract(const Duration(days: 1));

  final newItems = <AppNotification>[];
  final todayItems = <AppNotification>[];
  final yesterdayItems = <AppNotification>[];
  final earlierItems = <AppNotification>[];

  for (final notification in notifications) {
    if (!notification.isRead) {
      newItems.add(notification);
      continue;
    }
    final day = DateTime(
      notification.createdAt.year,
      notification.createdAt.month,
      notification.createdAt.day,
    );
    if (!day.isBefore(todayStart)) {
      todayItems.add(notification);
    } else if (!day.isBefore(yesterdayStart)) {
      yesterdayItems.add(notification);
    } else {
      earlierItems.add(notification);
    }
  }

  final sections = <NotificationSection>[];
  if (newItems.isNotEmpty) sections.add(NotificationSection(title: 'New', items: newItems));
  if (todayItems.isNotEmpty) sections.add(NotificationSection(title: 'Today', items: todayItems));
  if (yesterdayItems.isNotEmpty) {
    sections.add(NotificationSection(title: 'Yesterday', items: yesterdayItems));
  }
  if (earlierItems.isNotEmpty) sections.add(NotificationSection(title: 'Earlier', items: earlierItems));
  return sections;
}
