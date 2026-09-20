import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/feed_action_bar.dart';
import 'package:aub_connect_app/modules/home/widgets/post_author_header.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/widgets/vithey_media_image.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.headerTrailing,
    this.body,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBodyTap,
    this.onReact,
    this.onAuthorTap,
    this.caption,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.showShareAction = true,
  });

  final FeedPost post;
  final Widget? headerTrailing;
  final Widget? body;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onBodyTap;
  final ValueChanged<PostReactionType>? onReact;
  final VoidCallback? onAuthorTap;
  final Widget? caption;
  final EdgeInsetsGeometry margin;
  final bool showShareAction;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      padding: EdgeInsets.zero,
      margin: margin,
      bordered: true,
      elevated: false,
      borderRadius: VitheyRadii.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostAuthorHeader(
              post: post, trailing: headerTrailing, onAuthorTap: onAuthorTap),
          if (caption != null)
            caption!
          else if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                post.content,
                style: context.text.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
          if (body != null) GestureDetector(onTap: onBodyTap, child: body),
          FeedActionBar(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
            onReact: onReact,
            showShareAction: showShareAction,
          ),
        ],
      ),
    );
  }
}

class PostMediaImage extends StatelessWidget {
  const PostMediaImage({
    super.key,
    this.url,
    this.urls,
    this.height,
  });

  final String? url;
  final List<String>? urls;
  final double? height;

  List<String> get _resolvedUrls {
    final fromList = (urls ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (fromList.isNotEmpty) return fromList;
    final single = url?.trim();
    if (single != null && single.isNotEmpty) return [single];
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedUrls;
    if (resolved.isEmpty) return const SizedBox.shrink();
    if (resolved.length == 1) {
      return _PostMediaFrame(
        height: height,
        child: _PostMediaTile(url: resolved.first),
      );
    }
    return _PostMediaCarousel(urls: resolved, height: height);
  }
}

class _PostMediaFrame extends StatelessWidget {
  const _PostMediaFrame({required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (height != null) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: child,
      );
    }
    return AspectRatio(
      aspectRatio: 1.04,
      child: ColoredBox(
        color: context.appColors.inputFill,
        child: child,
      ),
    );
  }
}

class _PostMediaCarousel extends StatefulWidget {
  const _PostMediaCarousel({required this.urls, this.height});

  final List<String> urls;
  final double? height;

  @override
  State<_PostMediaCarousel> createState() => _PostMediaCarouselState();
}

class _PostMediaCarouselState extends State<_PostMediaCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.urls.length;
    return _PostMediaFrame(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: count,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (_, index) => _PostMediaTile(url: widget.urls[index]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (index) {
                final active = index == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(VitheyRadii.pill),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '${_page + 1}/$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostMediaTile extends StatelessWidget {
  const _PostMediaTile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return VitheyMediaImage(
      url: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
