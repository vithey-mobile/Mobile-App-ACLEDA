import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';

abstract final class CommentFixtures {
  static Map<String, List<CommentModel>> buildComments() {
    return {
      MockIds.post1: [
        CommentModel(
          id: 'comment-1',
          postId: MockIds.post1,
          author: UserFixtures.authorFor(MockIds.author2),
          text: 'Looks great! I will be there.',
          createdAt: MockClock.hoursAgo(1),
        ),
        CommentModel(
          id: 'comment-2',
          postId: MockIds.post1,
          author: UserFixtures.authorFor(MockIds.author1),
          text: 'Thanks everyone for the support!',
          createdAt: MockClock.minutesAgo(45),
        ),
      ],
      MockIds.post2: [
        CommentModel(
          id: 'comment-3',
          postId: MockIds.post2,
          author: UserFixtures.authorFor(MockIds.currentUser),
          text: 'Amazing showcase video!',
          createdAt: MockClock.hoursAgo(3),
        ),
        CommentModel(
          id: 'comment-4',
          postId: MockIds.post2,
          author: UserFixtures.authorFor(MockIds.author7),
          text: '@${UserFixtures.displayName(MockIds.currentUser)} can you share the project repo?',
          createdAt: MockClock.hoursAgo(2),
        ),
      ],
      MockIds.post3: [
        CommentModel(
          id: 'comment-5',
          postId: MockIds.post3,
          author: UserFixtures.authorFor(MockIds.author1),
          text: 'Is this open to final-year students only?',
          createdAt: MockClock.daysAgo(1),
        ),
      ],
    };
  }
}
