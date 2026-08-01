import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/chat_folder.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_folders_sheet.dart';
import 'package:get/get.dart';

/// Pinned Telegram-style folder navigation bar with bordered capsule track.
class ChatFolderTabs extends StatelessWidget {
  const ChatFolderTabs({super.key});

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ChatFolderTabsDelegate(),
    );
  }
}

class _ChatFolderTabsDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get maxExtent => ChatFolderTabs.height;

  @override
  double get minExtent => ChatFolderTabs.height;

  @override
  bool shouldRebuild(covariant _ChatFolderTabsDelegate oldDelegate) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.appColors;
    final controller = Get.find<ChatListController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final trackFill = isDark
        ? const Color(0xFF1E2329)
        : colors.cardSurface;
    final trackBorder = isDark
        ? const Color(0xFF3A424C)
        : colors.border;
    final inactiveLabel = isDark
        ? const Color(0xFFA8B0BA)
        : colors.muted;
    final badgeBg = isDark
        ? const Color(0xFFE8EAED)
        : const Color(0xFFF1F3F5);
    final badgeFg = isDark
        ? const Color(0xFF2C333A)
        : colors.heading;

    return Material(
      color: colors.cardSurface,
      elevation: 0,
      child: Obx(() {
        final selected = controller.selectedFolderId.value;
        final conversationCount = controller.conversations.length;
        final folders = controller.customFolders.toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: trackFill,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: trackBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 2,
                ),
                children: [
                  _FolderNavTab(
                    label: AppStrings.chatFolderAll,
                    count: conversationCount,
                    selected: selected == ChatFolderIds.all,
                    inactiveLabel: inactiveLabel,
                    badgeBg: badgeBg,
                    badgeFg: badgeFg,
                    onTap: () => controller.selectFolder(ChatFolderIds.all),
                  ),
                  _FolderNavTab(
                    label: AppStrings.chatFolderUnread,
                    count: controller.countForFolder(ChatFolderIds.unread),
                    selected: selected == ChatFolderIds.unread,
                    inactiveLabel: inactiveLabel,
                    badgeBg: badgeBg,
                    badgeFg: badgeFg,
                    onTap: () =>
                        controller.selectFolder(ChatFolderIds.unread),
                  ),
                  ...folders.map(
                    (folder) => _FolderNavTab(
                      label: folder.name,
                      count: controller.countForFolder(folder.id),
                      selected: selected == folder.id,
                      inactiveLabel: inactiveLabel,
                      badgeBg: badgeBg,
                      badgeFg: badgeFg,
                      onTap: () => controller.selectFolder(folder.id),
                      onLongPress: () =>
                          showAddChatsToFolderSheet(context, folder),
                    ),
                  ),
                  _ManageFolderNavTab(
                    onTap: () => showCreateFolderDialog(context),
                    onLongPress: () => showManageFoldersSheet(context),
                    color: inactiveLabel,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FolderNavTab extends StatelessWidget {
  const _FolderNavTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.inactiveLabel,
    required this.badgeBg,
    required this.badgeFg,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final int count;
  final bool selected;
  final Color inactiveLabel;
  final Color badgeBg;
  final Color badgeFg;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(99),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 3, 8, 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.primaryLight : inactiveLabel,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  height: 16,
                  constraints: const BoxConstraints(minWidth: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryLight
                        : badgeBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeFg,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageFolderNavTab extends StatelessWidget {
  const _ManageFolderNavTab({
    required this.onTap,
    required this.color,
    this.onLongPress,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_outlined, size: 16, color: color),
              const SizedBox(width: 2),
              Icon(Icons.add, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
