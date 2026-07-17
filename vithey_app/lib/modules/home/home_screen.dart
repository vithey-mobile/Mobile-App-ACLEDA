import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/create_post_composer.dart';
import 'package:aub_connect_app/modules/home/widgets/home_app_bar.dart';
import 'package:aub_connect_app/modules/home/widgets/home_bottom_navigation.dart';
import 'package:aub_connect_app/modules/home/widgets/mixed_post_feed.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? context.appColors.bodyBackground
          : context.scheme.surfaceContainerLow,
      appBar: const HomeAppBar(),
      body: Column(
        children: [
          ColoredBox(
            color: context.appColors.cardSurface,
            child: CreatePostComposer(
              onTapComposer: () => controller.openCreatePost(),
              onTapGallery: () =>
                  controller.openCreatePost(type: PostType.poster),
            ),
          ),
          const Expanded(child: MixedPostFeed()),
        ],
      ),
      bottomNavigationBar: Obx(
        () => HomeBottomNavigation(
          currentIndex: controller.currentTab.value,
          onTap: controller.onTabSelected,
          floating: true,
        ),
      ),
    );
  }
}
