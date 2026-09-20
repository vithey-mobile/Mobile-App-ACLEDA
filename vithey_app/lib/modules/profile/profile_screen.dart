import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_args.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_all.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_cover_redesign.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_header.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reels.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_tabs.dart';

/// Own profile (logged-in user — Khorn Molika).
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key, this.embedded = false});

  /// When true, used inside [MainShellScreen] (shell owns the bottom bar).
  final bool embedded;

  Future<void> _openAiCreateCv() async {
    await Get.toNamed(
      AppRoutes.applyCvTemplates,
      arguments: const AiCvArgs(returnToApply: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      // Standalone (non-shell) still shows its own FAB.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: embedded
          ? null
          : Obx(() {
              if (controller.isLoading.value ||
                  controller.hasError.value ||
                  controller.profile.value == null) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton.extended(
                onPressed: _openAiCreateCv,
                backgroundColor: AppColors.primary,
                foregroundColor: context.scheme.onPrimary,
                elevation: 3,
                icon: VitheyIcon(
                  LucideIcons.sparkles,
                  size: 20,
                  color: context.scheme.onPrimary,
                ),
                label: Text(
                  'AI Create CV'.tr,
                  style: context.text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.scheme.onPrimary,
                  ),
                ),
              );
            }),
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
          Tab(text: 'All'.tr),
          Tab(text: 'Reels'.tr),
          Tab(text: 'Posters'.tr),
          Tab(text: 'Jobs'.tr),
          Tab(text: 'Applied Jobs'.tr),
        ];

        const tabViews = <Widget>[
          ProfileAllTab(),
          ProfileReelsTab(),
          ProfilePostersTab(),
          ProfileJobsTab(),
          ProfileAppliedJobsTab(),
        ];

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProfileCoverRedesign(
                    profile: profile,
                    showMenu: true,
                    onMenuTap: () => Get.toNamed(AppRoutes.settings),
                    onEditProfile: controller.openEditProfile,
                    onVerifyStudent: controller.openVerifyStudent,
                    isStudentVerified:
                        Get.find<StudentVerificationRepository>()
                            .isVerified
                            .value,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        Text(
                          profile.fullName,
                          style: context.text.titleLarge
                              ?.copyWith(fontSize: 20, height: 1.2),
                          textAlign: TextAlign.center,
                        ),
                        if (profile.bio != null &&
                            profile.bio!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            profile.bio!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMedium?.copyWith(
                              color: context.appColors.muted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ProfileStats(profile: profile),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                topInset: MediaQuery.paddingOf(context).top,
                // Only inset under the status bar once the tab strip is stuck.
                pinnedUnderStatusBar: innerBoxIsScrolled,
                tabBar: TabBar(
                  controller: controller.tabController,
                  isScrollable: true,
                  dividerColor: context.appColors.border,
                  dividerHeight: 1,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(VitheyRadii.pill),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(vertical: 6),
                  splashBorderRadius: BorderRadius.circular(VitheyRadii.pill),
                  labelColor: context.scheme.onPrimary,
                  unselectedLabelColor: context.appColors.muted,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  labelStyle: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.scheme.onPrimary,
                  ),
                  unselectedLabelStyle: context.text.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
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
      bottomNavigationBar: embedded
          ? null
          : AppBottomNavigation(
              currentIndex: MainTabNavigation.profile,
              onTap: (index) => MainTabNavigation.handle(
                index,
                currentIndex: MainTabNavigation.profile,
              ),
            ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({
    required this.tabBar,
    required this.topInset,
    required this.pinnedUnderStatusBar,
  });

  final TabBar tabBar;
  final double topInset;
  final bool pinnedUnderStatusBar;

  double get _statusPad => pinnedUnderStatusBar ? topInset : 0;

  @override
  double get minExtent => tabBar.preferredSize.height + _statusPad;

  @override
  double get maxExtent => tabBar.preferredSize.height + _statusPad;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final pad = _statusPad;
    return Material(
      color: bg,
      elevation: pinnedUnderStatusBar || overlapsContent ? 1 : 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pad > 0) SizedBox(height: pad),
          tabBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      topInset != oldDelegate.topInset ||
      pinnedUnderStatusBar != oldDelegate.pinnedUnderStatusBar ||
      tabBar != oldDelegate.tabBar;
}
