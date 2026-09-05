import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';

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
    final action = await showVitheyActionSheet<_PostOwnerAction>(
      context: context,
      title: 'Post actions',
      actions: [
        VitheyActionSheetAction(
          value: _PostOwnerAction.edit,
          label: 'Edit post',
          subtitle: 'Update text, media, or job details',
          icon: Icons.edit_outlined,
        ),
        VitheyActionSheetAction(
          value: _PostOwnerAction.delete,
          label: 'Delete post',
          subtitle: 'Permanently remove this post',
          icon: Icons.delete_outline,
          destructive: true,
        ),
      ],
    );
    if (action == _PostOwnerAction.edit) onEdit();
    if (action == _PostOwnerAction.delete) onDelete();
  }
}

enum _PostOwnerAction { edit, delete }
