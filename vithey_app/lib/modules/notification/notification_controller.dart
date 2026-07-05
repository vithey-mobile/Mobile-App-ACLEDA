import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/modules/notification/widgets/delete_notification_dialog.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_action_sheet.dart';

class NotificationController extends GetxController {
  NotificationController(this._repository);

  final NotificationRepository _repository;

  final filter = NotificationFilter.all.obs;
  final notifications = <AppNotification>[].obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final mutatingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      notifications.assignAll(
        await _repository.fetchNotifications(filter: filter.value),
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
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

  List<AppNotification> get newNotifications =>
      notifications.where((n) => !n.isRead).toList();

  List<AppNotification> get earlierNotifications =>
      notifications.where((n) => n.isRead).toList();

  Future<void> openNotification(String notificationId) async {
    final item = _repository.getById(notificationId);
    if (item == null) return;
    if (!item.isRead) await markAsRead(notificationId);
    _routeToDestination(item);
  }

  void openActionSheet(AppNotification notification) {
    Get.bottomSheet<void>(
      NotificationActionSheet(
        notification: notification,
        onMarkRead: notification.isRead ? null : () => markAsRead(notification.id),
        onDelete: () => requestDelete(notification.id),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> markAsRead(String notificationId) async {
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
      Get.back();
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not mark as read');
    } finally {
      mutatingIds.remove(notificationId);
    }
  }

  Future<void> requestDelete(String notificationId) async {
    Get.back();
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

  void _routeToDestination(AppNotification item) {
    final dest = item.destination;
    switch (item.type) {
      case NotificationType.postLike:
      case NotificationType.postComment:
      case NotificationType.postMention:
      case NotificationType.postShare:
        if (dest.postId != null) {
          Get.toNamed(AppRoutes.postDetail, arguments: dest.postId);
        }
        break;
      case NotificationType.newFollower:
        if (dest.userId != null) {
          Get.toNamed(AppRoutes.profile, arguments: ProfileArgs(userId: dest.userId!));
        }
        break;
      case NotificationType.jobApplicationReceived:
        if (dest.jobPostId != null) {
          Get.toNamed(
            AppRoutes.jobApplicants,
            arguments: JobApplicantsArgs(jobPostId: dest.jobPostId!, jobTitle: 'Job'),
          );
        }
        break;
      case NotificationType.jobApplicationStatus:
        Get.snackbar(AppStrings.appName, 'Application detail coming soon');
        break;
      case NotificationType.chatRequest:
        Get.toNamed(AppRoutes.chat);
        break;
      case NotificationType.chatMessage:
        if (dest.conversationId != null) {
          Get.toNamed(AppRoutes.chatDetail, arguments: ChatDetailArgs(conversationId: dest.conversationId!));
        }
        break;
      case NotificationType.paymentDue:
      case NotificationType.paymentOverdue:
        Get.toNamed(AppRoutes.finance);
        break;
      case NotificationType.studentVerification:
        Get.toNamed(AppRoutes.verificationStatus);
        break;
      case NotificationType.system:
        Get.snackbar(AppStrings.appName, item.displayText);
        break;
    }
  }
}
