import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/modules/create_post/widgets/create_post_schedule_sheet.dart';

class CreatePostController extends GetxController {
  CreatePostController(this._postRepository, this._uploadService);

  final PostRepository _postRepository;
  final UploadService _uploadService;
  final _imagePicker = ImagePicker();

  final contentController = TextEditingController();
  final selectedType = Rxn<PostType>();
  final isPosting = false.obs;
  final isUploadingMedia = false.obs;
  final errorMessage = ''.obs;
  final mediaPath = RxnString();
  final mediaFileName = RxnString();
  final scheduledAt = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is PostType) selectedType.value = arg;
  }

  void selectType(PostType type) => selectedType.value = type;

  Future<void> showMediaSourceSheet() async {
    final type = selectedType.value;
    if (type == null) {
      errorMessage.value = 'Select a post type first';
      return;
    }

    final source = await Get.bottomSheet<ImageSource>(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(type == PostType.video ? 'Choose Video' : 'Choose from Library'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );
    if (source == null) return;
    await _pickMedia(source);
  }

  Future<void> _pickMedia(ImageSource source) async {
    final type = selectedType.value;
    if (type == null) return;

    final picked = type == PostType.video
        ? await _imagePicker.pickVideo(source: source)
        : await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    mediaPath.value = picked.path;
    mediaFileName.value = picked.name;
  }

  void clearMedia() {
    mediaPath.value = null;
    mediaFileName.value = null;
  }

  Future<void> pickSchedule(BuildContext context) async {
    final value = await CreatePostScheduleSheet.pick(context, initial: scheduledAt.value);
    if (value != null) scheduledAt.value = value;
  }

  void clearSchedule() => scheduledAt.value = null;

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
      String? mediaFileId;
      final path = mediaPath.value;
      if (path != null) {
        isUploadingMedia.value = true;
        final fileName = mediaFileName.value ?? path.split(RegExp(r'[\\/]')).last;
        final uploadType = type == PostType.video ? 'VIDEO' : 'POSTER';
        final mimeType = type == PostType.video ? 'video/mp4' : 'image/jpeg';
        final uploaded = await _uploadService.uploadPostMedia(
          filePath: path,
          fileName: fileName,
          mimeType: mimeType,
          type: uploadType,
        );
        mediaFileId = uploaded.fileId;
        isUploadingMedia.value = false;
      }

      final post = await _postRepository.createPost(
        type: type,
        content: content,
        mediaFileId: mediaFileId,
        scheduledAt: scheduledAt.value,
        jobMeta: type == PostType.job
            ? const JobMeta(title: 'New Job Opening', description: 'Apply now on Vithey')
            : null,
      );
      Get.back(result: post);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isPosting.value = false;
      isUploadingMedia.value = false;
    }
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
