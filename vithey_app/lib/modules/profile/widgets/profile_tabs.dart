import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/modules/apply_cv/models/application_status_args.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/home/widgets/poster_post_card.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_job_card.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_skills.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_video_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';

class ProfileAboutTab extends StatelessWidget {
  const ProfileAboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return const LoadingWidget();
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          ProfileSkillsRow(skills: profile.skills),
          if (profile.skills.isNotEmpty) const SizedBox(height: 20),
          ProfilePersonalDetails(
              profile: profile, isOwnProfile: controller.isOwnProfile),
          if (profile.telegramLink != null || profile.facebookLink != null) ...[
            const SizedBox(height: 20),
            const Text('Links',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (profile.telegramLink != null)
              _LinkRow(label: 'Telegram', url: profile.telegramLink!),
            if (profile.facebookLink != null)
              _LinkRow(label: 'Facebook', url: profile.facebookLink!),
          ],
        ],
      );
    });
  }
}

class ProfilePostersTab extends StatelessWidget {
  const ProfilePostersTab({super.key});

  @override
  Widget build(BuildContext context) =>
      const _ProfilePostsTab(type: PostType.poster);
}

class ProfileVideosTab extends StatelessWidget {
  const ProfileVideosTab({super.key});

  @override
  Widget build(BuildContext context) =>
      const _ProfilePostsTab(type: PostType.video);
}

class ProfileJobsTab extends StatelessWidget {
  const ProfileJobsTab({super.key});

  @override
  Widget build(BuildContext context) =>
      const _ProfilePostsTab(type: PostType.job);
}

class ProfileAppliedJobsTab extends StatelessWidget {
  const ProfileAppliedJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Obx(() {
      if (controller.appliedJobsLoading.value &&
          controller.appliedJobs.isEmpty) {
        return const LoadingWidget();
      }
      if (controller.appliedJobs.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.description_outlined,
          title: 'No apply job history',
          subtitle: "You don't have any apply job history.",
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemCount: controller.appliedJobs.length,
        itemBuilder: (context, index) {
          final job = controller.appliedJobs[index];
          return ListTile(
            title: Text(job.jobTitle,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle:
                Text('${job.company} · ${RelativeTime.format(job.appliedAt)}'),
            trailing: _StatusPill(status: job.status),
            onTap: () => Get.toNamed(
              AppRoutes.applicationStatus,
              arguments: ApplicationStatusArgs(
                  applicationId: job.id, jobPostId: job.jobPostId),
            ),
          );
        },
      );
    });
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ApplicationStatus.pending => ('Pending', AppColors.pending),
      ApplicationStatus.reviewed => ('Review', AppColors.info),
      ApplicationStatus.accepted => ('Accepted', AppColors.success),
      ApplicationStatus.rejected => ('Rejected', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _ProfilePostsTab extends StatelessWidget {
  const _ProfilePostsTab({required this.type});

  final PostType type;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Obx(() {
      if (controller.tabLoading[type]!.value &&
          controller.tabPosts[type]!.isEmpty) {
        return const LoadingWidget();
      }
      final posts = controller.tabPosts[type]!;
      if (posts.isEmpty) {
        return EmptyStateWidget(
          title: 'Nothing here yet',
          subtitle: controller.isOwnProfile
              ? 'Create your first ${_label(type)}'
              : 'No ${_label(type)} yet',
        );
      }

      if (type == PostType.video) {
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: posts.length,
          itemBuilder: (_, index) => ProfileVideoCard(
            post: posts[index],
            onTap: () => controller.openPost(posts[index].id),
          ),
        );
      }

      if (type == PostType.job) {
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: posts.length,
          itemBuilder: (_, index) => ProfileJobCard(
            post: posts[index],
            isOwnProfile: controller.isOwnProfile,
            onTap: () => controller.openPost(posts[index].id),
            onViewApplicants: () => controller.openJobApplicants(posts[index]),
            onApply: () => controller.applyToJob(posts[index].id),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: posts.length,
        itemBuilder: (_, index) {
          final post = posts[index];
          return PosterPostCard(
            post: post,
            onLike: () {},
            onComment: () {},
            onShare: () {},
            onFollow: () {},
            onOpen: () => controller.openPost(post.id),
            onEdit: () => controller.editPost(post),
            onDelete: () => controller.deletePost(context, post),
          );
        },
      );
    });
  }

  String _label(PostType type) {
    return switch (type) {
      PostType.poster => 'poster',
      PostType.video => 'video',
      PostType.job => 'job',
    };
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
      leading: Icon(Icons.link, color: context.appColors.muted, size: 20),
      title: Text(label),
      subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }
}
