import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/home_app_bar.dart';
import 'package:get/get.dart';

/// Home-style chat list header: title · search · inbox.
class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatListAppBar({super.key});

  static const double _extraTop = 24;
  static const double _barHeight = kToolbarHeight;

  @override
  Size get preferredSize =>
      const Size.fromHeight(_barHeight + _extraTop + 1);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatListController>();
    final colors = context.appColors;
    final title = AppStrings.appName.split(' ').first;

    return Material(
      color: colors.cardSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: _extraTop),
          SizedBox(
            height: _barHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.heading,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  HomeAppBarAction(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () => Get.toNamed(AppRoutes.search),
                    tooltip: 'Search',
                  ),
                  Obx(() {
                    final count = controller.messageRequests.length;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        HomeAppBarAction(
                          icon: const Icon(Icons.mark_email_unread_outlined),
                          onPressed: () => showMessageRequestsSheet(context),
                          tooltip: AppStrings.chatMessageRequests,
                        ),
                        if (count > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                count > 9 ? '9+' : '$count',
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
                    );
                  }),
                  const SizedBox(width: 2),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: colors.border),
        ],
      ),
    );
  }
}

Future<void> showMessageRequestsSheet(BuildContext context) {
  final controller = Get.find<ChatListController>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final colors = ctx.appColors;
      final height = MediaQuery.sizeOf(ctx).height * 0.72;
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.muted.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.chatMessageRequests,
                      style: TextStyle(
                        color: colors.heading,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: Icon(Icons.close_rounded, color: colors.muted),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),
            Expanded(
              child: Obx(() {
                final requests = controller.messageRequests;
                if (requests.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No message requests right now.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.muted, fontSize: 14),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final request = requests[index];
                    return _InboxRequestTile(
                      request: request,
                      onAccept: () async {
                        await controller.acceptRequest(request);
                        if (ctx.mounted && controller.messageRequests.isEmpty) {
                          Navigator.of(ctx).pop();
                        }
                      },
                      onDecline: () => controller.declineRequest(request),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
    },
  );
}

class _InboxRequestTile extends StatelessWidget {
  const _InboxRequestTile({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final MessageRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                name: request.requester.fullName,
                imageUrl: request.requester.avatarUrl,
                radius: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requester.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.heading,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Wants to message you',
                      style: TextStyle(color: colors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.initialMessage.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              request.initialMessage,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.heading,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.heading,
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
