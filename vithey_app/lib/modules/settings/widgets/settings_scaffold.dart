import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/app_screen_body.dart';
import 'package:aub_connect_app/modules/home/widgets/home_bottom_navigation.dart';

class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      body: AppScreenBody(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: 4,
        onTap: _onBottomNavTap,
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Get.offAllNamed(AppRoutes.home);
    } else if (index == 1) {
      Get.toNamed(AppRoutes.finance);
    } else if (index == 2) {
      Get.toNamed(AppRoutes.createPost);
    } else if (index == 3) {
      Get.toNamed(AppRoutes.chat);
    } else if (index == 4) {
      Get.offAllNamed(AppRoutes.profile);
    }
  }
}
