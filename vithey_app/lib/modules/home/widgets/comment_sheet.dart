import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/profile/profile_navigation.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class CommentSheet extends StatefulWidget {
  const CommentSheet({
    super.key,
    required this.post,
    required this.onCommentAdded,
    required this.onCommentsRemoved,
  });

  final FeedPost post;
  final VoidCallback onCommentAdded;
  final ValueChanged<int> onCommentsRemoved;

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _comments = <CommentModel>[].obs;
  final _isLoading = true.obs;
  final _isSending = false.obs;
  final _likedIds = <String>{}.obs;
  final _dislikedIds = <String>{}.obs;
  final _likeCounts = <String, int>{}.obs;
  final _repo = Get.find<PostRepository>();
  final _currentUser = Get.find<CurrentUserService>();

  CommentModel? _replyTarget;
  CommentModel? _editingComment;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    _isLoading.value = true;
    try {
      final items = await _repo.fetchComments(widget.post.id);
      _comments.assignAll(_flattenThreaded(items));
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending.value) return;

    if (_editingComment != null) {
      await _saveEdit(text);
      return;
    }

    _isSending.value = true;
    final parentId = _replyTarget?.id;
    final temp = CommentModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      author: _currentUser.postAuthor,
      text: text,
      createdAt: DateTime.now(),
      parentCommentId: parentId,
      isPending: true,
    );
    _insertComment(temp);
    _controller.clear();
    setState(() => _replyTarget = null);
    widget.onCommentAdded();

    try {
      final saved = await _repo.createComment(
        postId: widget.post.id,
        text: text,
        currentUser: _currentUser.postAuthor,
        parentCommentId: parentId,
      );
      final index = _comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) _comments[index] = saved;
    } catch (_) {
      final index = _comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) {
        _comments[index] = temp.copyWith(isPending: false, isFailed: true);
      }
    } finally {
      _isSending.value = false;
    }
  }

  Future<void> _saveEdit(String text) async {
    final editing = _editingComment!;
    _isSending.value = true;
    final index = _comments.indexWhere((c) => c.id == editing.id);
    if (index >= 0) {
      _comments[index] = editing.copyWith(text: text, isPending: true);
    }
    try {
      final saved = await _repo.updateComment(
        postId: widget.post.id,
        commentId: editing.id,
        text: text,
      );
      final savedIndex = _comments.indexWhere((c) => c.id == editing.id);
      if (savedIndex >= 0) _comments[savedIndex] = saved;
      _controller.clear();
      setState(() => _editingComment = null);
    } catch (_) {
      final failedIndex = _comments.indexWhere((c) => c.id == editing.id);
      if (failedIndex >= 0) _comments[failedIndex] = editing;
      Get.snackbar(AppStrings.appName, 'Could not update comment');
    } finally {
      _isSending.value = false;
    }
  }

  void _insertComment(CommentModel comment) {
    final parentId = comment.parentCommentId;
    if (parentId == null || parentId.isEmpty) {
      _comments.insert(0, comment);
      return;
    }
    final parentIndex = _comments.indexWhere((c) => c.id == parentId);
    if (parentIndex < 0) {
      _comments.insert(0, comment);
      return;
    }
    var insertAt = parentIndex + 1;
    while (insertAt < _comments.length &&
        _comments[insertAt].parentCommentId == parentId) {
      insertAt++;
    }
    _comments.insert(insertAt, comment);
  }

  void _replyTo(CommentModel comment) {
    final parentId = comment.parentCommentId;
    final parent = parentId == null || parentId.isEmpty
        ? comment
        : _comments.firstWhereOrNull((c) => c.id == parentId) ?? comment;
    setState(() {
      _editingComment = null;
      _replyTarget = parent;
    });
    final handle = parent.author.fullName.replaceAll(' ', '');
    _controller.text = '@$handle ';
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _focusNode.requestFocus();
  }

  void _startEdit(CommentModel comment) {
    if (!comment.isOwnedBy(_currentUser.userId)) return;
    setState(() {
      _replyTarget = null;
      _editingComment = comment;
    });
    _controller.text = comment.text;
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _focusNode.requestFocus();
  }

  Future<void> _delete(CommentModel comment) async {
    if (!comment.isOwnedBy(_currentUser.userId)) return;
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete comment?',
      message: 'This comment will be removed permanently.',
      confirmLabel: 'Delete',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;

    final removed = _comments
        .where((c) => c.id == comment.id || c.parentCommentId == comment.id)
        .toList();
    _comments.removeWhere(
      (c) => c.id == comment.id || c.parentCommentId == comment.id,
    );
    widget.onCommentsRemoved(removed.length);
    try {
      await _repo.deleteComment(
        postId: widget.post.id,
        commentId: comment.id,
      );
    } catch (_) {
      _comments.assignAll(_flattenThreaded([..._comments, ...removed]));
      widget.onCommentsRemoved(-removed.length);
      Get.snackbar(AppStrings.appName, 'Could not delete comment');
    }
  }

  void _toggleLike(CommentModel comment) {
    final id = comment.id;
    final liked = _likedIds.contains(id);
    _dislikedIds.remove(id);
    if (liked) {
      _likedIds.remove(id);
      _likeCounts[id] = ((_likeCounts[id] ?? 1) - 1).clamp(0, 999999);
      if ((_likeCounts[id] ?? 0) == 0) _likeCounts.remove(id);
    } else {
      _likedIds.add(id);
      _likeCounts[id] = (_likeCounts[id] ?? 0) + 1;
    }
  }

  void _toggleDislike(CommentModel comment) {
    final id = comment.id;
    final disliked = _dislikedIds.contains(id);
    if (_likedIds.contains(id)) {
      _likedIds.remove(id);
      _likeCounts[id] = ((_likeCounts[id] ?? 1) - 1).clamp(0, 999999);
      if ((_likeCounts[id] ?? 0) == 0) _likeCounts.remove(id);
    }
    if (disliked) {
      _dislikedIds.remove(id);
    } else {
      _dislikedIds.add(id);
    }
  }

  List<CommentModel> _flattenThreaded(List<CommentModel> items) {
    final roots = items.where((c) => !c.isReply).toList();
    final replies = <String, List<CommentModel>>{};
    for (final reply in items.where((c) => c.isReply)) {
      replies.putIfAbsent(reply.parentCommentId!, () => []).add(reply);
    }
    return [
      for (final root in roots) ...[
        root,
        ...?replies[root.id],
      ],
    ];
  }

  String _compactTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insertEmoji(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = selection.start >= 0
        ? text.replaceRange(selection.start, selection.end, emoji)
        : text + emoji;
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start >= 0
            ? selection.start + emoji.length
            : newText.length,
      ),
    );
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;

    // GetModalBottomSheetRoute already applies padding for the keyboard bottom inset,
    // positioning the bottom sheet flush on top of the keyboard.
    // Constrain height so the sheet stays comfortably below the top status bar / notch.
    final maxAvailableHeight = screenHeight - bottomInset - topPadding - 16.0;
    final defaultHeight =
        (screenHeight * 0.82).clamp(420.0, screenHeight - 64.0);
    final sheetHeight = bottomInset > 0
        ? maxAvailableHeight.clamp(260.0, screenHeight - 64.0)
        : defaultHeight;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(VitheyRadii.sheet),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                );
              }
              if (_comments.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (_, index) =>
                    _buildComment(context, _comments[index]),
              );
            }),
          ),
          _buildComposer(context, isKeyboardOpen: bottomInset > 0),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 38,
            height: 4.5,
            decoration: BoxDecoration(
              color: colors.muted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            children: [
              Text(
                'Comments',
                style: context.text.titleLarge?.copyWith(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: colors.heading,
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                final count = _comments.length;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(VitheyRadii.pill),
                  ),
                  child: Text(
                    '$count',
                    style: context.text.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                );
              }),
              const Spacer(),
              VitheyIconButton(
                icon: LucideIcons.x,
                tooltip: 'Close',
                color: colors.muted,
                circle: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: VitheyIcon(
                  LucideIcons.messageCircle,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No comments yet',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.heading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to share your thoughts!',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: colors.muted,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiBar(BuildContext context) {
    const emojis = ['❤️', '🔥', '👏', '😂', '👍', '🎉', '😍', '🙌'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: emojis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final emoji = emojis[index];
          return InkWell(
            onTap: () => _insertEmoji(emoji),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReplyBanner(BuildContext context) {
    final colors = context.appColors;
    if (_replyTarget == null && _editingComment == null) {
      return const SizedBox.shrink();
    }
    final isEditing = _editingComment != null;
    final label = isEditing
        ? 'Editing your comment'
        : 'Replying to ${_replyTarget!.author.fullName}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          VitheyIcon(
            isEditing ? LucideIcons.pencil : LucideIcons.cornerDownRight,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _replyTarget = null;
                _editingComment = null;
              });
              _controller.clear();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: VitheyIcon(
                LucideIcons.x,
                size: 14,
                color: colors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(BuildContext context, CommentModel comment) {
    final colors = context.appColors;
    final isReply = comment.isReply;
    final isOwn = comment.isOwnedBy(_currentUser.userId);

    return Obx(() {
      final liked = _likedIds.contains(comment.id);
      final disliked = _dislikedIds.contains(comment.id);
      final likeCount = _likeCounts[comment.id] ?? 0;

      return Padding(
        padding: EdgeInsets.fromLTRB(isReply ? 38 : 4, 8, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (Get.isBottomSheetOpen ?? false) Get.back();
                openUserProfile(comment.author.id);
              },
              child: UserAvatar(
                name: comment.author.fullName,
                imageUrl: comment.author.avatarUrl,
                radius: isReply ? 14 : 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (Get.isBottomSheetOpen ?? false) Get.back();
                                openUserProfile(comment.author.id);
                              },
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: comment.author.fullName,
                                      style: context.text.bodyMedium?.copyWith(
                                        color: colors.heading,
                                        fontSize: isReply ? 13.5 : 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '  ·  ${_compactTime(comment.createdAt)}',
                                      style: context.text.bodyMedium?.copyWith(
                                        color: colors.muted,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            _CommentText(
                              text: comment.text,
                              fontSize: isReply ? 13.5 : 14.5,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _ActionLabel(
                                  label: 'Reply',
                                  onTap: () => _replyTo(comment),
                                ),
                                if (isOwn) ...[
                                  const SizedBox(width: 14),
                                  _ActionLabel(
                                    label: 'Edit',
                                    onTap: () => _startEdit(comment),
                                  ),
                                  const SizedBox(width: 14),
                                  _ActionLabel(
                                    label: 'Delete',
                                    color: context.scheme.error,
                                    onTap: () => _delete(comment),
                                  ),
                                ],
                                if (comment.isPending) ...[
                                  const SizedBox(width: 14),
                                  Text(
                                    'Sending…',
                                    style: context.text.bodyMedium?.copyWith(
                                        color: colors.muted, fontSize: 12),
                                  ),
                                ],
                                if (likeCount > 0) ...[
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.inputFill,
                                      borderRadius: BorderRadius.circular(
                                          VitheyRadii.pill),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const VitheyIcon(
                                          LucideIcons.thumbsUp,
                                          size: 12,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$likeCount',
                                          style: context.text.labelLarge
                                              ?.copyWith(
                                            fontSize: 12,
                                            color: colors.heading,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CommentRowIconButton(
                              icon: LucideIcons.thumbsUp,
                              color: liked ? AppColors.primary : colors.muted,
                              tooltip: 'Like',
                              onTap: () => _toggleLike(comment),
                            ),
                            _CommentRowIconButton(
                              icon: LucideIcons.thumbsDown,
                              color: disliked ? colors.heading : colors.muted,
                              tooltip: 'Dislike',
                              onTap: () => _toggleDislike(comment),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildComposer(BuildContext context, {bool isKeyboardOpen = false}) {
    final colors = context.appColors;
    final me = _currentUser.postAuthor;
    final hint = _editingComment != null
        ? 'Edit your comment…'
        : _replyTarget != null
            ? 'Reply to ${_replyTarget!.author.fullName}…'
            : 'Add a comment…';

    const fieldHeight = 38.0;
    const avatarRadius = 17.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: !isKeyboardOpen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReplyBanner(context),
            const SizedBox(height: 4),
            _buildEmojiBar(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  UserAvatar(
                    name: me.fullName,
                    imageUrl: me.avatarUrl,
                    radius: avatarRadius,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (context, value, _) {
                        return Obx(() {
                          final hasText = value.text.trim().isNotEmpty;
                          final canSend = hasText && !_isSending.value;
                          return Container(
                            decoration: BoxDecoration(
                              color: colors.inputFill,
                              borderRadius:
                                  BorderRadius.circular(VitheyRadii.pill),
                              border: Border.all(
                                color: hasText
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : colors.border.withValues(alpha: 0.6),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(14, 2, 4, 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: fieldHeight,
                                      maxHeight: 110,
                                    ),
                                    child: TextField(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      minLines: 1,
                                      maxLines: 5,
                                      keyboardType: TextInputType.multiline,
                                      cursorColor: AppColors.primary,
                                      style: context.text.bodyMedium?.copyWith(
                                        height: 1.3,
                                        fontSize: 14,
                                        color: colors.heading,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintText: hint,
                                        hintStyle: context.text.bodyMedium
                                            ?.copyWith(
                                          color: colors.muted,
                                          fontSize: 13.5,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 9,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: fieldHeight,
                                  height: fieldHeight,
                                  child: IconButton(
                                    tooltip: _editingComment != null
                                        ? 'Save'
                                        : 'Send',
                                    onPressed: canSend ? _send : null,
                                    padding: EdgeInsets.zero,
                                    icon: _isSending.value
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: canSend
                                                  ? AppColors.primary
                                                  : Colors.transparent,
                                            ),
                                            child: Center(
                                              child: VitheyIcon(
                                                LucideIcons.arrowUp,
                                                size: 16,
                                                color: canSend
                                                    ? Colors.white
                                                    : colors.muted.withValues(
                                                        alpha: 0.4),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        label,
        style: context.text.bodyMedium?.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color ?? context.appColors.muted,
        ),
      ),
    );
  }
}

class _CommentText extends StatelessWidget {
  const _CommentText({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(@[A-Za-z0-9_]+)');
    var start = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      TextSpan(
        style: context.text.bodyMedium?.copyWith(
          fontSize: fontSize,
          height: 1.35,
          color: colors.heading,
        ),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }
}

class _CommentRowIconButton extends StatelessWidget {
  const _CommentRowIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: VitheyIcon(
                icon,
                size: 16,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
