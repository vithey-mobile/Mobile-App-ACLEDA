import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/modules/home/widgets/comment_sheet.dart';

class _FakePostRepository implements PostRepository {
  @override
  Future<List<CommentModel>> fetchComments(String postId, {int page = 1}) async {
    return [];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCurrentUserService extends GetxService implements CurrentUserService {
  @override
  String get userId => 'user_1';

  @override
  PostAuthor get postAuthor => const PostAuthor(
        id: 'user_1',
        fullName: 'Test User',
      );

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    Get.reset();
    Get.put<PostRepository>(_FakePostRepository());
    Get.put<CurrentUserService>(_FakeCurrentUserService());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('CommentSheet renders cleanly without overflow when keyboard is open', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 336 * 3);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });

    final dummyPost = FeedPost(
      id: 'post_1',
      type: PostType.poster,
      author: const PostAuthor(id: 'author_1', fullName: 'Author'),
      content: 'Test post',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: CommentSheet(
            post: dummyPost,
            onCommentAdded: () {},
            onCommentsRemoved: (_) {},
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byType(CommentSheet), findsOneWidget);
    expect(find.text('No comments yet'), findsOneWidget);
  });
}
