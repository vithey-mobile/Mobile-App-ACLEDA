import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/modules/notification/notification_controller.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_filter_bar.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_group_header.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_item.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Obx(() {
            if (controller.filter.value != NotificationFilter.all ||
                controller.notifications.every((n) => n.isRead)) {
              return const SizedBox.shrink();
            }
            return TextButton(
              onPressed: controller.markAllAsRead,
              child: const Text('Mark all read'),
            );
          }),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => Get.toNamed(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Notification settings',
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(
            () => NotificationFilterBar(
              selected: controller.filter.value,
              onSelected: controller.selectFilter,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return ListView.builder(
            itemCount: 8,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ShimmerListTile(),
            ),
          );
        }
        if (controller.hasError.value && controller.notifications.isEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadNotifications,
          );
        }
        if (controller.notifications.isEmpty) {
          return EmptyStateWidget(
            title: controller.filter.value == NotificationFilter.unread
                ? 'You\'re all caught up'
                : 'No notifications yet',
            subtitle: controller.filter.value == NotificationFilter.unread
                ? 'Unread notifications will appear here'
                : 'Activity from likes, comments, jobs, and more will show up here',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (controller.filter.value == NotificationFilter.unread)
                  ...controller.notifications.map(_buildItem)
                else
                  ...controller.sections.expand((section) => [
                        NotificationGroupHeader(title: section.title),
                        ...section.items.map(_buildItem),
                      ]),
                if (controller.isLoadingMore.value)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildItem(AppNotification notification) {
    return NotificationItem(
      notification: notification,
      onTap: () => controller.openNotification(notification.id),
      onMore: () => controller.openActionSheet(notification),
    );
  }
}
