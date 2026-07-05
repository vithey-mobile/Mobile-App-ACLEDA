import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final notificationRepo = Get.find<NotificationRepository>();

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.authHeading,
      elevation: 0.5,
      title: Row(
        children: [
          Image.asset(AppAssets.logoApp, width: 28, height: 28),
          const SizedBox(width: 8),
          Text(AppStrings.appName.split(' ').first),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.auto_awesome_outlined),
          onPressed: () => Get.toNamed(AppRoutes.chatbot),
          tooltip: 'Vithey AI',
        ),
        Obx(() {
          final count = notificationRepo.unreadCount.value;
          return IconButton(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text(count > 99 ? '99+' : '$count'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            tooltip: 'Notifications',
          );
        }),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          onPressed: FinanceNavigation.openFinanceEntry,
          tooltip: 'Finance',
        ),
      ],
    );
  }
}
