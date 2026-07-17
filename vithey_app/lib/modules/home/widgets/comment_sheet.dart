import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';

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
  final _comments = <CommentModel>[].obs;
  final _isLoading = true.obs;
  final _isSending = false.obs;
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.appColors.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.muted.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        color: context.appColors.heading,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.post.commentCount}',
                      style: TextStyle(
                        color: context.appColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: context.appColors.border),
              Expanded(
                child: Obx(() {
                  if (_isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (_comments.isEmpty) {
                    return Center(
                      child: Text(
                        'No comments yet. Be the first to comment.',
                        style: TextStyle(
                          color: context.appColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 8, 10, 12),
                    itemCount: _comments.length,
                    itemBuilder: (_, index) =>
                        _buildComment(context, _comments[index]),
                  );
                }),
              ),
              _buildComposer(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComment(BuildContext context, CommentModel comment) {
    final isReply = comment.isReply;
    final isOwn = comment.isOwnedBy(_currentUser.userId);
    return Padding(
      padding: EdgeInsets.fromLTRB(isReply ? 40 : 8, 4, 0, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            name: comment.author.fullName,
            imageUrl: comment.author.avatarUrl,
            radius: isReply ? 15 : 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  decoration: BoxDecoration(
                    color: context.appColors.cardSurface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.author.fullName,
                        style: TextStyle(
                          color: context.appColors.heading,
                          fontWeight: FontWeight.w600,
                          fontSize: isReply ? 13 : 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.text,
                        style: TextStyle(
                          color: context.appColors.heading,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 1, top: 5),
                  child: Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _SheetCommentAction(label: 'Like', onTap: () {}),
                      _SheetCommentAction(
                        label: 'Reply',
                        onTap: () => _replyTo(comment),
                      ),
                      if (isOwn) ...[
                        _SheetCommentAction(
                          label: 'Edit',
                          onTap: () => _startEdit(comment),
                        ),
                        _SheetCommentAction(
                          label: 'Delete',
                          color: context.scheme.error,
                          onTap: () => _delete(comment),
                        ),
                      ],
                      Text(
                        RelativeTime.format(comment.createdAt),
                        style: TextStyle(
                          color: context.appColors.muted,
                          fontSize: 11.5,
                        ),
                      ),
                      if (comment.isPending)
                        Text(
                          'Sending…',
                          style: TextStyle(
                            color: context.appColors.muted,
                            fontSize: 11.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final modeLabel = _editingComment != null
        ? 'Editing comment'
        : _replyTarget != null
            ? 'Replying to ${_replyTarget!.author.fullName}'
            : null;
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        border: Border(top: BorderSide(color: context.appColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            10 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (modeLabel != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          modeLabel,
                          style: TextStyle(
                            color: context.appColors.muted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _replyTarget = null;
                            _editingComment = null;
                          });
                          _controller.clear();
                        },
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              Container(
                constraints: const BoxConstraints(minHeight: 50),
                decoration: BoxDecoration(
                  color: context.appColors.cardSurface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: context.appColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 3,
                        style: TextStyle(
                          color: context.appColors.heading,
                          fontSize: 15,
                        ),
                        cursorColor: context.scheme.primary,
                        decoration: InputDecoration(
                          hintText: 'Amazing!',
                          hintStyle: TextStyle(
                            color: context.appColors.muted,
                            fontSize: 15,
                          ),
                          filled: false,
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(
                            14,
                            15,
                            8,
                            14,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 4, 4, 4),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (_, value, __) => Obx(() {
                          final canSend =
                              value.text.trim().isNotEmpty && !_isSending.value;
                          return SizedBox(
                            width: 42,
                            height: 42,
                            child: IconButton(
                              tooltip: _editingComment != null
                                  ? 'Save comment'
                                  : 'Send comment',
                              onPressed: canSend ? _send : null,
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                                backgroundColor: context.scheme.primary,
                                foregroundColor: context.scheme.onPrimary,
                                disabledBackgroundColor:
                                    context.appColors.inputFill,
                                disabledForegroundColor:
                                    context.appColors.muted,
                              ),
                              icon: _isSending.value
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: context.scheme.onPrimary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      size: 20,
                                    ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetCommentAction extends StatelessWidget {
  const _SheetCommentAction({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            color: color ?? context.appColors.muted,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
