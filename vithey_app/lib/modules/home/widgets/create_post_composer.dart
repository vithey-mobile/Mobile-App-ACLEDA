import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class CreatePostComposer extends StatelessWidget {
  const CreatePostComposer({
    super.key,
    required this.onTapComposer,
    required this.onTapGallery,
  });

  final VoidCallback onTapComposer;
  final VoidCallback onTapGallery;

  @override
  Widget build(BuildContext context) {
    final currentUser = Get.find<CurrentUserService>();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appColors.border),
        ),
      ),
      child: Row(
        children: [
          Obx(
            () => UserAvatar(
              name: currentUser.displayName,
              imageUrl: currentUser.user.value?.avatarUrl,
              radius: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: context.appColors.inputFill,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: onTapComposer,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 42,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: Text(
                    'What\'s on your mind?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.appColors.muted),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          VitheyIconButton(
            icon: LucideIcons.image,
            variant: VitheyIconButtonVariant.neutral,
            tooltip: 'Add photo',
            onTap: onTapGallery,
          ),
        ],
      ),
    );
  }
}
