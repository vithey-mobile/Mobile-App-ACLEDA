import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/create_post/create_post_controller.dart';
import 'package:aub_connect_app/modules/create_post/widgets/create_post_media_zone.dart';
import 'package:aub_connect_app/modules/create_post/widgets/create_post_schedule_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class CreatePostScreen extends GetView<CreatePostController> {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          Obx(() => shad.Button.ghost(
                onPressed: controller.isPosting.value ? null : controller.publish,
                child: controller.isPosting.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const shad.Text('Post'),
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
            Obx(() => CreatePostMediaZone(
                  mediaPath: controller.mediaPath.value,
                  isVideo: controller.selectedType.value == PostType.video,
                  isUploading: controller.isUploadingMedia.value,
                  onPick: controller.showMediaSourceSheet,
                  onClear: controller.clearMedia,
                )),
            const SizedBox(height: 12),
            Obx(() {
              final scheduled = controller.scheduledAt.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_outlined),
                title: Text(scheduled == null ? 'Schedule post' : 'Scheduled'),
                subtitle: scheduled == null
                    ? const Text('Post now or pick a future time')
                    : Text(CreatePostScheduleSheet.format(scheduled)),
                trailing: scheduled == null
                    ? const Icon(Icons.chevron_right)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: controller.clearSchedule,
                      ),
                onTap: () => controller.pickSchedule(context),
              );
            }),
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
    Get.lazyPut<CreatePostController>(
      () => CreatePostController(Get.find<PostRepository>(), Get.find<UploadService>()),
    );
  }
}
