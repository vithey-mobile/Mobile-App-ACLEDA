import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';

/// Feed / profile post mocks.
///
/// Usage split (no role picker):
/// - Logged-in user (**Poster / HR**): owns JOB posts `post-7`…`post-9`.
/// - `author-1` (**Applier / Student**): posters/videos only — no JOB posts.
/// - `post-10`: another user's open job — **not** seeded as applied (Apply CV demo).
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
        id: MockIds.post10,
        authorId: MockIds.author3,
        title: 'Web Developer',
        company: 'Aeon Mall',
        employmentType: 'Full-time',
        location: 'Phnom Penh, 32nd Street, SMC',
        mediaUrl: AppAssets.jobPost1,
        applicantCount: 2,
        createdAt: MockClock.hoursAgo(2),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _job(
        id: MockIds.post3,
        authorId: MockIds.author3,
        title: 'Multiple position',
        company: 'Chip Mong Group',
        employmentType: 'Full-time',
        location: 'Phnom Penh, Head Office',
        mediaUrl: AppAssets.jobPost1,
        applicantCount: 5,
        createdAt: MockClock.hoursAgo(5),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _job(
        id: MockIds.post4,
        authorId: MockIds.author3,
        title: 'Sales (Credit Officer) Intern',
        company: 'KDSB',
        employmentType: 'Internship',
        location: 'KDSB Branches & Head Office',
        mediaUrl: AppAssets.jobPost2,
        applicantCount: 12,
        createdAt: MockClock.daysAgo(3),
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
      _job(
        id: MockIds.post7,
        authorId: MockIds.currentUser,
        title: 'Call Center Officer',
        company: 'LOLC (Cambodia) Plc.',
        employmentType: 'Full-time',
        location: 'Phnom Penh, Head Office',
        mediaUrl: AppAssets.jobPost3,
        applicantCount: 8,
        createdAt: MockClock.monthsAgo(2),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _job(
        id: MockIds.post8,
        authorId: MockIds.currentUser,
        title: 'Young Talent, Finance',
        company: 'Chip Mong Group',
        employmentType: 'Internship',
        location: 'Phnom Penh',
        mediaUrl: AppAssets.jobPost1,
        applicantCount: 5,
        createdAt: MockClock.yearsAgo(1),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _job(
        id: MockIds.post9,
        authorId: MockIds.currentUser,
        title: 'Marketing Intern',
        company: 'KDSB',
        employmentType: 'Internship',
        location: 'Phnom Penh, 32nd Street, SMC',
        mediaUrl: AppAssets.jobPost2,
        applicantCount: 3,
        createdAt: MockClock.hoursAgo(18),
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
    required String company,
    required String employmentType,
    required String location,
    required String mediaUrl,
    required int applicantCount,
    required DateTime createdAt,
    required String currentUserId,
    required Set<String> reactedPosts,
    required Set<String> followedAuthors,
    JobApplicationState applicationState = JobApplicationState.notApplied,
  }) {
    return FeedPost(
      id: id,
      type: PostType.job,
      author: PostAuthor(id: authorId, fullName: UserFixtures.displayName(authorId)),
      content: location,
      mediaUrl: mediaUrl,
      jobMeta: JobMeta(
        title: title,
        description: company,
        requirement: employmentType,
      ),
      applicantCount: applicantCount,
      applicationState: applicationState,
      createdAt: createdAt,
      reactionCount: 20,
      commentCount: 4,
      shareCount: 1,
      userReacted: reactedPosts.contains(id),
      isFollowingAuthor: followedAuthors.contains(authorId),
      currentUserId: currentUserId,
    );
  }
}
