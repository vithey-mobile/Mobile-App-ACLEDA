import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_system_ui.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_binding.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/home_screen.dart';
import 'package:aub_connect_app/modules/home/notification/notification_binding.dart';
import 'package:aub_connect_app/modules/home/notification/notification_screen.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_args.dart';
import 'package:aub_connect_app/modules/profile/profile_binding.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/profile_screen.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_cover_redesign.dart';
import 'package:aub_connect_app/modules/home/reels/reels_binding.dart';
import 'package:aub_connect_app/modules/home/reels/reels_screen.dart';
import 'package:aub_connect_app/core/localization/locale_service.dart';

/// Persistent main tabs host. Tab changes animate the page content only —
/// the bottom bar stays put (no GetX route push transitions).
/// Chatbot is opened as a full-screen route (no bottom bar).
class MainShellController extends GetxController {
  final currentIndex = MainTabNavigation.home.obs;
  final navVisible = true.obs;

  late final PageController pageController;

  static const _hideThreshold = 6.0;

  @override
  void onInit() {
    super.onInit();
    final initial = _initialIndex();
    currentIndex.value = initial;
    pageController = PageController(initialPage: _pageForTab(initial));
  }

  int _initialIndex() {
    final args = Get.arguments;
    if (args is int &&
        args >= MainTabNavigation.profile &&
        args <= MainTabNavigation.notifications &&
        args != MainTabNavigation.chatbot) {
      return args;
    }
    return MainTabNavigation.home;
  }

  /// Maps bottom-nav index → PageView index (chatbot has no page).
  static int _pageForTab(int tabIndex) {
    if (tabIndex == MainTabNavigation.notifications) return 3;
    if (tabIndex == MainTabNavigation.chatbot) return 1;
    return tabIndex;
  }

  static int _tabForPage(int pageIndex) {
    if (pageIndex == 3) return MainTabNavigation.notifications;
    return pageIndex;
  }

