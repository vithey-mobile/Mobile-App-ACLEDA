import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/job_poster_card.dart';
import 'package:aub_connect_app/modules/home/widgets/poster_post_card.dart';
import 'package:aub_connect_app/modules/home/widgets/video_post_card.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileAboutTab extends StatelessWidget {
  const ProfileAboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return const LoadingWidget();
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Personal Detail'),
          _InfoRow('Name', profile.fullName),
          if (profile.university != null) _InfoRow('University', profile.university!),
          if (profile.major != null) _InfoRow('Major', profile.major!),
          if (profile.graduationYear != null) _InfoRow('Graduation', '${profile.graduationYear}'),
          const SizedBox(height: 16),
          _SectionTitle('Links'),
          if (profile.telegramLink != null)
            _LinkRow(label: 'Telegram', url: profile.telegramLink!),
          if (profile.facebookLink != null)
            _LinkRow(label: 'Facebook', url: profile.facebookLink!),
          if (profile.telegramLink == null && profile.facebookLink == null)
            Text(
              controller.isOwnProfile ? 'Add links in Edit Profile' : 'No public links',
              style: const TextStyle(color: AppColors.authMuted),
            ),
        ],
      );
    });
  }
}

class ProfilePostersTab extends StatelessWidget {
  const ProfilePostersTab({super.key});

  @override
  Widget build(BuildContext context) => _ProfilePostsTab(type: PostType.poster);
}

class ProfileVideosTab extends StatelessWidget {
  const ProfileVideosTab({super.key});

  @override
  Widget build(BuildContext context) => _ProfilePostsTab(type: PostType.video);
}

class ProfileJobsTab extends StatelessWidget {
  const ProfileJobsTab({super.key});

  @override
  Widget build(BuildContext context) => _ProfilePostsTab(type: PostType.job);
}

class _ProfilePostsTab extends StatelessWidget {
  const _ProfilePostsTab({required this.type});

  final PostType type;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Obx(() {
      if (controller.tabLoading[type]!.value && controller.tabPosts[type]!.isEmpty) {
        return const LoadingWidget();
      }
      final posts = controller.tabPosts[type]!;
      if (posts.isEmpty) {
        return EmptyStateWidget(
          title: 'Nothing here yet',
          subtitle: controller.isOwnProfile ? 'Create your first ${_label(type)}' : 'No ${_label(type)} yet',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: posts.length,
        itemBuilder: (_, index) {
          final post = posts[index];
          return _buildCard(controller, post);
        },
      );
    });
  }

  String _label(PostType type) {
    switch (type) {
      case PostType.poster:
        return 'poster';
      case PostType.video:
        return 'video';
      case PostType.job:
        return 'job';
    }
  }

  Widget _buildCard(ProfileController controller, FeedPost post) {
    switch (post.type) {
      case PostType.poster:
        return PosterPostCard(
          post: post,
          onLike: () {},
          onComment: () {},
          onShare: () {},
          onFollow: () {},
          onOpen: () => controller.openPost(post.id),
        );
      case PostType.video:
        return VideoPostCard(
          post: post,
          onLike: () {},
          onComment: () {},
          onShare: () {},
          onFollow: () {},
          onOpen: () => controller.openPost(post.id),
        );
      case PostType.job:
        return JobPosterCard(
          post: post,
          onLike: () {},
          onComment: () {},
          onShare: () {},
          onApply: () => controller.applyToJob(post.id),
          onViewApplicants: () => controller.openJobApplicants(post),
          onOpen: () => controller.openPost(post.id),
        );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.authMuted))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }
}
