import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/home/widgets/poster_post_card.dart';
import 'package:aub_connect_app/modules/profile/profile_tabs_host.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_skills.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reels_card.dart';

class ProfileAllTab extends StatelessWidget {
  const ProfileAllTab({super.key, this.host});

  final ProfileTabsHost? host;

  @override
  Widget build(BuildContext context) {
    final controller = resolveProfileTabsHost(host);
    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return const LoadingWidget();
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          ProfileSkillsRow(skills: profile.skills),
          if (profile.skills.isNotEmpty) const SizedBox(height: 20),
          ProfileAllDetails(
            profile: profile,
            isOwnProfile: controller.isOwnProfile,
          ),
          ProfileAllPostsSection(host: host),
        ],
      );
    });
  }
}

/// All tab: display-only titled sections. Editing is only on Edit personal info.
class ProfileAllDetails extends StatelessWidget {
  const ProfileAllDetails({
    super.key,
    required this.profile,
    required this.isOwnProfile,
  });

  final UserProfileModel profile;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    final personal = <_AllRowData>[
      if (profile.location != null && profile.location!.trim().isNotEmpty)
        _AllRowData(Icons.location_on_outlined, profile.location!),
      if (profile.gender != null && profile.gender!.trim().isNotEmpty)
        _AllRowData(Icons.person_outline, profile.gender!),
      if (profile.dateOfBirth != null)
        _AllRowData(
          Icons.cake_outlined,
          DateFormat('MMMM dd yyyy').format(profile.dateOfBirth!),
        ),
      for (final extra in profile.personalExtras)
        if (extra.trim().isNotEmpty)
          _AllRowData(Icons.notes_outlined, extra),
    ];

    final work = <_AllRowData>[
      for (final job in profile.workItems)
        if (job.displayLabel.trim().isNotEmpty)
          _AllRowData(Icons.apartment_outlined, job.displayLabel),
    ];

    final education = <_AllRowData>[
      for (final edu in profile.educationItems) ...[
        if (edu.school.trim().isNotEmpty)
          _AllRowData(Icons.school_outlined, edu.school),
        if (edu.major != null && edu.major!.trim().isNotEmpty)
          _AllRowData(Icons.menu_book_outlined, edu.major!),
        if (edu.certificate != null && edu.certificate!.trim().isNotEmpty)
          _AllRowData(Icons.workspace_premium_outlined, edu.certificate!),
      ],
    ];

    final links = <_AllLinkData>[
      for (final link in profile.linkItems)
        if (link.url.trim().isNotEmpty)
          _AllLinkData(
            link.platform.trim().isEmpty ? link.url : link.platform,
            link.url,
          ),
    ];

    final contact = <_AllRowData>[
      if (isOwnProfile)
        for (final c in profile.contactItems) ...[
          if (c.phone != null && c.phone!.trim().isNotEmpty)
            _AllRowData(Icons.phone_outlined, c.phone!),
          if (c.email != null && c.email!.trim().isNotEmpty)
            _AllRowData(Icons.email_outlined, c.email!),
        ],
    ];

    final hasAny = personal.isNotEmpty ||
        work.isNotEmpty ||
        education.isNotEmpty ||
        links.isNotEmpty ||
        contact.isNotEmpty;

    if (!hasAny) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (personal.isNotEmpty) ...[
          _AllSection(title: 'Personal details', rows: personal),
          const SizedBox(height: 18),
        ],
        if (work.isNotEmpty) ...[
          _AllSection(title: 'Work', rows: work),
          const SizedBox(height: 18),
        ],
        if (education.isNotEmpty) ...[
          _AllSection(title: 'Education', rows: education),
          const SizedBox(height: 18),
        ],
        if (links.isNotEmpty) ...[
          _AllLinksSection(links: links),
          const SizedBox(height: 18),
        ],
        if (contact.isNotEmpty) ...[
          _AllSection(title: 'Contact info', rows: contact),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// Mixed reels + posters below Contact info — same data as Reels/Posters nav tabs.
class ProfileAllPostsSection extends StatefulWidget {
  const ProfileAllPostsSection({super.key, this.host});

  final ProfileTabsHost? host;

  @override
  State<ProfileAllPostsSection> createState() => _ProfileAllPostsSectionState();
}

class _ProfileAllPostsSectionState extends State<ProfileAllPostsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resolveProfileTabsHost(widget.host).ensureAllPostsLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = resolveProfileTabsHost(widget.host);
    return Obx(() {
      if (controller.isAllPostsLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: LoadingWidget(),
        );
      }

      final posts = controller.mergedReelsAndPosters;
      if (posts.isEmpty) {
        return EmptyStateWidget(
          title: 'No posts yet',
          subtitle: controller.isOwnProfile
              ? 'Your reels and posters will show here'
              : 'No posts to show',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Post',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: context.appColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          for (final post in posts)
            _AllPostTile(host: controller, post: post),
        ],
      );
    });
  }
}

class _AllPostTile extends StatelessWidget {
  const _AllPostTile({required this.host, required this.post});

  final ProfileTabsHost host;
  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    if (post.type == PostType.video) {
      return ProfileReelsCard(
        post: post,
        onLike: () {},
        onComment: () => host.openPost(post.id),
        onShare: () {},
      );
    }

    return PosterPostCard(
      post: post,
      margin: const EdgeInsets.symmetric(vertical: 5),
      showShareAction: false,
      onLike: () {},
      onComment: () {},
      onShare: () {},
      onFollow: () {},
      onOpen: () => host.openPost(post.id),
      onEdit: () => host.editPost(post),
      onDelete: () => host.deletePost(context, post),
    );
  }
}

class _AllRowData {
  const _AllRowData(this.icon, this.text);
  final IconData icon;
  final String text;
}

class _AllLinkData {
  const _AllLinkData(this.label, this.url);
  final String label;
  final String url;
}

class _AllSection extends StatelessWidget {
  const _AllSection({required this.title, required this.rows});

  final String title;
  final List<_AllRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 8),
        for (final row in rows) _DetailRow(icon: row.icon, text: row.text),
      ],
    );
  }
}

class _AllLinksSection extends StatelessWidget {
  const _AllLinksSection({required this.links});

  final List<_AllLinkData> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Links',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 8),
        for (final link in links)
          _LinkDetailRow(label: link.label, url: link.url),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.appColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                color: context.appColors.heading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkDetailRow extends StatelessWidget {
  const _LinkDetailRow({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid link')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showUrlAsLabel = label.startsWith('http');
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.link, size: 20, color: context.appColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                showUrlAsLabel ? url : label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
