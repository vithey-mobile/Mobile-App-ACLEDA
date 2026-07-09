import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/models/notification_page_result.dart';
import 'package:aub_connect_app/data/services/notification_service.dart';

class NotificationRepository extends GetxService {
  NotificationRepository(this._notificationService, this._flags);

  final NotificationService _notificationService;
  final FeatureFlags _flags;

  final unreadCount = 0.obs;
  final _items = <String, AppNotification>{};

  bool get useMockApi => _flags.useMockNotifications;

  @override
  void onInit() {
    super.onInit();
    if (useMockApi) {
      _seedMockData();
      _syncUnreadCount();
    }
  }

  Future<NotificationPageResult> fetchNotifications({
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
      final pageItems = list.skip(start).take(limit).toList();
      return NotificationPageResult(
        items: pageItems,
        hasMore: start + pageItems.length < list.length,
        total: list.length,
        unreadTotal: _items.values.where((n) => !n.isRead).length,
      );
    }

    final result = await _notificationService.fetchNotifications(
      page: page,
      limit: limit,
      unreadOnly: filter == NotificationFilter.unread,
    );
    _cacheItems(result.items);
    if (result.unreadTotal != null) {
      unreadCount.value = result.unreadTotal!;
    } else if (page == 1) {
      await reconcileUnreadCount();
    }
    return result;
  }

  Future<void> markAsRead(String notificationId) async {
    final item = _items[notificationId];
    if (item != null && item.isRead) return;

    AppNotification? previous;
    if (item != null) {
      previous = item;
      _items[notificationId] = item.copyWith(isRead: true);
      _syncUnreadCount();
    }

    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return;
    }

    try {
      await _notificationService.markRead(notificationId);
      if (item == null) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999999);
      }
    } catch (e) {
      if (previous != null) {
        _items[notificationId] = previous;
        _syncUnreadCount();
      }
      rethrow;
    }
  }

  Future<int> markAllAsRead() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      var updated = 0;
      for (final entry in _items.entries) {
        if (!entry.value.isRead) {
          _items[entry.key] = entry.value.copyWith(isRead: true);
          updated++;
        }
      }
      _syncUnreadCount();
      return updated;
    }

    final updated = await _notificationService.markAllRead();
    for (final entry in _items.entries) {
      if (!entry.value.isRead) {
        _items[entry.key] = entry.value.copyWith(isRead: true);
      }
    }
    unreadCount.value = 0;
    return updated;
  }

  Future<void> deleteNotification(String notificationId) async {
    final removed = _items.remove(notificationId);
    if (removed != null && !removed.isRead) {
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999999);
    } else {
      _syncUnreadCount();
    }

    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return;
    }

    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      if (removed != null) {
        _items[notificationId] = removed;
        _syncUnreadCount();
      }
      rethrow;
    }
  }

  AppNotification? getById(String id) => _items[id];

  void cacheNotification(AppNotification notification) => _cacheItems([notification]);

  Future<void> reconcileUnreadCount() async {
    if (useMockApi) {
      _syncUnreadCount();
      return;
    }
    unreadCount.value = await _notificationService.fetchUnreadCount();
  }

  Future<void> onUserAuthenticated() async {
    await reconcileUnreadCount();
  }

  Future<void> onAppResumed() async {
    await reconcileUnreadCount();
  }

  void clearSession() {
    _items.clear();
    unreadCount.value = 0;
  }

  void _cacheItems(List<AppNotification> items) {
    for (final item in items) {
      if (item.id.isEmpty) continue;
      _items[item.id] = item;
    }
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
        event: 'reaction.added',
        title: 'New like',
        body: 'Heng Liza liked your poster.',
        actor: const NotificationActor(id: 'author-1', fullName: 'Heng Liza'),
        destination: const NotificationDestination(postId: 'post-1', referenceType: 'POST'),
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.postComment,
        event: 'comment.added',
        title: 'New comment',
        body: 'Molika Khorn commented on your video.',
        actor: const NotificationActor(id: 'author-2', fullName: 'Molika Khorn'),
        destination: const NotificationDestination(postId: 'post-2', referenceType: 'POST'),
        createdAt: now.subtract(const Duration(minutes: 18)),
      ),
      AppNotification(
        id: 'n3',
        type: NotificationType.postShare,
        event: 'post.shared',
        title: 'Post shared',
        body: 'Sreynich Chan shared your post.',
        actor: const NotificationActor(id: 'author-4', fullName: 'Sreynich Chan'),
        destination: const NotificationDestination(postId: 'post-1', referenceType: 'POST'),
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      AppNotification(
        id: 'n4',
        type: NotificationType.newFollower,
        event: 'follow.created',
        title: 'New follower',
        body: 'Kimheang started following you.',
        actor: const NotificationActor(id: 'author-5', fullName: 'Kimheang'),
        destination: const NotificationDestination(userId: 'author-5', referenceType: 'USER'),
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'n5',
        type: NotificationType.jobApplicationReceived,
        event: 'job.application.submitted',
        title: 'New application',
        body: 'Sok Pisey applied for Marketing Intern.',
        actor: const NotificationActor(id: 'applicant-1', fullName: 'Sok Pisey'),
        destination: const NotificationDestination(
          jobPostId: 'post-3',
          applicationId: 'app-1',
          referenceType: 'JOB_APPLICATION',
        ),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'n6',
        type: NotificationType.chatMessage,
        event: 'chat.message.sent',
        title: 'New message',
        body: 'Heng Liza sent you a message.',
        actor: const NotificationActor(id: 'author-1', fullName: 'Heng Liza'),
        destination: const NotificationDestination(
          conversationId: 'conv-1',
          referenceType: 'CONVERSATION',
        ),
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      AppNotification(
        id: 'n7',
        type: NotificationType.aiAssistantResponse,
        event: 'ai.response.ready',
        title: 'AI response ready',
        body: 'Vithey AI finished your request.',
        destination: const NotificationDestination(aiThreadId: 'thread-1', referenceType: 'AI_THREAD'),
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: 'n8',
        type: NotificationType.paymentDue,
        event: 'payment.due',
        title: 'Payment due',
        body: 'Tuition Fee of \$450 is due in 14 days.',
        destination: const NotificationDestination(paymentId: 'pay-1', referenceType: 'PAYMENT'),
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      AppNotification(
        id: 'n9',
        type: NotificationType.jobApplicationStatus,
        event: 'job.application.status_changed',
        title: 'Application update',
        body: 'Your application for Marketing Intern is under review.',
        destination: const NotificationDestination(
          jobPostId: 'post-3',
          applicationId: 'app-2',
          referenceType: 'JOB_APPLICATION',
        ),
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 14)),
      ),
      AppNotification(
        id: 'n10',
        type: NotificationType.paymentOverdue,
        event: 'payment.overdue',
        title: 'Payment overdue',
        body: 'Your Lab Fee payment is overdue.',
        destination: const NotificationDestination(paymentId: 'pay-2', referenceType: 'PAYMENT'),
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'n11',
        type: NotificationType.system,
        event: 'system.announcement',
        title: 'System announcement',
        body: 'Vithey will undergo maintenance tonight at 11 PM.',
        destination: const NotificationDestination(routeName: '/settings'),
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      AppNotification(
        id: 'n12',
        type: NotificationType.studentVerification,
        event: 'student.verification.updated',
        title: 'Verification update',
        body: 'Your student verification is pending review.',
        destination: const NotificationDestination(routeName: '/verification-status'),
        isRead: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
    for (final item in mock) {
      _items[item.id] = item;
    }
  }
}
