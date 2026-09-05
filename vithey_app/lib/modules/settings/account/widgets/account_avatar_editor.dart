import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';

class AccountAvatarEditor extends StatelessWidget {
  const AccountAvatarEditor({
    super.key,
    required this.fullName,
    this.avatarUrl,
    this.isUploading = false,
    required this.onChangeAvatar,
    this.onEditInfo,
    this.showEditAction = true,
  });

  final String fullName;
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback onChangeAvatar;
  final VoidCallback? onEditInfo;
  final bool showEditAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(name: fullName, imageUrl: avatarUrl, radius: 48),
              if (isUploading)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                    child: Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: isUploading ? null : onChangeAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showEditAction && onEditInfo != null) ...[
          const SizedBox(height: 12),
          Center(
            child: CustomButton(
              label: 'Update Information',
              icon: Icons.edit,
              variant: CustomButtonVariant.ghost,
              foregroundColor: AppColors.primary,
              onPressed: onEditInfo,
            ),
          ),
        ],
      ],
    );
  }
}
