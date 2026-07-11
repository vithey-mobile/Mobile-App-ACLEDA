import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';

abstract final class PostFixtures {
  static List<FeedPost> allPosts({
    required String currentUserId,
    Set<String> reactedPosts = const {},
    Set<String> followedAuthors = const {},
  }) {
    return [
      _poster(
        id: MockIds.post1,
        authorId: MockIds.author1,
        content: 'Campus event this Friday! Join us for workshops and networking.',
        seed: 1,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _video(
        id: MockIds.post2,
        authorId: MockIds.author2,
        content: 'Highlights from last week\'s student showcase.',
        seed: 2,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _job(
        id: MockIds.post3,
        authorId: MockIds.author3,
        title: 'Multiple position · Aeon Mall',
        description: 'Support campus campaigns and social media.',
        seed: 3,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _job(
        id: MockIds.post4,
        authorId: MockIds.author3,
        title: 'Marketing Intern',
        description: 'Summer internship program for marketing students.',
        seed: 4,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _video(
        id: MockIds.post5,
        authorId: MockIds.currentUser,
        content: 'Student showcase highlights from last week.',
        seed: 5,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _poster(
        id: MockIds.post6,
        authorId: MockIds.author1,
        content: 'Heng Liza design portfolio launch event this weekend.',
        seed: 6,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
    ];
  }

  static List<FeedPost> feedPage({
    required int page,
    required String currentUserId,
    Set<String> reactedPosts = const {},
    Set<String> followedAuthors = const {},
  }) {
    final all = allPosts(
      currentUserId: currentUserId,
      reactedPosts: reactedPosts,
      followedAuthors: followedAuthors,
    );
    const pageSize = 3;
    if (page < 1 || page > 2) return [];
    final start = (page - 1) * pageSize;
    return all.skip(start).take(pageSize).toList();
  }

  static FeedPost? findPost(
    String postId, {
    required String currentUserId,
    Set<String> reactedPosts = const {},
    Set<String> followedAuthors = const {},
  }) {
    for (final post in allPosts(
      currentUserId: currentUserId,
      reactedPosts: reactedPosts,
      followedAuthors: followedAuthors,
    )) {
      if (post.id == postId) return post;
    }
    return null;
  }

  static FeedPost _poster({
    required String id,
    required String authorId,
    required String content,
    required int seed,
    required String currentUserId,
    required Set<String> reactedPosts,
    required Set<String> followedAuthors,
  }) {
    return FeedPost(
      id: id,
      type: PostType.poster,
      author: PostAuthor(id: authorId, fullName: UserFixtures.displayName(authorId)),
      content: content,
      mediaUrl: 'https://picsum.photos/seed/poster$seed/600/420',
      createdAt: MockClock.hoursAgo(seed * 2),
      reactionCount: 12 + seed,
      commentCount: 3 + seed,
      shareCount: seed,
      userReacted: reactedPosts.contains(id),
      isFollowingAuthor: followedAuthors.contains(authorId),
      currentUserId: currentUserId,
    );
  }

  static FeedPost _video({
    required String id,
    required String authorId,
    required String content,
    required int seed,
    required String currentUserId,
    required Set<String> reactedPosts,
    required Set<String> followedAuthors,
  }) {
    return FeedPost(
      id: id,
      type: PostType.video,
      author: PostAuthor(id: authorId, fullName: UserFixtures.displayName(authorId)),
      content: content,
      mediaUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vthumb$seed/600/340',
      durationSeconds: 95 + seed,
      createdAt: MockClock.hoursAgo(seed * 3),
      reactionCount: 45 + seed,
      commentCount: 8,
      shareCount: 2,
      userReacted: reactedPosts.contains(id),
      isFollowingAuthor: followedAuthors.contains(authorId),
      currentUserId: currentUserId,
    );
  }

  static FeedPost _job({
    required String id,
    required String authorId,
    required String title,
    required String description,
    required int seed,
    required String currentUserId,
    required Set<String> reactedPosts,
    required Set<String> followedAuthors,
    JobApplicationState applicationState = JobApplicationState.notApplied,
  }) {
    return FeedPost(
      id: id,
      type: PostType.job,
      author: PostAuthor(id: authorId, fullName: UserFixtures.displayName(authorId)),
      content: 'Job announcement! We are hiring interns for the summer program.',
      mediaUrl: 'https://picsum.photos/seed/job$seed/600/400',
      jobMeta: JobMeta(title: title, description: description),
      applicantCount: 5 + seed,
      applicationState: applicationState,
      createdAt: MockClock.daysAgo(seed),
      reactionCount: 20,
      commentCount: 4,
      shareCount: 1,
      userReacted: reactedPosts.contains(id),
      isFollowingAuthor: followedAuthors.contains(authorId),
      currentUserId: currentUserId,
    );
  }
}
