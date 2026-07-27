import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/widgets/application_feedback_success.dart';
import 'package:aub_connect_app/modules/profile/widgets/experience_timeline.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ApplicantDetailController extends GetxController {
  ApplicantDetailController(this._repository);

  final ProfileRepository _repository;

  final detail = Rxn<ApplicantDetailModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final isActionLoading = false.obs;

  String? _applicationId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as ApplicantDetailArgs?;
    _applicationId = args?.applicationId;
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (_applicationId == null) {
      hasError.value = true;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    hasError.value = false;
    try {
      detail.value = await _repository.getApplicantDetail(_applicationId!);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void openApplicantProfile() {
    final current = detail.value;
    if (current == null) return;
    Get.toNamed(AppRoutes.profile, arguments: ProfileArgs(userId: current.applicantUserId));
  }

  Future<void> accept() async {
    final current = detail.value;
    if (current == null || isActionLoading.value) return;

    final confirmed = await Get.dialog<bool>(
      shad.AlertDialog(
        title: const shad.Text('Accept applicant?'),
        content: const shad.Text('This applicant will be notified of your decision.'),
        actions: [
          shad.Button.ghost(onPressed: () => Get.back(result: false), child: const shad.Text('Cancel')),
          shad.Button.primary(onPressed: () => Get.back(result: true), child: const shad.Text('Accept')),
        ],
      ),
    );
    if (confirmed != true) return;

    isActionLoading.value = true;
    try {
      await _repository.updateApplicationStatus(current.applicationId, ApplicationStatus.accepted);
      detail.value = _copyWithStatus(current, ApplicationStatus.accepted);
      ApplicationFeedbackSuccess.show();
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> reject() async {
    final current = detail.value;
    if (current == null || isActionLoading.value) return;

    final confirmed = await Get.dialog<bool>(
      shad.AlertDialog(
        title: const shad.Text('Reject applicant?'),
        content: const shad.Text('This applicant will be notified of your decision.'),
        actions: [
          shad.Button.ghost(onPressed: () => Get.back(result: false), child: const shad.Text('Cancel')),
          shad.Button.destructive(onPressed: () => Get.back(result: true), child: const shad.Text('Reject')),
        ],
      ),
    );
    if (confirmed != true) return;

    isActionLoading.value = true;
    try {
      await _repository.updateApplicationStatus(current.applicationId, ApplicationStatus.rejected);
      detail.value = _copyWithStatus(current, ApplicationStatus.rejected);
      ApplicationFeedbackSuccess.show();
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> viewCv() async {
    final current = detail.value;
    if (current == null || !current.hasCv) return;

    Get.toNamed(
      AppRoutes.applicantCvPreview,
      arguments: ApplicantCvArgs(
        applicationId: current.applicationId,
        applicantName: current.applicantName,
        cvFileName: current.cvFileName,
      ),
    );
  }

  ApplicantDetailModel _copyWithStatus(ApplicantDetailModel current, ApplicationStatus status) {
    return ApplicantDetailModel(
      applicationId: current.applicationId,
      jobPostId: current.jobPostId,
      jobTitle: current.jobTitle,
      applicantUserId: current.applicantUserId,
      applicantName: current.applicantName,
      headline: current.headline,
      location: current.location,
      email: current.email,
      avatarUrl: current.avatarUrl,
      status: status,
      cvFileName: current.cvFileName,
      experience: current.experience,
      education: current.education,
    );
  }
}

class ApplicantDetailScreen extends GetView<ApplicantDetailController> {
  const ApplicantDetailScreen({super.key});

  static const _coverTeal = Color(0xFF7DDAD6);
  static const _decorTeal = Color(0xFF2A9E99);
  static const _avatarRadius = 40.0;
  static const _pagePad = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final name = controller.detail.value?.applicantName;
          return Text(name ?? 'Applicant', style: const TextStyle(fontWeight: FontWeight.bold));
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        if (controller.hasError.value || controller.detail.value == null) {
          return AppErrorWidget(
            message: 'Could not load applicant details',
            onRetry: controller.loadDetail,
          );
        }

        final applicant = controller.detail.value!;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _ApplicantCoverHeader(
                    name: applicant.applicantName,
                    avatarUrl: applicant.avatarUrl,
                    coverTeal: _coverTeal,
                    decorTeal: _decorTeal,
                    avatarRadius: _avatarRadius,
                    pagePad: _pagePad,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_pagePad, 0, _pagePad, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group 1: name + apply position (tight)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                applicant.applicantName,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            shad.Button.primary(
                              onPressed: controller.openApplicantProfile,
                              child: const shad.Text('View Profile'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Apply position: ${applicant.jobTitle}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Gap between profile group and contact group
                        const SizedBox(height: 20),
                        // Group 2: location + email (tight)
                        if (applicant.location != null)
                          _ContactRow(icon: Icons.location_on_outlined, text: applicant.location!),
                        if (applicant.location != null && applicant.email != null)
                          const SizedBox(height: 2),
                        if (applicant.email != null)
                          _ContactRow(icon: Icons.email_outlined, text: applicant.email!),
                        const SizedBox(height: 28),
                        ExperienceTimeline(
                          title: 'Experience',
                          entries: applicant.experience,
                        ),
                        const SizedBox(height: 28),
                        ExperienceTimeline(
                          title: 'Education',
                          entries: applicant.education,
                          useEducationIcon: true,
                        ),
                        const SizedBox(height: 28),
                        _CurriculumVitaeCard(
                          fileName: applicant.cvFileName,
                          hasCv: applicant.hasCv,
                          onTap: controller.viewCv,
                          onDownload: controller.viewCv,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _OwnerActionBar(
              status: applicant.status,
              isLoading: controller.isActionLoading.value,
              onAccept: controller.accept,
              onReject: controller.reject,
            ),
          ],
        );
      }),
    );
  }
}

class _ApplicantCoverHeader extends StatelessWidget {
  const _ApplicantCoverHeader({
    required this.name,
    required this.avatarUrl,
    required this.coverTeal,
    required this.decorTeal,
    required this.avatarRadius,
    required this.pagePad,
  });

  final String name;
  final String? avatarUrl;
  final Color coverTeal;
  final Color decorTeal;
  final double avatarRadius;
  final double pagePad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pagePad, pagePad, pagePad, avatarRadius + 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: coverTeal,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: _decorIcons(decorTeal)),
          ),
          Positioned(
            left: 12,
            bottom: -avatarRadius + 4,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: UserAvatar(
                name: name,
                imageUrl: avatarUrl,
                radius: avatarRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _decorIcons(Color iconColor) {
    return [
      Positioned(
        left: 20,
        top: 32,
        child: Text(
          '</>',
          style: TextStyle(color: iconColor, fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ),
      Positioned(
        right: 28,
        top: 24,
        child: Icon(Icons.casino_outlined, color: iconColor, size: 28),
      ),
      Positioned(
        right: 72,
        top: 54,
        child: Icon(Icons.view_in_ar_outlined, color: iconColor, size: 26),
      ),
      Positioned(
        left: 78,
        top: 18,
        child: Icon(Icons.chat_bubble_outline, color: iconColor, size: 24),
      ),
      Positioned(
        right: 16,
        top: 78,
        child: Icon(Icons.star_outline, color: iconColor, size: 24),
      ),
      Positioned(
        left: 118,
        top: 50,
        child: Icon(Icons.auto_awesome_outlined, color: iconColor, size: 22),
      ),
    ];
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.appColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: context.appColors.muted, fontSize: 13)),
        ),
      ],
    );
  }
}

