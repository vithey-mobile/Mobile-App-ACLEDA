import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/models/story_item.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/story/story_viewer_screen.dart';

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

class _DummyPostRepository implements PostRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DummyJobApplicationRepository implements JobApplicationRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    Get.reset();
    Get.put<CurrentUserService>(_FakeCurrentUserService());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('StoryViewerScreen renders story with progress bars and reactions',
      (tester) async {
    final story1 = StoryItem(
      id: 'story_1',
      authorId: 'user_1',
      authorName: 'Sreynich Chan',
      gradientColors: const [Color(0xFF6366F1), Color(0xFF9333EA)],
      text: 'Final exams are finally over! 🎉',
      fontStyle: 'neon',
      sticker: '✨ Good Vibes',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    final story2 = StoryItem(
      id: 'story_2',
      authorId: 'user_1',
      authorName: 'Sreynich Chan',
      gradientColors: const [Color(0xFFF43F5E), Color(0xFFFB923C)],
      text: 'Coffee time at Brown Coffee ☕',
      fontStyle: 'bold',
      sticker: '☕ Coffee Break',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );

    final group = UserStoryGroup(
      authorId: 'user_1',
      authorName: 'Sreynich Chan',
      stories: [story1, story2],
      isOwn: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(
          storyGroups: [group],
          initialGroupIndex: 0,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(StoryViewerScreen), findsOneWidget);
    expect(find.text('Sreynich Chan'), findsOneWidget);
    expect(find.text('Final exams are finally over! 🎉'), findsOneWidget);
    expect(find.text('✨ Good Vibes'), findsOneWidget);

    // Emoji reaction buttons exist
    expect(find.text('❤️'), findsOneWidget);
    expect(find.text('🔥'), findsOneWidget);
    expect(find.text('😂'), findsOneWidget);

    // Tap on right half to advance to next story
    await tester.tapAt(const Offset(600, 300));
    await tester.pump(const Duration(milliseconds: 100));

    // Now story2 is displayed
    expect(find.text('Coffee time at Brown Coffee ☕'), findsOneWidget);
    expect(find.text('☕ Coffee Break'), findsOneWidget);
  });

  test('HomeController addUserStory updates mediaStories and storyGroups', () {
    final controller = HomeController(
      _DummyPostRepository(),
      _DummyJobApplicationRepository(),
    );

    // Initial state
    expect(controller.userStories.isEmpty, isTrue);
    final initialMedia = controller.mediaStories;
    expect(initialMedia.first.label, 'Add Story');
    expect(initialMedia.first.hasUnseen, isFalse);

    // Add user story with custom drag positions
    controller.addUserStory(
      text: 'My First Story!',
      fontStyle: 'neon',
      sticker: '✨ Good Vibes',
      gradientColors: const [Color(0xFF6366F1), Color(0xFF9333EA)],
      textDx: 15.0,
      textDy: -50.0,
      stickerDx: -20.0,
      stickerDy: 100.0,
    );

    expect(controller.userStories.length, 1);
    expect(controller.userStories.first.text, 'My First Story!');
    expect(controller.userStories.first.textDx, 15.0);
    expect(controller.userStories.first.textDy, -50.0);
    expect(controller.userStories.first.stickerDx, -20.0);
    expect(controller.userStories.first.stickerDy, 100.0);

    // Media header now shows "Your Story" with colorful ring
    final updatedMedia = controller.mediaStories;
    expect(updatedMedia.first.label, 'Your Story');
    expect(updatedMedia.first.hasUnseen, isTrue);

    // Story groups includes user story group
    final groups = controller.storyGroups;
    expect(groups.first.isOwn, isTrue);
    expect(groups.first.stories.first.text, 'My First Story!');

    // Delete story
    controller.deleteUserStory(controller.userStories.first.id);
    expect(controller.userStories.isEmpty, isTrue);
    expect(controller.mediaStories.first.label, 'Add Story');
  });

  testWidgets('StoryViewerScreen renders Gen-Z music vibe and interactive poll',
      (tester) async {
    final musicStory = StoryItem(
      id: 'story_music',
      authorId: 'user_1',
      authorName: 'Alex',
      gradientColors: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      text: 'Vibing at the library 🎧',
      vibeType: 'music',
      vibeData: 'Lo-Fi Campus Beats',
      textAlignment: 'center',
      hasVignette: true,
      createdAt: DateTime.now(),
    );

    final pollStory = StoryItem(
      id: 'story_poll',
      authorId: 'user_1',
      authorName: 'Alex',
      gradientColors: const [Color(0xFF064E3B), Color(0xFF10B981)],
      text: 'Big Question Today!',
      vibeType: 'poll',
      vibeData: 'Study or Sleep? 😴 / 📚',
      createdAt: DateTime.now(),
    );

    final group = UserStoryGroup(
      authorId: 'user_1',
      authorName: 'Alex',
      stories: [musicStory, pollStory],
      isOwn: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(
          storyGroups: [group],
          initialGroupIndex: 0,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify music vibe track name is rendered
    expect(find.text('Lo-Fi Campus Beats'), findsOneWidget);
    expect(find.text('Vibing at the library 🎧'), findsOneWidget);

    // Tap right half to advance to poll story
    await tester.tapAt(const Offset(600, 300));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify poll question and options are rendered
    expect(find.text('Study or Sleep?'), findsOneWidget);
    expect(find.text('😴'), findsWidgets);
  });
}
