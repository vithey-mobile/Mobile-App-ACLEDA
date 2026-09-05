import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';

/// Legacy preferred-size app bar (kept for screens that still need it).
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: context.appColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          const AppLogo(size: 28),
          const SizedBox(width: 8),
          Text(
            AppStrings.appName.split(' ').first,
            style: TextStyle(
              color: context.appColors.heading,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        HomeAppBarAction(
          icon: const Icon(Icons.search),
          onPressed: () => Get.toNamed(AppRoutes.search),
          tooltip: 'Search',
        ),
        HomeAppBarAction(
          icon: const Icon(Icons.map_outlined),
          onPressed: () => Get.toNamed(AppRoutes.map),
          tooltip: 'Map',
        ),
        HomeAppBarAction(
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          onPressed: () => Get.toNamed(AppRoutes.chat),
          tooltip: 'Messages',
        ),
        const HomeAppBarAction(
          icon: Icon(Icons.account_balance_wallet_outlined),
          onPressed: FinanceNavigation.openFinanceEntry,
          tooltip: 'Finance',
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: context.appColors.border),
      ),
    );
  }
}

class HomeAppBarAction extends StatefulWidget {
  const HomeAppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<HomeAppBarAction> createState() => _HomeAppBarActionState();
}

class _HomeAppBarActionState extends State<HomeAppBarAction> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;
  bool _activated = false;

  Future<void> _handleTap() async {
    HapticFeedback.selectionClick();
    setState(() => _activated = true);
    widget.onPressed();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) setState(() => _activated = false);
  }

  @override
  Widget build(BuildContext context) {
    final isHighlighted = _hovered || _focused || _pressed || _activated;
    final backgroundOpacity = _pressed
        ? 0.18
        : _activated
            ? 0.14
            : (_hovered || _focused)
                ? 0.10
                : 0.0;
    final scale = _pressed
        ? 0.92
        : (_hovered || _focused)
            ? 1.04
            : 1.0;

    return Tooltip(
      message: widget.tooltip,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.scheme.primary.withValues(
              alpha: backgroundOpacity,
            ),
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleTap,
              onHover: (value) => setState(() => _hovered = value),
              onFocusChange: (value) => setState(() => _focused = value),
              onHighlightChanged: (value) => setState(() => _pressed = value),
              customBorder: const CircleBorder(),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                style: TextStyle(
                  color: isHighlighted
                      ? context.scheme.primary
                      : context.appColors.muted,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: isHighlighted
                        ? context.scheme.primary
                        : context.appColors.muted,
                    size: 22,
                  ),
                  child: Center(child: widget.icon),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
