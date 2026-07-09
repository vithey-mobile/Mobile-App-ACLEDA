import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      appBar: const HomeAppBar(),
      body: Column(
        children: [
          CreatePostComposer(
            onTapComposer: () => controller.openCreatePost(),
            onTapGallery: () => controller.openCreatePost(),
          ),
          const Expanded(child: MixedPostFeed()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.openCreatePost(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => HomeBottomNavigation(
          currentIndex: controller.currentTab.value,
          onTap: controller.onTabSelected,
        ),
      ),
    );
  }
}
