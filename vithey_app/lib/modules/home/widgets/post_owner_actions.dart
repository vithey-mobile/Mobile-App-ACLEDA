import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PostOwnerActions extends StatelessWidget {
  const PostOwnerActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Post actions',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.more_horiz_rounded, size: 22),
      onPressed: () => _showActions(context),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final action = await showModalBottomSheet<_PostOwnerAction>(
      context: context,
      backgroundColor: context.appColors.cardSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit post'),
                subtitle: const Text('Update text, media, or job details'),
                onTap: () => Navigator.pop(context, _PostOwnerAction.edit),
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text(
                  'Delete post',
                  style: TextStyle(color: AppColors.error),
                ),
                subtitle: const Text('Permanently remove this post'),
                onTap: () => Navigator.pop(context, _PostOwnerAction.delete),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == _PostOwnerAction.edit) onEdit();
    if (action == _PostOwnerAction.delete) onDelete();
  }
}

enum _PostOwnerAction { edit, delete }
