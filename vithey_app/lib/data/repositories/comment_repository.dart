import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';

class CommentRepository {
  CommentRepository(this._postRepository);

  final PostRepository _postRepository;

  static final mentionUsers = UserFixtures.mentionUsers();

  Future<List<CommentModel>> fetchComments({
    required String postId,
    int page = 1,
  }) {
    return _postRepository.fetchComments(postId, page: page);
  }

  Future<CommentModel> createComment({
    required String postId,
    required String text,
    required PostAuthor currentUser,
  }) {
    return _postRepository.createComment(
      postId: postId,
      text: text,
      currentUser: currentUser,
    );
  }

  List<PostAuthor> searchMentionUsers(String query) {
    final q = query.toLowerCase();
    if (q.isEmpty) return mentionUsers;
    return mentionUsers
        .where((u) => u.fullName.toLowerCase().contains(q))
        .toList();
  }
}
