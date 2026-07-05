import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/modules/notification/notification_controller.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_item.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Notification settings',
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() => _FilterBar(
                selected: controller.filter.value,
                onSelected: controller.selectFilter,
              )),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            itemCount: 8,
            itemBuilder: (_, __) => const Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ShimmerListTile(),
            ),
          );
        }
        if (controller.hasError.value) {
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
          child: ListView(
            children: [
              if (controller.filter.value == NotificationFilter.all &&
                  controller.newNotifications.isNotEmpty) ...[
                const _SectionHeader(title: 'New'),
                ...controller.newNotifications.map((n) => NotificationItem(
                      notification: n,
                      onTap: () => controller.openNotification(n.id),
                      onMore: () => controller.openActionSheet(n),
                    )),
              ],
              if (controller.filter.value == NotificationFilter.all &&
                  controller.earlierNotifications.isNotEmpty) ...[
                const _SectionHeader(title: 'Earlier'),
                ...controller.earlierNotifications.map((n) => NotificationItem(
                      notification: n,
                      onTap: () => controller.openNotification(n.id),
                      onMore: () => controller.openActionSheet(n),
                    )),
              ],
              if (controller.filter.value == NotificationFilter.unread)
                ...controller.notifications.map((n) => NotificationItem(
                      notification: n,
                      onTap: () => controller.openNotification(n.id),
                      onMore: () => controller.openActionSheet(n),
                    )),
            ],
          ),
        );
      }),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            selected: selected == NotificationFilter.all,
            onTap: () => onSelected(NotificationFilter.all),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Unread',
            selected: selected == NotificationFilter.unread,
            onTap: () => onSelected(NotificationFilter.unread),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.authMuted,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
