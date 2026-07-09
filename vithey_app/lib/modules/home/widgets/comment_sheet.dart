import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class CommentSheet extends StatefulWidget {
  const CommentSheet({
    super.key,
    required this.post,
    required this.onCommentAdded,
  });

  final FeedPost post;
  final VoidCallback onCommentAdded;

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _controller = TextEditingController();
  final _comments = <CommentModel>[].obs;
  final _isLoading = true.obs;
  final _isSending = false.obs;
  final _repo = Get.find<PostRepository>();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    _isLoading.value = true;
    try {
      final items = await _repo.fetchComments(widget.post.id);
      _comments.assignAll(items);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending.value) return;

    _isSending.value = true;
    final temp = CommentModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      author: HomeController.currentUser,
      text: text,
      createdAt: DateTime.now(),
      isPending: true,
    );
    _comments.insert(0, temp);
    _controller.clear();
    widget.onCommentAdded();

    try {
      final saved = await _repo.createComment(
        postId: widget.post.id,
        text: text,
        currentUser: HomeController.currentUser,
      );
      final index = _comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) _comments[index] = saved;
    } catch (_) {
      final index = _comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) _comments[index] = temp.copyWith(isPending: false, isFailed: true);
    } finally {
      _isSending.value = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('${widget.post.reactionCount} Likes'),
                    Text('${widget.post.commentCount} Comments'),
                    Text('${widget.post.shareCount} Shares'),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Obx(() {
                  if (_isLoading.value) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (_comments.isEmpty) {
                    return const Center(child: Text('No comments yet. Be the first to comment.'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    itemBuilder: (_, index) {
                      final comment = _comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserAvatar(name: comment.author.fullName, radius: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.appColors.inputFill,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: context.appColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(comment.author.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(comment.text),
                                    const SizedBox(height: 6),
                                    Text(
                                      RelativeTime.format(comment.createdAt),
                                      style: TextStyle(color: context.appColors.muted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Write a comment…',
                            filled: true,
                            fillColor: context.appColors.inputFill,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => IconButton(
                            onPressed: _isSending.value ? null : _send,
                            icon: _isSending.value
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.send, color: AppColors.primary),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
