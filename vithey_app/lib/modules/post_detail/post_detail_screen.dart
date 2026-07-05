import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/feed_action_bar.dart';
import 'package:aub_connect_app/modules/post_detail/post_detail_controller.dart';
import 'package:aub_connect_app/modules/post_detail/widgets/comment_section.dart';
import 'package:aub_connect_app/modules/post_detail/widgets/post_detail_header.dart';
import 'package:aub_connect_app/modules/post_detail/widgets/post_detail_media.dart';

class PostDetailScreen extends GetView<PostDetailController> {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Get.back(result: controller.post.value);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(result: controller.post.value),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingWidget(message: 'Loading post...');
          }
          if (controller.hasError.value) {
            return AppErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.loadPost,
            );
          }

          final post = controller.post.value;
          if (post == null) {
            return const AppErrorWidget(message: 'Post unavailable');
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostDetailHeader(post: post, onFollow: controller.toggleFollow),
                if (post.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(post.content),
                  ),
                const SizedBox(height: 8),
                PostDetailMedia(post: post),
                if (post.type == PostType.job)
                  _JobDetailBlock(post: post, onApply: controller.applyJob),
                FeedActionBar(
                  post: post,
                  onLike: controller.toggleLike,
                  onComment: () => controller.commentFocus.requestFocus(),
                  onShare: () {},
                ),
                const Divider(height: 1),
                const CommentSection(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _JobDetailBlock extends StatelessWidget {
  const _JobDetailBlock({required this.post, required this.onApply});

  final FeedPost post;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final meta = post.jobMeta;
    final canApply = !post.isOwnPost &&
        post.lifecycleState == JobLifecycleState.open &&
        post.applicationState == JobApplicationState.notApplied;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta.title != null)
            Text(meta.title!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (meta.description != null) ...[
            const SizedBox(height: 8),
            Text(meta.description!, style: const TextStyle(color: AppColors.authMuted)),
          ],
          if (meta.requirement != null) ...[
            const SizedBox(height: 8),
            Text('Requirements: ${meta.requirement}'),
          ],
          const SizedBox(height: 16),
          if (post.applicationState == JobApplicationState.applied)
            const Text('Applied', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600))
          else if (canApply)
            CustomButton(label: 'Apply CV', icon: Icons.description_outlined, onPressed: onApply)
          else if (!post.isOwnPost)
            const Text('Applications closed', style: TextStyle(color: AppColors.authMuted)),
        ],
      ),
    );
  }
}
