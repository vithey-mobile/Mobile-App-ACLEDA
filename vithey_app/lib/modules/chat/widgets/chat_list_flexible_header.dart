import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/chat/widgets/add_chat_contacts_row.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_list_app_bar.dart';
import 'package:aub_connect_app/modules/home/widgets/home_app_bar.dart';
import 'package:get/get.dart';

/// Collapsing chat header like home: contacts collapse into title avatar stack.
class ChatListFlexibleHeader extends StatelessWidget {
  const ChatListFlexibleHeader({super.key});

  static const double toolbarHeight = 52;
  static const double contactsHeight = 108;
  static const double maxHeight = toolbarHeight + contactsHeight;
  static const double minHeight = toolbarHeight;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ChatListHeaderDelegate(),
    );
  }
}

class _ChatListHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get maxExtent => ChatListFlexibleHeader.maxHeight;

  @override
  double get minExtent => ChatListFlexibleHeader.minHeight;

  @override
  bool shouldRebuild(covariant _ChatListHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final t = (shrinkOffset / range).clamp(0.0, 1.0);
    final expandT = 1.0 - t;
    final colors = context.appColors;
    final controller = Get.find<ChatListController>();
    final title = AppStrings.appName.split(' ').first;

    // Share collapse with folder tabs (hide bottom border when scrolled).
    if (Get.isRegistered<ChatListController>()) {
      final collapsed = t > 0.55 || overlapsContent;
      if (controller.headerCollapsed.value != collapsed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.headerCollapsed.value != collapsed) {
            controller.headerCollapsed.value = collapsed;
          }
        });
      }
    }

    return Material(
      color: colors.cardSurface,
      elevation: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final contactsVisible = (height - minExtent)
              .clamp(0.0, ChatListFlexibleHeader.contactsHeight);

          return ClipRect(
            child: SizedBox(
              width: constraints.maxWidth,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: ChatListFlexibleHeader.toolbarHeight,
                    child: Obx(() {
                      final stack = controller.recentContacts.take(3).toList();
                      return _ChatToolbar(
                        title: title,
                        expandT: expandT,
                        t: t,
                        stackContacts: stack,
                        onStackTap: stack.isEmpty
                            ? null
                            : () => controller.openContactChat(stack.first),
                        inboxCount: controller.messageRequests.length,
                        onSearch: () => Get.toNamed(AppRoutes.search),
                        onInbox: () => showMessageRequestsSheet(context),
                      );
                    }),
                  ),
                  if (contactsVisible > 2)
                    Positioned(
                      top: ChatListFlexibleHeader.toolbarHeight,
                      left: 0,
                      right: 0,
                      height: contactsVisible,
                      child: Opacity(
                        opacity: expandT.clamp(0.0, 1.0),
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          maxHeight: ChatListFlexibleHeader.contactsHeight,
                          child: Obx(() {
                            final contacts =
                                controller.recentContacts.toList();
                            return AddChatContactsRow(
                              contacts: contacts,
                              onAddChat: controller.openAddChat,
                              onContactTap: controller.openContactChat,
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatToolbar extends StatelessWidget {
  const _ChatToolbar({
    required this.title,
    required this.expandT,
    required this.t,
    required this.stackContacts,
    required this.inboxCount,
    required this.onSearch,
    required this.onInbox,
    this.onStackTap,
  });

  final String title;
  final double expandT;
  final double t;
  final List<ChatParticipant> stackContacts;
  final int inboxCount;
  final VoidCallback onSearch;
  final VoidCallback onInbox;
  final VoidCallback? onStackTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Opacity(
                  opacity: expandT,
                  child: IgnorePointer(
                    ignoring: t > 0.5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: colors.heading,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: t,
                  child: IgnorePointer(
                    ignoring: t < 0.5,
                    child: Row(
                      children: [
                        if (stackContacts.isNotEmpty) ...[
                          _OverlappingContactStack(
                            contacts: stackContacts,
                            onTap: onStackTap ?? () {},
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.heading,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          HomeAppBarAction(
            icon: const Icon(Icons.search_rounded),
            onPressed: onSearch,
            tooltip: AppStrings.chatSearchHint,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              HomeAppBarAction(
                icon: const Icon(Icons.mark_email_unread_outlined),
                onPressed: onInbox,
                tooltip: AppStrings.chatMessageRequests,
              ),
              if (inboxCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      inboxCount > 9 ? '9+' : '$inboxCount',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

class _OverlappingContactStack extends StatelessWidget {
  const _OverlappingContactStack({
    required this.contacts,
    required this.onTap,
  });

  final List<ChatParticipant> contacts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    const overlap = 12.0;
    final width = size + (contacts.length - 1) * (size - overlap);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: size,
        child: Stack(
          children: [
            for (var i = 0; i < contacts.length; i++)
              Positioned(
                left: i * (size - overlap),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    color: context.appColors.cardSurface,
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: UserAvatar(
                    name: contacts[i].fullName,
                    imageUrl: contacts[i].avatarUrl,
                    radius: (size / 2) - 3.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
