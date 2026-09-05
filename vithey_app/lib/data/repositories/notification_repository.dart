import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/services/notification_service.dart';

class NotificationRepository extends GetxService {
  NotificationRepository(this._notificationService);

  final NotificationService _notificationService;

  final unreadCount = 0.obs;
  final _items = <String, AppNotification>{};

  bool get useMockApi => dotenv.env['USE_MOCK_API']?.toLowerCase() != 'false';

  @override
  void onInit() {
    super.onInit();
    if (useMockApi) _seedMockData();
    _syncUnreadCount();
  }

  Future<List<AppNotification>> fetchNotifications({
    NotificationFilter filter = NotificationFilter.all,
    int page = 1,
    int limit = 20,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      var list = _items.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (filter == NotificationFilter.unread) {
        list = list.where((n) => !n.isRead).toList();
      }
      final start = (page - 1) * limit;
      return list.skip(start).take(limit).toList();
    }
    return [];
  }

  Future<void> markAsRead(String notificationId) async {
    final item = _items[notificationId];
    if (item == null || item.isRead) return;
    _items[notificationId] = item.copyWith(isRead: true);
    _syncUnreadCount();
    if (!useMockApi) {
      await _notificationService.markRead(notificationId);
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final item = _items.remove(notificationId);
    _syncUnreadCount();
    if (!useMockApi) {
      await _notificationService.deleteNotification(notificationId);
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (item != null && !item.isRead) {
      // count already synced
    }
  }

  AppNotification? getById(String id) => _items[id];

  Future<void> reconcileUnreadCount() async {
    if (useMockApi) {
      _syncUnreadCount();
      return;
    }
    unreadCount.value = await _notificationService.fetchUnreadCount();
  }

  void _syncUnreadCount() {
    unreadCount.value = _items.values.where((n) => !n.isRead).length;
  }

  void _seedMockData() {
    final now = DateTime.now();
    final mock = <AppNotification>[
      AppNotification(
        id: 'n1',
        type: NotificationType.postLike,
        title: 'New like',
        body: 'Heng Liza liked your poster.',
        actor: const NotificationActor(id: 'author-1', fullName: 'Heng Liza'),
        destination: const NotificationDestination(postId: 'post-1'),
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.postComment,
        title: 'New comment',
        body: 'Molika Khorn commented on your video.',
        actor: const NotificationActor(id: 'author-2', fullName: 'Molika Khorn'),
        destination: const NotificationDestination(postId: 'post-2'),
        createdAt: now.subtract(const Duration(minutes: 18)),
      ),
      AppNotification(
        id: 'n3',
        type: NotificationType.newFollower,
        title: 'New follower',
        body: 'Sreynich Chan started following you.',
        actor: const NotificationActor(id: 'author-4', fullName: 'Sreynich Chan'),
        destination: const NotificationDestination(userId: 'author-4'),
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'n4',
        type: NotificationType.jobApplicationReceived,
        title: 'New application',
        body: 'Sok Pisey applied for Marketing Intern.',
        actor: const NotificationActor(id: 'applicant-1', fullName: 'Sok Pisey'),
        destination: const NotificationDestination(jobPostId: 'post-3', applicationId: 'app-1'),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'n5',
        type: NotificationType.jobApplicationStatus,
        title: 'Application update',
        body: 'Your application for Marketing Intern is under review.',
        destination: const NotificationDestination(jobPostId: 'post-3', applicationId: 'app-2'),
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'n6',
        type: NotificationType.chatMessage,
        title: 'New message',
        body: 'Heng Liza sent you a message.',
        actor: const NotificationActor(id: 'author-1', fullName: 'Heng Liza'),
        destination: const NotificationDestination(conversationId: 'conv-1'),
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: 'n7',
        type: NotificationType.paymentDue,
        title: 'Payment due',
        body: 'Tuition Fee is due in 14 days.',
        destination: const NotificationDestination(paymentId: 'pay-1'),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'n8',
        type: NotificationType.studentVerification,
        title: 'Verification update',
        body: 'Your student verification is pending review.',
        destination: const NotificationDestination(routeName: '/verification-status'),
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
    for (final item in mock) {
      _items[item.id] = item;
    }
  }
}