  Future<void> selectTab(int index) async {
    if (index == MainTabNavigation.chatbot) {
      Get.toNamed(AppRoutes.chatbot);
      return;
    }
    // Always reveal nav when switching tabs.
    navVisible.value = true;
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    if (!pageController.hasClients) return;
    await pageController.animateToPage(
      _pageForTab(index),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void onPageChanged(int pageIndex) {
    currentIndex.value = _tabForPage(pageIndex);
    navVisible.value = true;
  }

  Timer? _scrollStopTimer;

  /// Hide bar while scrolling down the feed; show again when scrolling up or when scroll stops.
  bool handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    // When scrolling completely stops (drag ends or momentum settles), bring the bar back smoothly.
    if (notification is ScrollEndNotification ||
        notification is UserScrollNotification &&
            notification.direction == ScrollDirection.idle) {
      _scrollStopTimer?.cancel();
      _scrollStopTimer = Timer(const Duration(milliseconds: 160), () {
        if (!navVisible.value) navVisible.value = true;
      });
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final pixels = notification.metrics.pixels;
      final delta = notification.scrollDelta ?? 0;

      if (pixels <= 48) {
        if (!navVisible.value) navVisible.value = true;
        return false;
      }

      if (delta > _hideThreshold) {
        _scrollStopTimer?.cancel();
        if (navVisible.value) navVisible.value = false;
        // Schedule auto-restore once user stops moving finger/scrolling
        _scrollStopTimer = Timer(const Duration(milliseconds: 400), () {
          if (!navVisible.value) navVisible.value = true;
        });
      } else if (delta < -_hideThreshold) {
        _scrollStopTimer?.cancel();
        if (!navVisible.value) navVisible.value = true;
      }
    }
    return false;
  }

  @override
  void onClose() {
    _scrollStopTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}

class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  List<Widget> _buildPages(String localeCode) => [
        ProfileScreen(
          key: ValueKey('shell_profile_$localeCode'),
          embedded: true,
        ),
        HomeScreen(
          key: ValueKey('shell_home_$localeCode'),
          embedded: true,
        ),
        ReelsScreen(
          key: ValueKey('shell_reels_$localeCode'),
          embedded: true,
        ),
        NotificationScreen(
          key: ValueKey('shell_notification_$localeCode'),
          embedded: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Obx(() {
      final index = controller.currentIndex.value;
      final localeCode = LocaleService.rxLocaleCode.value;
      final overlay = switch (index) {
        MainTabNavigation.reel => VitheySystemUi.immersiveDark(),
        MainTabNavigation.profile => VitheySystemUi.forBackground(
            ProfileCoverRedesign.tealColor(context),
            systemNavigationBarColor: colors.bodyBackground,
          ),
        _ => VitheySystemUi.forBackground(
            colors.bodyBackground,
            systemNavigationBarColor: colors.bodyBackground,
          ),
      };

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: Scaffold(
          extendBody: true,
          backgroundColor: colors.bodyBackground,
          floatingActionButtonLocation: AppBottomNavigation.fabLocation(),
          floatingActionButton: _ShellFab(tabIndex: index),
          body: NotificationListener<ScrollNotification>(
            onNotification: controller.handleScrollNotification,
            child: PageView(
              key: ValueKey('shell_page_view_$localeCode'),
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: controller.onPageChanged,
              children: _buildPages(localeCode),
            ),
          ),
          bottomNavigationBar: Builder(
            builder: (context) {
              final visible = controller.navVisible.value;
              return AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                curve: Curves.fastOutSlowIn,
                offset: visible ? Offset.zero : const Offset(0, 1.4),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 130),
                  opacity: visible ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !visible,
                    child: AppBottomNavigation(
                      currentIndex: controller.currentIndex.value,
                      onTap: controller.selectTab,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

/// Home / Profile FABs owned by the shell so they clear the real navbar.
class _ShellFab extends StatelessWidget {
  const _ShellFab({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<MainShellController>();
    final showHome = tabIndex == MainTabNavigation.home;
    final showProfile = tabIndex == MainTabNavigation.profile;

    if (!showHome && !showProfile) return const SizedBox.shrink();

    return Obx(() {
      final navVisible = shell.navVisible.value;
      final _ = LocaleService.rxLocaleCode.value;
      Widget? fab;

      if (showHome && Get.isRegistered<HomeController>()) {
        fab = FloatingActionButton.extended(
          heroTag: 'shell-post-fab',
          onPressed: () => Get.find<HomeController>()
              .openCreatePost(type: PostType.poster),
          backgroundColor: AppColors.primary,
          foregroundColor: context.scheme.onPrimary,
          elevation: 3,
          icon: VitheyIcon(
            LucideIcons.plus,
            size: 20,
            color: context.scheme.onPrimary,
          ),
          label: Text(
            'Post'.tr,
            style: context.text.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.scheme.onPrimary,
            ),
          ),
        );
      } else if (showProfile && Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>();
        if (!profile.isLoading.value &&
            !profile.hasError.value &&
            profile.profile.value != null) {
          fab = FloatingActionButton.extended(
            heroTag: 'shell-ai-cv-fab',
            onPressed: () => Get.toNamed(
              AppRoutes.applyCvTemplates,
              arguments: const AiCvArgs(returnToApply: false),
            ),
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
        }
      }

      if (fab == null) return const SizedBox.shrink();

      return IgnorePointer(
        ignoring: !navVisible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          offset: navVisible ? Offset.zero : const Offset(0, 1.6),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: navVisible ? 1 : 0,
            child: fab,
          ),
        ),
      );
    });
  }
}

/// Binding for the main tab shell and tab controllers (chatbot is route-only).
class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    HomeBinding().dependencies();
    ProfileBinding().dependencies();
    ReelsBinding().dependencies();
    NotificationBinding().dependencies();
    Get.lazyPut<MainShellController>(() => MainShellController(), fenix: true);
  }
}

/// Return to the shell (if needed), then select a tab with page motion.
void goToMainTab(int index) {
  if (index == MainTabNavigation.chatbot) {
    Get.toNamed(AppRoutes.chatbot);
    return;
  }

  if (Get.currentRoute != AppRoutes.home) {
    Get.until(
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
  }

  if (Get.isRegistered<MainShellController>()) {
    Get.find<MainShellController>().selectTab(index);
    return;
  }

  Get.offAllNamed(AppRoutes.home, arguments: index);
}