class _CurriculumVitaeCard extends StatelessWidget {
  const _CurriculumVitaeCard({
    required this.fileName,
    required this.hasCv,
    required this.onTap,
    required this.onDownload,
  });

  final String? fileName;
  final bool hasCv;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  static const _previewHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final border = context.appColors.border;
    // Show only the original uploaded file name from the application.
    final displayName = fileName?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Curriculum Vitae', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        Material(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: _previewHeight,
                width: double.infinity,
                child: hasCv
                    ? InkWell(
                        onTap: onTap,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          // Thumbnail mock only — label uses application cvFileName.
                          child: Image.asset(
                            AppAssets.applicantCvPreview,
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _NoCvPlaceholder(onTap: null),
                          ),
                        ),
                      )
                    : const _NoCvPlaceholder(onTap: null),
              ),
              if (hasCv)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: context.appColors.muted.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      Icon(_fileIcon(displayName), color: AppColors.error, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          displayName == null || displayName.isEmpty ? 'CV' : displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Download',
                        onPressed: onDownload,
                        icon: Icon(Icons.download_outlined, color: context.appColors.muted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _fileIcon(String? name) {
    final lower = (name ?? '').toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) return Icons.description_outlined;
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp')) {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}

class _NoCvPlaceholder extends StatelessWidget {
  const _NoCvPlaceholder({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 40, color: context.appColors.muted),
          const SizedBox(height: 8),
          Text(
            'No CV Available',
            style: TextStyle(color: context.appColors.muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return InkWell(onTap: onTap, child: child);
  }
}

class _OwnerActionBar extends StatelessWidget {
  const _OwnerActionBar({
    required this.status,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
  });

  final ApplicationStatus status;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final acceptEnabled = !isLoading && status != ApplicationStatus.accepted;
    final rejectEnabled = !isLoading && status != ApplicationStatus.rejected;
    // Same teal as View Profile (`shad.Button.primary` → colorScheme.primary).
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: context.appColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: acceptEnabled ? onAccept : null,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.45),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                  surfaceTintColor: Colors.transparent,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: rejectEnabled ? onReject : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicantDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplicantDetailController(Get.find<ProfileRepository>()));
  }
}
