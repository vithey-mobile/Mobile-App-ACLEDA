import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_folder.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:get/get.dart';

Future<void> showManageFoldersSheet(BuildContext context) {
  final controller = Get.find<ChatListController>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final colors = ctx.appColors;
      final height = MediaQuery.sizeOf(ctx).height * 0.7;
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
                      AppStrings.chatManageFolders,
                      style: TextStyle(
                        color: colors.heading,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => showCreateFolderDialog(ctx),
                    child: const Text(AppStrings.chatNewFolder),
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
                final folders = controller.customFolders;
                if (folders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Create folders to organize your chats.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.muted, fontSize: 14),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: folders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final folder = folders[index];
                    final count = controller.countForFolder(folder.id);
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: colors.border),
                      ),
                      leading: const Icon(
                        Icons.folder_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        folder.name,
                        style: TextStyle(
                          color: colors.heading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '$count chats',
                        style: TextStyle(color: colors.muted, fontSize: 12),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'add') {
                            Navigator.of(ctx).pop();
                            await showAddChatsToFolderSheet(context, folder);
                          } else if (value == 'rename') {
                            await _promptRenameFolder(ctx, controller, folder);
                          } else if (value == 'delete') {
                            await controller.deleteFolder(folder.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'add',
                            child: Text(AppStrings.chatAddChatsToFolder),
                          ),
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(AppStrings.chatRenameFolder),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(AppStrings.chatDeleteFolder),
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.selectFolder(folder.id);
                        Navigator.of(ctx).pop();
                      },
                      onLongPress: () {
                        Navigator.of(ctx).pop();
                        showAddChatsToFolderSheet(context, folder);
                      },
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

/// Dialog to create a folder by name.
Future<ChatFolder?> showCreateFolderDialog(BuildContext context) async {
  final controller = Get.find<ChatListController>();
  final name = await _promptFolderName(
    context,
    title: AppStrings.chatNewFolder,
  );
  if (name == null || name.isEmpty) return null;
  final folder = await controller.createFolder(name);
  if (folder != null) controller.selectFolder(folder.id);
  return folder;
}

/// Pick chats to add into [folder] (long-press folder).
Future<void> showAddChatsToFolderSheet(
  BuildContext context,
  ChatFolder folder,
) {
  final controller = Get.find<ChatListController>();
  final selectedIds = <String>{}.obs;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return _AddChatsToFolderSheet(
        folder: folder,
        controller: controller,
        selectedIds: selectedIds,
      );
    },
  );
}

class _AddChatsToFolderSheet extends StatefulWidget {
  const _AddChatsToFolderSheet({
    required this.folder,
    required this.controller,
    required this.selectedIds,
  });

  final ChatFolder folder;
  final ChatListController controller;
  final RxSet<String> selectedIds;

  @override
  State<_AddChatsToFolderSheet> createState() => _AddChatsToFolderSheetState();
}

class _AddChatsToFolderSheetState extends State<_AddChatsToFolderSheet> {
  bool _fullScreen = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final height = _fullScreen ? screenHeight : screenHeight * 0.72;
    final topRadius = _fullScreen ? 0.0 : 20.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: height,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      ),
      child: Column(
        children: [
          if (!_fullScreen) ...[
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.muted.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ] else
            SizedBox(height: MediaQuery.paddingOf(context).top > 0 ? 4 : 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.chatAddChatsToFolder,
                    style: TextStyle(
                      color: colors.heading,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Obx(() {
                  final count = widget.selectedIds.length;
                  return TextButton(
                    onPressed: count == 0
                        ? null
                        : () async {
                            for (final id in widget.selectedIds.toList()) {
                              await widget.controller.addConversationToFolder(
                                widget.folder.id,
                                id,
                              );
                            }
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: Text(count == 0 ? 'Add' : 'Add ($count)'),
                  );
                }),
                IconButton(
                  tooltip: _fullScreen ? 'Exit full screen' : 'Full screen',
                  onPressed: () => setState(() => _fullScreen = !_fullScreen),
                  icon: Icon(
                    _fullScreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    color: colors.muted,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: colors.muted),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          Expanded(
            child: Obx(() {
              final latest = widget.controller.customFolders
                  .firstWhereOrNull((f) => f.id == widget.folder.id);
              final existing = latest?.conversationIds.toSet() ??
                  widget.folder.conversationIds.toSet();
              final chats = widget.controller.conversations
                  .where((c) => !existing.contains(c.id))
                  .toList();

              if (chats.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.chatNoChatsToAdd,
                    style: TextStyle(color: colors.muted),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                itemCount: chats.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: colors.border.withValues(alpha: 0.6),
                ),
                itemBuilder: (_, index) {
                  final chat = chats[index];
                  return Obx(() {
                    final checked = widget.selectedIds.contains(chat.id);
                    return CheckboxListTile(
                      value: checked,
                      onChanged: (value) {
                        if (value == true) {
                          widget.selectedIds.add(chat.id);
                        } else {
                          widget.selectedIds.remove(chat.id);
                        }
                      },
                      secondary: UserAvatar(
                        name: chat.participant.fullName,
                        imageUrl: chat.participant.avatarUrl,
                        radius: 22,
                      ),
                      title: Text(
                        chat.participant.fullName,
                        style: TextStyle(
                          color: colors.heading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        chat.lastMessagePreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.muted, fontSize: 13),
                      ),
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

Future<void> showMoveToFolderSheet(
  BuildContext context,
  ConversationModel conversation,
) {
  final controller = Get.find<ChatListController>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final colors = ctx.appColors;
      return Container(
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SafeArea(
          top: false,
          child: Obx(() {
            final folders = controller.customFolders.toList();
            final inFolders = controller.foldersContaining(conversation.id);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.chatMoveToFolder,
                  style: TextStyle(
                    color: colors.heading,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  conversation.participant.fullName,
                  style: TextStyle(color: colors.muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                if (folders.isEmpty)
                  Text(
                    'Create a folder first.',
                    style: TextStyle(color: colors.muted),
                  )
                else
                  ...folders.map((folder) {
                    final inFolder = inFolders.any((f) => f.id == folder.id);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        inFolder ? Icons.folder : Icons.folder_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(folder.name),
                      trailing: inFolder
                          ? TextButton(
                              onPressed: () async {
                                await controller.removeConversationFromFolder(
                                  folder.id,
                                  conversation.id,
                                );
                              },
                              child: const Text(AppStrings.chatRemoveFromFolder),
                            )
                          : TextButton(
                              onPressed: () async {
                                await controller.addConversationToFolder(
                                  folder.id,
                                  conversation.id,
                                );
                              },
                              child: const Text('Add'),
                            ),
                    );
                  }),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    showCreateFolderDialog(context);
                  },
                  child: const Text(AppStrings.chatNewFolder),
                ),
              ],
            );
          }),
        ),
      );
    },
  );
}

Future<void> _promptRenameFolder(
  BuildContext context,
  ChatListController controller,
  ChatFolder folder,
) async {
  final name = await _promptFolderName(
    context,
    title: AppStrings.chatRenameFolder,
    initial: folder.name,
  );
  if (name == null) return;
  await controller.renameFolder(folder.id, name);
}

Future<String?> _promptFolderName(
  BuildContext context, {
  required String title,
  String? initial,
}) {
  final colors = context.appColors;
  final textController = TextEditingController(text: initial ?? '');
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: colors.cardSurface,
        title: Text(title, style: TextStyle(color: colors.heading)),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: AppStrings.chatFolderNameHint,
            hintStyle: TextStyle(color: colors.muted),
          ),
          onSubmitted: (value) => Navigator.of(ctx).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(textController.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
