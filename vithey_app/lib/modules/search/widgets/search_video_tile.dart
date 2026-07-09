import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/modules/search/widgets/search_highlight_text.dart';

class SearchVideoTile extends StatelessWidget {
  const SearchVideoTile({
    super.key,
    required this.video,
    required this.query,
    required this.onTap,
  });

  final PostSearchResult video;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 48,
                    color: colors.inputFill,
                    child: video.thumbnailUrl != null
                        ? CachedNetworkImage(imageUrl: video.thumbnailUrl!, fit: BoxFit.cover)
                        : Icon(Icons.videocam_outlined, color: colors.muted),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SearchHighlightText(
                text: video.title,
                query: query,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.heading,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
