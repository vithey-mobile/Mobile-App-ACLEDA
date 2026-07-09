import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:intl/intl.dart';

class ChatSharedTabs extends StatelessWidget {
  const ChatSharedTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const tabs = [
    AppStrings.chatMedias,
    AppStrings.chatVideos,
    AppStrings.chatFiles,
    AppStrings.chatLinks,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final active = index == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(index),
            child: Column(
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    color: active ? AppColors.primary : context.appColors.muted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  color: active ? AppColors.primary : Colors.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class SharedMediaGrid extends StatelessWidget {
  const SharedMediaGrid({
    super.key,
    this.itemCount = 0,
    this.imageUrls = const [],
  });

  final int itemCount;
  final List<String> imageUrls;

  int get _count => imageUrls.isNotEmpty ? imageUrls.length : itemCount;

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return const EmptyStateWidget(
        icon: Icons.image_outlined,
        title: AppStrings.chatNoSharedMedia,
        subtitle: AppStrings.chatNoSharedMediaSubtitle,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _count,
      itemBuilder: (_, index) {
        final url = imageUrls.isNotEmpty ? imageUrls[index] : null;
        return Container(
          decoration: BoxDecoration(
            color: context.appColors.inputFill,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: url == null
              ? Icon(Icons.image_outlined, color: context.appColors.muted)
              : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
        );
      },
    );
  }
}

class SharedVideoGrid extends StatelessWidget {
  const SharedVideoGrid({
    super.key,
    this.itemCount = 0,
    this.videoUrls = const [],
  });

  final int itemCount;
  final List<String> videoUrls;

  int get _count => videoUrls.isNotEmpty ? videoUrls.length : itemCount;

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return const EmptyStateWidget(
        icon: Icons.videocam_outlined,
        title: AppStrings.chatNoSharedMedia,
        subtitle: AppStrings.chatNoSharedMediaSubtitle,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _count,
      itemBuilder: (_, index) {
        final url = videoUrls.isNotEmpty ? videoUrls[index] : null;
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.appColors.inputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: url == null
                  ? null
                  : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
            ),
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SharedFileTile extends StatelessWidget {
  const SharedFileTile({
    super.key,
    required this.fileName,
    required this.sizeLabel,
    required this.dateLabel,
  });

  final String fileName;
  final String sizeLabel;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '$sizeLabel, $dateLabel',
                  style: TextStyle(fontSize: 12, color: context.appColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SharedFilesList extends StatelessWidget {
  const SharedFilesList({super.key, required this.files});

  final List<({String name, String size, DateTime date})> files;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.insert_drive_file_outlined,
        title: AppStrings.chatNoSharedFiles,
        subtitle: AppStrings.chatNoSharedMediaSubtitle,
      );
    }
    final format = DateFormat('dd.MM.yy \'at\' h:mma');
    return Column(
      children: files
          .map(
            (f) => SharedFileTile(
              fileName: f.name,
              sizeLabel: f.size,
              dateLabel: format.format(f.date),
            ),
          )
          .toList(),
    );
  }
}

class SharedLinkTile extends StatelessWidget {
  const SharedLinkTile({
    super.key,
    required this.title,
    required this.description,
    required this.url,
  });

  final String title;
  final String description;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.appColors.inputFill,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.link, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: context.appColors.muted)),
                const SizedBox(height: 4),
                Text(url, style: const TextStyle(fontSize: 13, color: AppColors.info)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SharedLinksList extends StatelessWidget {
  const SharedLinksList({super.key, required this.links});

  final List<({String month, String title, String description, String url})> links;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.link_outlined,
        title: AppStrings.chatNoSharedLinks,
        subtitle: AppStrings.chatNoSharedMediaSubtitle,
      );
    }
    final grouped = <String, List<({String title, String description, String url})>>{};
    for (final link in links) {
      grouped.putIfAbsent(link.month, () => []).add(
            (title: link.title, description: link.description, url: link.url),
          );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(entry.key, style: TextStyle(color: context.appColors.muted, fontSize: 13)),
          ),
          for (final item in entry.value)
            SharedLinkTile(
              title: item.title,
              description: item.description,
              url: item.url,
            ),
        ],
      ],
    );
  }
}

class ChatQuickActionsRow extends StatelessWidget {
  const ChatQuickActionsRow({
    super.key,
    required this.onProfile,
    this.onCall,
    this.onVideo,
    this.onMute,
  });

  final VoidCallback onProfile;
  final VoidCallback? onCall;
  final VoidCallback? onVideo;
  final VoidCallback? onMute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: context.appColors.subtleShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionItem(icon: Icons.person_outline, label: AppStrings.chatProfileAction, onTap: onProfile),
          if (onCall != null)
            _ActionItem(icon: Icons.call_outlined, label: AppStrings.chatCallAction, onTap: onCall!)
          else
            _ActionItem(icon: Icons.call_outlined, label: AppStrings.chatCallAction, onTap: null),
          if (onVideo != null)
            _ActionItem(icon: Icons.videocam_outlined, label: AppStrings.chatVideoAction, onTap: onVideo!)
          else
            _ActionItem(icon: Icons.videocam_outlined, label: AppStrings.chatVideoAction, onTap: null),
          if (onMute != null)
            _ActionItem(icon: Icons.mic_off_outlined, label: AppStrings.chatMuteAction, onTap: onMute!)
          else
            _ActionItem(icon: Icons.mic_off_outlined, label: AppStrings.chatMuteAction, onTap: null),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: context.appColors.muted)),
          ],
        ),
      ),
    );
  }
}

class ChatContactInfoCard extends StatelessWidget {
  const ChatContactInfoCard({
    super.key,
    this.phone,
    this.bio,
  });

  final String? phone;
  final String? bio;

  @override
  Widget build(BuildContext context) {
    if ((phone == null || phone!.isEmpty) && (bio == null || bio!.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (phone != null && phone!.isNotEmpty)
            _InfoRow(
              icon: Icons.phone_outlined,
              value: phone!,
              label: AppStrings.chatMobile,
            ),
          if (phone != null && phone!.isNotEmpty && bio != null && bio!.isNotEmpty)
            const SizedBox(height: 14),
          if (bio != null && bio!.isNotEmpty)
            _InfoRow(
              icon: Icons.info_outline,
              value: bio!,
              label: AppStrings.chatBio,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 12, color: context.appColors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}
