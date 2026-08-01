import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_screen_body.dart';

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
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      body: AppScreenBody(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: MainTabNavigation.profile,
        onTap: (index) => MainTabNavigation.handle(
          index,
          currentIndex: MainTabNavigation.profile,
        ),
      ),
    );
  }
}
