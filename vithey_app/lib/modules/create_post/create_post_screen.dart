import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/create_post/create_post_controller.dart';
import 'package:aub_connect_app/modules/create_post/widgets/create_post_media_zone.dart';
import 'package:intl/intl.dart';

class CreatePostScreen extends GetView<CreatePostController> {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: context.appColors.cardSurface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: context.appColors.cardSurface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            onPressed: () => _handleBack(context),
            tooltip: 'Back',
          ),
          title: Text(
            controller.isEditing ? 'Edit Post' : 'Post',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          actions: [
            Obx(() {
              controller.contentRevision.value;
              return _PublishAction(
                label: controller.isEditing
                    ? 'Save'
                    : controller.scheduledAt.value == null
                        ? 'Post'
                        : 'Schedule',
                enabled: controller.canPublish,
                loading: controller.isPosting.value,
                onPressed: controller.publish,
              );
            }),
            const SizedBox(width: 10),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              color: context.appColors.border,
            ),
          ),
        ),
        body: Column(
          children: [
            _AuthorAudienceRow(
              onAudienceTap: () => _showAudienceSheet(context),
            ),
            Obx(() {
              final scheduledAt = controller.scheduledAt.value;
              if (scheduledAt == null) return const SizedBox.shrink();
              return _ScheduleBanner(
                value: scheduledAt,
                onTap: () => controller.pickSchedule(context),
                onClear: controller.clearSchedule,
              );
            }),
            Expanded(child: _AdaptiveEditor(controller: controller)),
          ],
        ),
        bottomNavigationBar: _ComposerToolbar(
          onMedia: controller.showMediaSourceSheet,
          onSchedule: () => controller.pickSchedule(context),
          onCvLimit: () => _showCvLimitSheet(context),
          onCategory:
              controller.isEditing ? null : () => _showCategorySheet(context),
        ),
      ),
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final hasDraft = controller.hasUnsavedChanges;
    if (!hasDraft) {
      Get.back();
      return;
    }
    final discard = await showConfirmDialog(
      context: context,
      title: controller.isEditing ? 'Discard changes?' : 'Discard post?',
      message: controller.isEditing
          ? 'Your changes to this post will be lost.'
          : 'Your text, media, and schedule will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      variant: ConfirmDialogVariant.destructive,
    );
    if (discard == true) Get.back();
  }

  void _showAudienceSheet(BuildContext context) {
    Get.bottomSheet<void>(
      _AudienceSheet(controller: controller),
      backgroundColor: context.appColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    );
  }

  void _showCategorySheet(BuildContext context) {
    Get.bottomSheet<void>(
      _CategorySheet(controller: controller),
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    );
  }

  void _showCvLimitSheet(BuildContext context) {
    Get.bottomSheet<void>(
      _CvLimitSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    );
  }
}

class _AdaptiveEditor extends StatelessWidget {
  const _AdaptiveEditor({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mediaPath = controller.mediaPreviewPath;
      final isUploading = controller.isUploadingMedia.value;
      final error = controller.errorMessage.value;

      if (mediaPath == null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('expanded-composer-editor'),
                controller: controller.contentController,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: _editorStyle(context),
                decoration: _editorDecoration(context),
              ),
            ),
            if (error.isNotEmpty) _ComposerError(message: error),
          ],
        );
      }

      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const ValueKey('media-composer-editor'),
              controller: controller.contentController,
              minLines: 4,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: _editorStyle(context),
              decoration: _editorDecoration(context),
            ),
            CreatePostMediaZone(
              mediaPath: mediaPath,
              isVideo: controller.isVideo,
              isUploading: isUploading,
              onPick: controller.showMediaSourceSheet,
              onClear: controller.clearMedia,
            ),
            if (error.isNotEmpty) _ComposerError(message: error),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  TextStyle _editorStyle(BuildContext context) {
    return TextStyle(
      color: context.appColors.heading,
      fontSize: 15,
      height: 1.4,
    );
  }

  InputDecoration _editorDecoration(BuildContext context) {
    return InputDecoration(
      hintText: 'What\'s on your mind?',
      hintStyle: TextStyle(
        color: context.appColors.muted,
        fontSize: 15,
      ),
      filled: true,
      fillColor: context.appColors.cardSurface,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
    );
  }
}

