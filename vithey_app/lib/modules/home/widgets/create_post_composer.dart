import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const UserAvatar(name: 'Vithey User', radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTapComposer,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.appColors.inputFill,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.appColors.border),
                ),
                child: Text(
                  'What\'s on your mind?',
                  style: TextStyle(color: context.appColors.muted),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onTapGallery,
            icon: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
            tooltip: 'Add photo',
          ),
        ],
      ),
    );
  }
}
