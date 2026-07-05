import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';

class CommentRepository {
  CommentRepository(this._postRepository);

  final PostRepository _postRepository;

  static const mentionUsers = [
    PostAuthor(id: 'author-1', fullName: 'Heng Liza'),
    PostAuthor(id: 'author-2', fullName: 'Molika Khorn'),
    PostAuthor(id: 'author-3', fullName: 'AUB Career Center'),
    PostAuthor(id: 'author-4', fullName: 'Vithey Admin'),
  ];

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
