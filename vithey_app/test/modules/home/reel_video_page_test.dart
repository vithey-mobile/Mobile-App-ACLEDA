import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/modules/home/reels/widgets/reel_video_page.dart';

void main() {
  testWidgets('ReelVideoPage renders action rail and post details without error',
      (tester) async {
    final post = FeedPost(
      id: 'test_reel_1',
      type: PostType.video,
      author: const PostAuthor(
        id: 'author_1',
        fullName: 'Bopha Pich',
        avatarUrl: null,
      ),
      content: 'Campus walk at AUB! Check out the new library.',
      mediaUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl: null,
      durationSeconds: 15,
      createdAt: DateTime(2026, 9, 10),
      viewCount: 1200,
      reactionCount: 450,
      commentCount: 32,
      shareCount: 12,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReelVideoPage(
            post: post,
            isActive: false,
            muted: true,
            onToggleMute: () {},
            onLike: () {},
            onComment: () {},
            onAuthorTap: () {},
            bottomInset: 0,
          ),
        ),
      ),
    );

    // Initial render before video init
    expect(find.text('Bopha Pich'), findsOneWidget);
    expect(find.textContaining('Campus walk at AUB'), findsOneWidget);
    expect(find.text('450'), findsOneWidget);
    expect(find.text('32'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
}
