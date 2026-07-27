import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/modules/notification/notification_controller.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_filter_bar.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_group_header.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_item.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_item_skeleton.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_list_entrance.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: context.appColors.bodyBackground,
        foregroundColor: context.appColors.heading,
        titleSpacing: 0,
        title: const Text(
          'Notification',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: context.appColors.border,
          ),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            const SizedBox(height: 20),
            NotificationFilterBar(
              selected: controller.filter.value,
              onSelected: controller.selectFilter,
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
          ],
        );
      }),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading.value && controller.notifications.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: 7,
        itemBuilder: (_, __) => const NotificationItemSkeleton(),
      );
    }
    if (controller.hasError.value && controller.notifications.isEmpty) {
      return AppErrorWidget(
        message: controller.errorMessage.value,
        onRetry: controller.loadNotifications,
      );
    }
    if (controller.notifications.isEmpty) {
      final filter = controller.filter.value;
      return EmptyStateWidget(
        title: switch (filter) {
          NotificationFilter.all => 'No notifications yet',
          NotificationFilter.read => 'Nothing here yet',
          NotificationFilter.unread => 'You\'re all caught up',
        },
        subtitle: switch (filter) {
          NotificationFilter.all => 'Your latest activity will appear here',
          NotificationFilter.read => 'Read notifications will appear here',
          NotificationFilter.unread => 'Unread notifications will appear here',
        },
        icon: Icons.notifications_none_rounded,
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
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ..._buildAnimatedSections(),
            if (controller.isLoadingMore.value)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (controller.paginationError.value)
              Center(
                child: TextButton.icon(
                  onPressed: controller.loadMore,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Flattens sections into headers + cards, each wrapped in a staggered
  /// entrance animation. Keys include the active filter so the animation
  /// replays on every tab switch but not on unrelated rebuilds.
  List<Widget> _buildAnimatedSections() {
    final filter = controller.filter.value;
    final direction = controller.slideDirection;
    final children = <Widget>[];
    var index = 0;

    for (final section in controller.sections) {
      children.add(
        NotificationListEntrance(
          key: ValueKey('$filter-header-${section.title}'),
          index: index++,
          direction: direction,
          child: NotificationGroupHeader(title: section.title),
        ),
      );
      for (final notification in section.items) {
        children.add(
          NotificationListEntrance(
            key: ValueKey('$filter-item-${notification.id}'),
            index: index++,
            direction: direction,
            child: _buildItem(notification),
          ),
        );
      }
    }
    return children;
  }

  Widget _buildItem(AppNotification notification) {
    return NotificationItem(
      notification: notification,
      onTap: () => controller.openNotification(notification.id),
      onMore: () => controller.openActionSheet(notification),
    );
  }
}
