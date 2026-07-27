import 'dart:async';

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
  final paginationError = false.obs;
  final mutatingIds = <String>{}.obs;
  final scrollController = ScrollController();

  /// 1 when the user moved to a tab on the right, -1 for the left.
  /// Drives the direction of the list entrance animation.
  int slideDirection = 1;

  int _page = 1;
  bool _hasMore = true;
  final _filterStates = <NotificationFilter, _NotificationFilterState>{
    for (final value in NotificationFilter.values)
      value: _NotificationFilterState(),
  };

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    _repository.reconcileUnreadCount();
  }

  List<NotificationSection> get sections => groupNotifications(notifications);

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadNotifications() async {
    final requestedFilter = filter.value;
    isLoading.value = true;
    hasError.value = false;
    paginationError.value = false;
    _page = 1;
    _hasMore = true;
    try {
      final result = await _repository.fetchNotifications(
        filter: requestedFilter,
        page: _page,
      );
      final state = _filterStates[requestedFilter]!;
      state
        ..items = result.items.toList()
        ..page = 1
        ..hasMore = result.hasMore
        ..loaded = true;
      if (filter.value != requestedFilter) return;
      notifications.assignAll(result.items);
      _hasMore = result.hasMore;
    } catch (e) {
      if (filter.value == requestedFilter) {
        hasError.value = true;
        errorMessage.value = e.toString();
      }
    } finally {
      if (filter.value == requestedFilter) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;
    isLoadingMore.value = true;
    paginationError.value = false;
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
        if (existingIds.add(item.id)) notifications.add(item);
      }
      _page = nextPage;
      _hasMore = result.hasMore;
      _saveCurrentState();
    } catch (_) {
      paginationError.value = true;
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
    slideDirection = NotificationFilter.values.indexOf(value) >
            NotificationFilter.values.indexOf(filter.value)
        ? 1
        : -1;
    _saveCurrentState();
    final state = _filterStates[value]!;
    if (state.loaded) {
      // Swap filter and items in the same synchronous frame so the screen
      // renders the new tab's content directly — no flash of old content.
      filter.value = value;
      notifications.assignAll(state.items);
      _page = state.page;
      _hasMore = state.hasMore;
      hasError.value = false;
      paginationError.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpTo(state.scrollOffset);
      });
      return;
    }
    // Unloaded tab: clear the old tab's items first so skeletons show while
    // fetching, instead of the previous tab's content animating in.
    filter.value = value;
    notifications.clear();
    await loadNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpTo(0);
    });
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      if (filter.value == NotificationFilter.unread) {
        notifications.clear();
      } else {
        notifications.assignAll(
            notifications.map((n) => n.copyWith(isRead: true)).toList());
      }
      for (final entry in _filterStates.entries) {
        if (entry.key == NotificationFilter.unread) {
          entry.value.items.clear();
        } else {
          entry.value.items =
              entry.value.items.map((n) => n.copyWith(isRead: true)).toList();
        }
      }
      _saveCurrentState();
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not mark all as read');
    }
  }

  Future<void> openNotification(String notificationId) async {
    final item = _repository.getById(notificationId) ??
        notifications.firstWhereOrNull((n) => n.id == notificationId);
    if (item == null) return;
    // Fire-and-forget so the card flips to the read style and the detail
    // screen opens immediately; markAsRead reverts and notifies on failure.
    if (!item.isRead) {
      unawaited(markAsRead(notificationId, closeSheet: false));
    }
    NotificationRouter.routeToNotification(item);
  }

  void openActionSheet(AppNotification notification) {
    Get.bottomSheet<void>(
      NotificationActionSheet(
        notification: notification,
        previewText: NotificationDisplayText.build(notification),
        onMarkRead:
            notification.isRead ? null : () => markAsRead(notification.id),
        onDelete: () => requestDelete(notification.id),
      ),
      isScrollControlled: true,
      backgroundColor: Get.context!.scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> markAsRead(String notificationId,
      {bool closeSheet = true}) async {
    if (mutatingIds.contains(notificationId)) return;
    mutatingIds.add(notificationId);

    // Optimistic update: flip the card to the read style right away so the
    // pale-primary background animates out without waiting for the API.
    AppNotification? previous;
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0 && !notifications[index].isRead) {
      previous = notifications[index];
      notifications[index] = previous.copyWith(isRead: true);
    }
    if (closeSheet && Get.isBottomSheetOpen == true) Get.back();

    try {
      await _repository.markAsRead(notificationId);
      if (filter.value == NotificationFilter.unread) {
        notifications.removeWhere((n) => n.id == notificationId);
      }
      _updateCachedNotification(notificationId, isRead: true);
      _saveCurrentState();
    } catch (_) {
      if (previous != null) {
        final revertIndex =
            notifications.indexWhere((n) => n.id == notificationId);
        if (revertIndex >= 0) notifications[revertIndex] = previous;
      }
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
      for (final state in _filterStates.values) {
        state.items.removeWhere((n) => n.id == notificationId);
      }
      _saveCurrentState();
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not delete notification');
    } finally {
      mutatingIds.remove(notificationId);
    }
  }

  void _saveCurrentState() {
    final state = _filterStates[filter.value]!;
    state
      ..items = notifications.toList()
      ..page = _page
      ..hasMore = _hasMore
      ..loaded = true
      ..scrollOffset = _currentScrollOffset;
  }

  /// Reads the scroll offset without asserting when the controller is
  /// attached to zero or multiple scroll views (which happens when the
  /// notification screen exists more than once in the navigation stack).
  double get _currentScrollOffset {
    final positions = scrollController.positions;
    if (positions.isEmpty) return 0;
    return positions.last.pixels;
  }

  void _jumpTo(double offset) {
    final positions = scrollController.positions;
    if (positions.isEmpty) return;
    final position = positions.last;
    position.jumpTo(offset.clamp(0, position.maxScrollExtent));
  }

  void _updateCachedNotification(String id, {required bool isRead}) {
    for (final entry in _filterStates.entries) {
      final state = entry.value;
      final index = state.items.indexWhere((item) => item.id == id);
      if (index < 0) {
        if (entry.key == NotificationFilter.read && isRead && state.loaded) {
          final item = _repository.getById(id);
          if (item != null) state.items.insert(0, item);
        }
        continue;
      }
      if (entry.key == NotificationFilter.unread && isRead) {
        state.items.removeAt(index);
      } else {
        state.items[index] = state.items[index].copyWith(isRead: isRead);
      }
    }
  }
}

class _NotificationFilterState {
  List<AppNotification> items = [];
  int page = 1;
  bool hasMore = true;
  bool loaded = false;
  double scrollOffset = 0;
}
