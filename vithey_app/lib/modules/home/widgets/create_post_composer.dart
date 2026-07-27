import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 11),
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
          const SizedBox(width: 9),
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
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: Text(
                    'What\'s on your mind?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.appColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 3),
          IconButton(
            onPressed: onTapGallery,
            icon: Icon(
              Icons.image_outlined,
              color: context.appColors.muted,
              size: 25,
            ),
            tooltip: 'Add photo',
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }
}
