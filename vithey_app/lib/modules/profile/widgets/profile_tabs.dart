import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/modules/apply_cv/models/application_status_args.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/home/widgets/poster_post_card.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_job_card.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_skills.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_video_card.dart';
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          ProfileSkillsRow(skills: profile.skills),
          if (profile.skills.isNotEmpty) const SizedBox(height: 20),
          ProfileAboutDetails(
            profile: profile,
            isOwnProfile: controller.isOwnProfile,
          ),
        ],
      );
    });
  }
}

class ProfilePostersTab extends StatelessWidget {
  const ProfilePostersTab({super.key});

  @override
  Widget build(BuildContext context) => const _ProfilePostsTab(type: PostType.poster);
}

class ProfileVideosTab extends StatelessWidget {
  const ProfileVideosTab({super.key});

  @override
  Widget build(BuildContext context) => const _ProfilePostsTab(type: PostType.video);
}

class ProfileJobsTab extends StatelessWidget {
  const ProfileJobsTab({super.key});

  @override
  Widget build(BuildContext context) => const _ProfilePostsTab(type: PostType.job);
}

class ProfileAppliedJobsTab extends StatelessWidget {
  const ProfileAppliedJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Obx(() {
      if (controller.appliedJobsLoading.value && controller.appliedJobs.isEmpty) {
        return const LoadingWidget();
      }
      if (controller.appliedJobs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: EmptyStateWidget(
            icon: Icons.description_outlined,
            title: 'No apply job history',
            subtitle: "You don't have any apply job history.",
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: controller.appliedJobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = controller.appliedJobs[index];
          return Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Get.toNamed(
                AppRoutes.applicationStatus,
                arguments: ApplicationStatusArgs(
                  applicationId: job.id,
                  jobPostId: job.jobPostId,
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.appColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.jobTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: context.appColors.heading,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${job.company} · ${RelativeTime.format(job.appliedAt)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.appColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StatusPill(status: job.status),
                  ],
                ),
              ),
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
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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

      if (type == PostType.video) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: posts.length,
          itemBuilder: (_, index) {
            final post = posts[index];
            return ProfileVideoCard(
              post: post,
              onLike: () {},
              onComment: () {},
              onShare: () {},
            );
          },
        );
      }

      if (type == PostType.job) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: posts.length,
          itemBuilder: (_, index) {
            final post = posts[index];
            return ProfileJobCard(
              post: post,
              isOwnProfile: controller.isOwnProfile,
              onOpenApplicants: () => controller.openJobApplicants(post),
              onApply: () => controller.applyToJob(post.id),
              onOpenPost: () => controller.openPost(post.id),
              onEdit: () => controller.editJobPost(post),
              onDelete: () => controller.deleteJobPost(post),
            );
          },
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: posts.length,
        itemBuilder: (_, index) {
          final post = posts[index];
          return PosterPostCard(
            post: post,
            margin: const EdgeInsets.symmetric(vertical: 6),
            actionsAlignStart: true,
            onLike: () {},
            onComment: () {},
            onShare: () {},
            onFollow: () {},
            onOpen: () => controller.openPost(post.id),
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
