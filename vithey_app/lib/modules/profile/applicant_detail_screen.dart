import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/widgets/application_feedback_success.dart';
import 'package:aub_connect_app/modules/profile/widgets/experience_timeline.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_wavy_header.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
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
    isActionLoading.value = true;
    try {
      await _repository.updateApplicationStatus(current.applicationId, ApplicationStatus.accepted);
      detail.value = ApplicantDetailModel(
        applicationId: current.applicationId,
        jobPostId: current.jobPostId,
        jobTitle: current.jobTitle,
        applicantUserId: current.applicantUserId,
        applicantName: current.applicantName,
        headline: current.headline,
        location: current.location,
        email: current.email,
        avatarUrl: current.avatarUrl,
        status: ApplicationStatus.accepted,
        cvFileName: current.cvFileName,
        experience: current.experience,
        education: current.education,
      );
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
      detail.value = ApplicantDetailModel(
        applicationId: current.applicationId,
        jobPostId: current.jobPostId,
        jobTitle: current.jobTitle,
        applicantUserId: current.applicantUserId,
        applicantName: current.applicantName,
        headline: current.headline,
        location: current.location,
        email: current.email,
        avatarUrl: current.avatarUrl,
        status: ApplicationStatus.rejected,
        cvFileName: current.cvFileName,
        experience: current.experience,
        education: current.education,
      );
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
}

class ApplicantDetailScreen extends GetView<ApplicantDetailController> {
  const ApplicantDetailScreen({super.key});

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
        final profile = UserProfileModel(
          id: applicant.applicantUserId,
          fullName: applicant.applicantName,
          avatarUrl: applicant.avatarUrl,
          location: applicant.location,
          email: applicant.email,
        );

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  ProfileWavyHeader(profile: profile, showMenu: false),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apply position: ${applicant.jobTitle}',
                                style: TextStyle(color: context.appColors.muted, fontSize: 13),
                              ),
                              if (applicant.headline != null) ...[
                                const SizedBox(height: 4),
                                Text(applicant.headline!, style: const TextStyle(fontSize: 14)),
                              ],
                            ],
                          ),
                        ),
                        shad.Button.primary(
                          onPressed: controller.openApplicantProfile,
                          child: const shad.Text('View Profile'),
                        ),
                      ],
                    ),
                  ),
                  if (applicant.location != null)
                    _ContactRow(icon: Icons.location_on_outlined, text: applicant.location!),
                  if (applicant.email != null)
                    _ContactRow(icon: Icons.email_outlined, text: applicant.email!),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ExperienceTimeline(
                      title: 'Experience',
                      entries: applicant.experience,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ExperienceTimeline(
                      title: 'Education',
                      entries: applicant.education,
                    ),
                  ),
                ],
              ),
            ),
            _OwnerActionBar(
              status: applicant.status,
              hasCv: applicant.hasCv,
              isLoading: controller.isActionLoading.value,
              onAccept: controller.accept,
              onReject: controller.reject,
              onViewCv: controller.viewCv,
            ),
          ],
        );
      }),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.appColors.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: context.appColors.muted, fontSize: 13))),
        ],
      ),
    );
  }
}

class _OwnerActionBar extends StatelessWidget {
  const _OwnerActionBar({
    required this.status,
    required this.hasCv,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
    required this.onViewCv,
  });

  final ApplicationStatus status;
  final bool hasCv;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onViewCv;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: context.appColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: shad.Button.primary(
                onPressed: isLoading || status == ApplicationStatus.accepted ? null : onAccept,
                child: const shad.Text('Accept'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: shad.Button.destructive(
                onPressed: isLoading || status == ApplicationStatus.rejected ? null : onReject,
                child: const shad.Text('Reject'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: shad.Button.outline(
                onPressed: hasCv && !isLoading ? onViewCv : null,
                child: Text(hasCv ? 'View CV' : 'No CV'),
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
