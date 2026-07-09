import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

PreferredSizeWidget buildChatbotAppBar({
  required VoidCallback onMenu,
  required VoidCallback onNewChat,
}) {
  return AppBar(
    elevation: 0,
    centerTitle: false,
    leading: _CircleIconButton(icon: Icons.menu, onPressed: onMenu),
    title: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Vithey AI',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
    actions: [
      _CircleIconButton(icon: Icons.chevron_right, onPressed: onNewChat),
      const SizedBox(width: 8),
    ],
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1),
    ),
  );
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: context.appColors.inputFill,
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, size: 22),
          tooltip: icon == Icons.chevron_right ? 'New Chat' : 'Menu',
          onPressed: onPressed,
        ),
      ),
    );
  }
}
