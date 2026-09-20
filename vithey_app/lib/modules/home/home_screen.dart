import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/create_story_sheet.dart';
import 'package:aub_connect_app/modules/home/widgets/home_media_header.dart';
import 'package:aub_connect_app/modules/home/widgets/mixed_post_feed.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key, this.embedded = false});

  /// When true, used inside [MainShellScreen] (shell owns FAB + bottom bar).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      // Standalone (non-shell) still shows its own Post FAB.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: embedded
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  controller.openCreatePost(type: PostType.poster),
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
            ),
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => MixedPostFeed(
            topSlivers: [
              HomeFlexibleHeader(
                items: controller.mediaStories,
                onOpenOwnMedia: () => CreateStorySheet.show(context),
                onOpenItem: controller.openMediaItem,
                onAddStory: () => CreateStorySheet.show(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
