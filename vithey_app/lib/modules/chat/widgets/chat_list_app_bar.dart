import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:get/get.dart';

class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatListAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.appColors.bodyBackground,
      foregroundColor: context.appColors.heading,
      title: Row(
        children: [
          const AppLogo(size: 28),
          const SizedBox(width: 8),
          Text(
            'Vithey',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_outlined),
          onPressed: () => Get.toNamed(AppRoutes.search),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: context.appColors.border),
      ),
    );
  }
}
