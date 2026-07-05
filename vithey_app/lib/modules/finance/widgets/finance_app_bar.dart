import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';

class FinanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FinanceAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text('Finance', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset('assets/images/brand/logo_app.png', fit: BoxFit.contain),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Get.toNamed(AppRoutes.notifications),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    );
  }
}
