import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class CreatePostController extends GetxController {
  CreatePostController(this._postRepository);

  final PostRepository _postRepository;

  final contentController = TextEditingController();
  final selectedType = Rxn<PostType>();
  final isPosting = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is PostType) selectedType.value = arg;
  }

  void selectType(PostType type) => selectedType.value = type;

  Future<void> publish() async {
    final type = selectedType.value;
    final content = contentController.text.trim();
    if (type == null) {
      errorMessage.value = 'Select a post type';
      return;
    }
    if (content.isEmpty) {
      errorMessage.value = 'Write something to post';
      return;
    }

    isPosting.value = true;
    errorMessage.value = '';
    try {
      final post = await _postRepository.createPost(
        type: type,
        content: content,
        jobMeta: type == PostType.job
            ? const JobMeta(title: 'New Job Opening', description: 'Apply now on Vithey')
            : null,
      );
      Get.back(result: post);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isPosting.value = false;
    }
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}

class CreatePostScreen extends GetView<CreatePostController> {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isPosting.value ? null : controller.publish,
                child: controller.isPosting.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Post'),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What is your post type?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() => Column(
                  children: [
                    _TypeTile(
                      icon: Icons.image_outlined,
                      label: 'Poster',
                      selected: controller.selectedType.value == PostType.poster,
                      onTap: () => controller.selectType(PostType.poster),
                    ),
                    _TypeTile(
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      selected: controller.selectedType.value == PostType.video,
                      onTap: () => controller.selectType(PostType.video),
                    ),
                    _TypeTile(
                      icon: Icons.work_outline,
                      label: 'Job',
                      selected: controller.selectedType.value == PostType.job,
                      onTap: () => controller.selectType(PostType.job),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            TextField(
              controller: controller.contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What\'s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.appColors.inputFill,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.appColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: context.appColors.muted),
                  const SizedBox(height: 8),
                  const Text('Media picker coming with file-service integration'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
              return Text(controller.errorMessage.value, style: const TextStyle(color: AppColors.error));
            }),
            const SizedBox(height: 16),
            Obx(() => CustomButton(
                  label: 'Publish',
                  isLoading: controller.isPosting.value,
                  onPressed: controller.publish,
                )),
          ],
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : context.appColors.muted),
      title: Text(label),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.primary : context.appColors.muted,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? AppColors.primary : context.appColors.border),
      ),
    );
  }
}

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatePostController>(() => CreatePostController(Get.find<PostRepository>()));
  }
}
