import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/modules/search/widgets/search_highlight_text.dart';

class SearchPersonTile extends StatelessWidget {
  const SearchPersonTile({
    super.key,
    required this.person,
    required this.query,
    required this.onTap,
    required this.onMessage,
  });

  final UserSearchResult person;
  final String query;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserAvatar(
                name: person.fullName, imageUrl: person.avatarUrl, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchHighlightText(
                    text: person.fullName,
                    query: query,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.heading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    person.subtitle,
                    style: TextStyle(fontSize: 13, color: colors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline,
                  color: colors.muted, size: 22),
              onPressed: onMessage,
              tooltip: 'Message',
            ),
          ],
        ),
      ),
    );
  }
}
