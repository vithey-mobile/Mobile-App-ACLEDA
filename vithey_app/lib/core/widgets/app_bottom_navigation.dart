import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';

/// Floating pill bottom navigation used across main app screens.
///
/// Order: Profile (avatar) · Home · Reel · Chatbot/Chat · Notifications
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.avatarUrl,
    this.avatarName,
    /// When true (Messages screen), slot 3 shows a chat icon instead of chatbot.
    this.messagesMode = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? avatarUrl;
  final String? avatarName;
  final bool messagesMode;

  static const _height = 64.0;
  static const _radius = 32.0;
  static const _inactive = Color(0xFF9AA0A6);

  @override
  Widget build(BuildContext context) {
    final user = Get.isRegistered<CurrentUserService>()
        ? Get.find<CurrentUserService>()
        : null;
    final resolvedAvatar = avatarUrl ?? user?.avatarUrl;
    final resolvedName = avatarName ?? user?.displayName;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appColors.cardSurface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: context.appColors.subtleShadow.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _ProfileNavItem(
                  selected: currentIndex == 0,
                  avatarUrl: resolvedAvatar,
                  avatarName: resolvedName,
                  onTap: () => onTap(0),
                ),
                _NavIcon(
                  icon: Icons.home_outlined,
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavIcon(
                  icon: Icons.video_collection_outlined,
                  selected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavIcon(
                  icon: messagesMode
                      ? Icons.chat_bubble_outline_rounded
                      : Icons.lightbulb_outline_rounded,
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NotificationNavItem(
                  selected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: Container(
            width: selected ? 52 : 40,
            height: 44,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 24,
              color:
                  selected ? AppColors.primary : AppBottomNavigation._inactive,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationNavItem extends StatelessWidget {
  const _NotificationNavItem({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final repo = Get.isRegistered<NotificationRepository>()
        ? Get.find<NotificationRepository>()
        : null;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: Container(
            width: selected ? 52 : 40,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: repo == null
                ? Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: selected
                        ? AppColors.primary
                        : AppBottomNavigation._inactive,
                  )
                : Obx(() {
                    final count = repo.unreadCount.value;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text(count > 99 ? '99+' : '$count'),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 24,
                        color: selected
                            ? AppColors.primary
                            : AppBottomNavigation._inactive,
                      ),
                    );
                  }),
          ),
        ),
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  const _ProfileNavItem({
    required this.selected,
    required this.onTap,
    this.avatarUrl,
    this.avatarName,
  });

  final bool selected;
  final VoidCallback onTap;
  final String? avatarUrl;
  final String? avatarName;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: Container(
            width: selected ? 52 : 40,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppBottomNavigation._inactive.withValues(alpha: 0.45),
                  width: selected ? 2 : 1.2,
                ),
              ),
              child: UserAvatar(
                imageUrl: avatarUrl,
                name: avatarName,
                radius: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
