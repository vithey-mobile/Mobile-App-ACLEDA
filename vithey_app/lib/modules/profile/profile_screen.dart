import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_header.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_tabs.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/modules/home/widgets/home_bottom_navigation.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vithey'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading profile...');
        }
        if (controller.hasError.value) {
          return AppErrorWidget(message: controller.errorMessage.value, onRetry: controller.refreshProfile);
        }
        final profile = controller.profile.value;
        if (profile == null) return const AppErrorWidget(message: 'Profile unavailable');

        return NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProfileHeader(profile: profile),
                  ProfileStats(profile: profile),
                  ProfileActionRow(
                    isOwnProfile: controller.isOwnProfile,
                    isFollowing: profile.isFollowing,
                    onFollow: controller.toggleFollow,
                    onMessage: controller.startMessage,
                    onEditProfile: () => Get.snackbar('Vithey', 'Edit Profile coming soon'),
                    onPreviewCv: controller.openPreviewOwnCv,
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: controller.tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Posters'),
                    Tab(text: 'Videos'),
                    Tab(text: 'Jobs'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: controller.tabController,
            children: const [
              ProfileAboutTab(),
              ProfilePostersTab(),
              ProfileVideosTab(),
              ProfileJobsTab(),
            ],
          ),
        );
      }),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed(AppRoutes.home);
          } else if (index == 2) Get.toNamed(AppRoutes.createPost);
          else if (index != 4) Get.snackbar('Vithey', 'Coming soon');
        },
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(color: Theme.of(context).scaffoldBackgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
