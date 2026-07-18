import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_header.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_tabs.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_wavy_header.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/modules/home/widgets/home_bottom_navigation.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading profile...');
        }
        if (controller.hasError.value) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshProfile,
          );
        }
        final profile = controller.profile.value;
        if (profile == null) {
          return const AppErrorWidget(message: 'Profile unavailable');
        }

        final tabs = <Tab>[
          const Tab(text: 'About'),
          const Tab(text: 'Videos'),
          const Tab(text: 'Posters'),
          const Tab(text: 'Jobs'),
          if (controller.isOwnProfile) const Tab(text: 'Applied Jobs'),
        ];

        final tabViews = <Widget>[
          const ProfileAboutTab(),
          const ProfileVideosTab(),
          const ProfilePostersTab(),
          const ProfileJobsTab(),
          if (controller.isOwnProfile) const ProfileAppliedJobsTab(),
        ];

        return NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProfileWavyHeader(
                    profile: profile,
                    showMenu: controller.isOwnProfile,
                    onMenuTap: () => Get.toNamed(AppRoutes.settings),
                    showCvPreview: controller.isOwnProfile,
                    onCvPreviewTap: controller.openPreviewOwnCv,
                  ),
                  ProfileStats(profile: profile),
                  Obx(
                    () => ProfileActionRow(
                      isOwnProfile: controller.isOwnProfile,
                      isFollowing: profile.isFollowing,
                      isStudentVerified:
                          Get.find<StudentVerificationRepository>()
                              .isVerified
                              .value,
                      onFollow: controller.toggleFollow,
                      onMessage: controller.startMessage,
                      onEditProfile: controller.openEditProfile,
                      onVerifyStudent: controller.openVerifyStudent,
                      onShare: controller.shareProfile,
                    ),
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: controller.tabController,
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorWeight: 3,
                  tabAlignment: TabAlignment.start,
                  tabs: tabs,
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: controller.tabController,
            children: tabViews,
          ),
        );
      }),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed(AppRoutes.home);
          } else if (index == 1) {
            FinanceNavigation.openFinanceEntry();
          } else if (index == 2) {
            Get.toNamed(AppRoutes.createPost);
          } else if (index == 3) {
            Get.offNamed(AppRoutes.chat);
          }
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
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 1 : 0,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