class _ComposerError extends StatelessWidget {
  const _ComposerError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.scheme.errorContainer.withValues(alpha: 0.55),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        message,
        style: TextStyle(
          color: context.scheme.onErrorContainer,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PublishAction extends StatelessWidget {
  const _PublishAction({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: enabled ? context.scheme.primary : context.appColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled && !loading ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: label == 'Schedule' ? 76 : 54,
            height: 30,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.scheme.onPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: enabled
                            ? context.scheme.onPrimary
                            : context.appColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorAudienceRow extends GetView<CreatePostController> {
  const _AuthorAudienceRow({required this.onAudienceTap});

  final VoidCallback onAudienceTap;

  @override
  Widget build(BuildContext context) {
    final currentUser = Get.find<CurrentUserService>();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appColors.border)),
      ),
      child: Obx(
        () => Row(
          children: [
            UserAvatar(
              name: currentUser.displayName,
              imageUrl: currentUser.user.value?.avatarUrl,
              radius: 18,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                currentUser.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.appColors.heading,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Material(
              color: context.scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: onAudienceTap,
                borderRadius: BorderRadius.circular(13),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.audienceLabel,
                        style: TextStyle(
                          color: context.scheme.primary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: context.scheme.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleBanner extends StatelessWidget {
  const _ScheduleBanner({
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final DateTime value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat("EEE, MMM d 'at' h:mma").format(value);
    return Material(
      color: context.scheme.primary.withValues(alpha: 0.09),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 6, 9),
          child: Row(
            children: [
              Icon(
                Icons.public_rounded,
                color: context.scheme.primary,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Posting on $formatted. ',
                    children: const [
                      TextSpan(
                        text: 'Edit',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: context.appColors.heading,
                    fontSize: 11,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClear,
                tooltip: 'Clear schedule',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerToolbar extends GetView<CreatePostController> {
  const _ComposerToolbar({
    required this.onMedia,
    required this.onSchedule,
    required this.onCvLimit,
    required this.onCategory,
  });

  final VoidCallback onMedia;
  final VoidCallback onSchedule;
  final VoidCallback onCvLimit;
  final VoidCallback? onCategory;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        border: Border(top: BorderSide(color: context.appColors.border)),
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 2,
        shadowColor: context.appColors.subtleShadow,
        child: SafeArea(
          top: false,
          child: Obx(
            () => SizedBox(
              height: 55,
              child: Row(
                children: [
                  _ToolbarAction(
                    icon: Icons.image_outlined,
                    label: 'Media',
                    onTap: onMedia,
                  ),
                  _ToolbarAction(
                    icon: Icons.schedule_outlined,
                    label: 'Schedule',
                    onTap: onSchedule,
                  ),
                  if (controller.isJob)
                    _ToolbarAction(
                      icon: Icons.badge_outlined,
                      label: '${controller.cvLimit.value}',
                      onTap: onCvLimit,
                    ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onCategory,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.categoryLabel,
                              style: TextStyle(
                                color: context.scheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              onCategory == null
                                  ? Icons.lock_outline_rounded
                                  : Icons.arrow_drop_down_rounded,
                              color: context.scheme.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 62, minHeight: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: context.appColors.muted),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: context.appColors.muted,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceSheet extends StatelessWidget {
  const _AudienceSheet({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 15),
            Text(
              'Who can see your post?',
              style: TextStyle(
                color: context.appColors.heading,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: [
                  _ChoiceRow(
                    icon: Icons.public_rounded,
                    title: 'Public',
                    subtitle: 'Visible for everyone',
                    selected: controller.audience.value == PostAudience.public,
                    onTap: () {
                      controller.selectAudience(PostAudience.public);
                      Get.back();
                    },
                  ),
                  _ChoiceRow(
                    icon: Icons.people_outline_rounded,
                    title: 'Friends',
                    subtitle: controller.isJob
                        ? 'Job posts must be Public'
                        : 'Only friends can see this post',
                    selected: controller.audience.value == PostAudience.friends,
                    enabled: !controller.isJob,
                    onTap: () {
                      controller.selectAudience(PostAudience.friends);
                      Get.back();
                    },
                  ),
                  _ChoiceRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'Only Me',
                    subtitle: controller.isJob
                        ? 'Job posts must be Public'
                        : 'Only visible in my account',
                    selected: controller.audience.value == PostAudience.private,
                    enabled: !controller.isJob,
                    onTap: () {
                      controller.selectAudience(PostAudience.private);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 15),
            Text(
              'What is your post type?',
              style: TextStyle(
                color: context.appColors.heading,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: [
                  _ChoiceRow(
                    icon: Icons.image_outlined,
                    title: 'General',
                    subtitle: 'Community or social post',
                    selected: controller.selectedType.value == PostType.poster,
                    onTap: () {
                      controller.selectType(PostType.poster);
                      Get.back();
                    },
                  ),
                  _ChoiceRow(
                    icon: Icons.work_outline_rounded,
                    title: 'Job',
                    subtitle: 'Job announcement with Apply action',
                    selected: controller.selectedType.value == PostType.job,
                    onTap: () {
                      controller.selectType(PostType.job);
                      Get.back();
                    },
                  ),
                  _ChoiceRow(
                    icon: Icons.videocam_outlined,
                    title: 'Video',
                    subtitle: 'Share a video',
                    selected: controller.selectedType.value == PostType.video,
                    onTap: () {
                      controller.selectType(PostType.video);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CvLimitSheet extends StatefulWidget {
  const _CvLimitSheet({required this.controller});

  final CreatePostController controller;

  @override
  State<_CvLimitSheet> createState() => _CvLimitSheetState();
}

class _CvLimitSheetState extends State<_CvLimitSheet> {
  late final TextEditingController _amountController;
  int? _selectedPreset;
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = widget.controller.cvLimit.value;
    final isPreset = CreatePostController.cvLimitPresets.contains(current);
    _selectedPreset = isPreset ? current : null;
    _amountController = TextEditingController(
      text: isPreset ? '' : '$current',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectPreset(int limit) {
    setState(() {
      _selectedPreset = limit;
      _amountController.clear();
      _error = null;
    });
  }

  void _onCustomChanged(String value) {
    setState(() {
      if (value.trim().isNotEmpty) {
        _selectedPreset = null;
      }
      _error = null;
    });
  }

  void _confirm() {
    final error = widget.controller.applyCvLimitInput(
      preset: _selectedPreset,
      customAmount: _selectedPreset == null ? _amountController.text : null,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 18 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 12),
              Text(
                'Limit CV',
                style: TextStyle(
                  color: colors.heading,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              for (final limit in CreatePostController.cvLimitPresets)
                _CvLimitOptionRow(
                  label: '$limit',
                  selected: _selectedPreset == limit,
                  onTap: () => _selectPreset(limit),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: _onCustomChanged,
                onSubmitted: (_) => _confirm(),
                decoration: InputDecoration(
                  hintText: 'Insert amount',
                  hintStyle: TextStyle(color: colors.muted, fontSize: 14),
                  filled: true,
                  fillColor: colors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: context.scheme.primary,
                      width: 1.2,
                    ),
                  ),
                  errorText: _error,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.scheme.primary,
                    foregroundColor: context.scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CvLimitOptionRow extends StatelessWidget {
  const _CvLimitOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.appColors.heading,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color:
                  selected ? context.scheme.primary : context.appColors.muted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: ListTile(
        enabled: enabled,
        onTap: enabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 2),
        leading: Icon(icon, color: context.appColors.muted),
        title: Text(
          title,
          style: TextStyle(
            color: context.appColors.heading,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: context.appColors.muted, fontSize: 11.5),
        ),
        trailing: Icon(
          selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_off_rounded,
          color: selected ? context.scheme.primary : context.appColors.muted,
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: context.appColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatePostController>(
      () => CreatePostController(
          Get.find<PostRepository>(), Get.find<UploadService>()),
    );
  }
}
