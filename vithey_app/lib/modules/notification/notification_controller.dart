import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/push/notification_router.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/modules/notification/utils/notification_display_text.dart';
import 'package:aub_connect_app/modules/notification/utils/notification_grouping.dart';
import 'package:aub_connect_app/modules/notification/widgets/delete_notification_dialog.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_action_sheet.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class NotificationController extends GetxController {
  NotificationController(this._repository);

  final NotificationRepository _repository;

  final filter = NotificationFilter.all.obs;
  final notifications = <AppNotification>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isRefreshing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final mutatingIds = <String>{}.obs;

  int _page = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    _repository.reconcileUnreadCount();
  }

  List<NotificationSection> get sections => groupNotifications(notifications);

  Future<void> loadNotifications() async {
    isLoading.value = true;
    hasError.value = false;
    _page = 1;
    _hasMore = true;
    try {
      final result = await _repository.fetchNotifications(filter: filter.value, page: _page);
      notifications.assignAll(result.items);
      _hasMore = result.hasMore;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;
    isLoadingMore.value = true;
    try {
      final nextPage = _page + 1;
      final result = await _repository.fetchNotifications(
        filter: filter.value,
        page: nextPage,
      );
      if (result.items.isEmpty) {
        _hasMore = false;
        return;
      }
      final existingIds = notifications.map((n) => n.id).toSet();
      for (final item in result.items) {
        if (!existingIds.contains(item.id)) notifications.add(item);
      }
      _page = nextPage;
      _hasMore = result.hasMore;
    } catch (_) {
      // Keep loaded rows; pagination retry on next scroll
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    isRefreshing.value = true;
    try {
      await loadNotifications();
      await _repository.reconcileUnreadCount();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> selectFilter(NotificationFilter value) async {
    if (filter.value == value) return;
    filter.value = value;
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      if (filter.value == NotificationFilter.unread) {
        notifications.clear();
      } else {
        notifications.assignAll(notifications.map((n) => n.copyWith(isRead: true)).toList());
      }
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not mark all as read');
    }
  }

  Future<void> openNotification(String notificationId) async {
    final item = _repository.getById(notificationId) ??
        notifications.firstWhereOrNull((n) => n.id == notificationId);
    if (item == null) return;
    if (!item.isRead) await markAsRead(notificationId, closeSheet: false);
    NotificationRouter.routeToNotification(item);
  }

  void openActionSheet(AppNotification notification) {
    Get.bottomSheet<void>(
      NotificationActionSheet(
        notification: notification,
        previewText: NotificationDisplayText.build(notification),
        onMarkRead: notification.isRead ? null : () => markAsRead(notification.id),
        onDelete: () => requestDelete(notification.id),
      ),
      isScrollControlled: true,
      backgroundColor: Get.context!.scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> markAsRead(String notificationId, {bool closeSheet = true}) async {
    if (mutatingIds.contains(notificationId)) return;
    mutatingIds.add(notificationId);
    try {
      await _repository.markAsRead(notificationId);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        if (filter.value == NotificationFilter.unread) {
          notifications.removeAt(index);
        }
      }
      if (closeSheet && Get.isBottomSheetOpen == true) Get.back();
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not mark as read');
    } finally {
      mutatingIds.remove(notificationId);
    }
  }

  Future<void> requestDelete(String notificationId) async {
    if (Get.isBottomSheetOpen == true) Get.back();
    final confirmed = await DeleteNotificationDialog.show();
    if (confirmed != true) return;
    if (mutatingIds.contains(notificationId)) return;
    mutatingIds.add(notificationId);
    try {
      await _repository.deleteNotification(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not delete notification');
    } finally {
      mutatingIds.remove(notificationId);
    }
  }
}
