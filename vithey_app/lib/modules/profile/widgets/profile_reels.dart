import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/profile/profile_tabs_host.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reels_card.dart';

class ProfileReelsTab extends StatelessWidget {
  const ProfileReelsTab({super.key, this.host});

  final ProfileTabsHost? host;

  @override
  Widget build(BuildContext context) {
    final controller = resolveProfileTabsHost(host);
    return Obx(() {
      if (controller.tabLoading[PostType.video]!.value &&
          controller.tabPosts[PostType.video]!.isEmpty) {
        return const LoadingWidget();
      }
      final posts = controller.tabPosts[PostType.video]!;
      if (posts.isEmpty) {
        return EmptyStateWidget(
          title: 'Nothing here yet',
          subtitle: controller.isOwnProfile
              ? 'Create your first Reels'
              : 'No Reels yet',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: posts.length,
        itemBuilder: (_, index) {
          final post = posts[index];
          return ProfileReelsCard(
            post: post,
            onLike: () {},
            onComment: () => controller.openPost(post.id),
            onShare: () {},
          );
        },
      );
    });
  }
}
