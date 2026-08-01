import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

PreferredSizeWidget buildChatbotAppBar({
  required VoidCallback onMenu,
  required VoidCallback onBackHome,
}) {
  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    leading: _CircleIconButton(
      icon: Icons.menu_rounded,
      tooltip: 'Menu',
      onPressed: onMenu,
    ),
    title: Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(22),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Vithey AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    ),
    actions: [
      _CircleIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: 'Back to home',
        onPressed: onBackHome,
      ),
      const SizedBox(width: 8),
    ],
  );
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: context.appColors.inputFill,
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, size: 22, color: context.appColors.heading),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
