import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';

class ChatDetailHeader extends StatelessWidget {
  const ChatDetailHeader({
    super.key,
    required this.participant,
    required this.isTyping,
    required this.onBack,
    required this.onProfileTap,
    required this.onSearch,
    required this.onMenu,
  });

  final ChatParticipant? participant;
  final bool isTyping;
  final VoidCallback onBack;
  final VoidCallback onProfileTap;
  final VoidCallback onSearch;
  final ValueChanged<String> onMenu;

  @override
  Widget build(BuildContext context) {
    final p = participant;
    return AppBar(
      elevation: 0,
      backgroundColor: context.appColors.cardSurface,
      foregroundColor: context.appColors.heading,
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
      title: p == null
          ? const Text('Chat')
          : InkWell(
              onTap: onProfileTap,
              child: Row(
                children: [
                  UserAvatar(name: p.fullName, imageUrl: p.avatarUrl, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isTyping
                              ? AppStrings.chatTyping
                              : (p.isOnline ? AppStrings.chatActiveNow : ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: isTyping || p.isOnline
                                ? AppColors.primary
                                : context.appColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        IconButton(icon: const Icon(Icons.search_outlined), onPressed: onSearch),
        PopupMenuButton<String>(
          onSelected: onMenu,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'profile', child: Text('View profile')),
            PopupMenuItem(value: 'block', child: Text('Block')),
            PopupMenuItem(value: 'report', child: Text('Report')),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: context.appColors.border),
      ),
    );
  }
}
