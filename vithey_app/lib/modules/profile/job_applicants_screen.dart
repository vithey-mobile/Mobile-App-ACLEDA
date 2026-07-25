import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/widgets/application_feedback_success.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class JobApplicantsController extends GetxController {
  JobApplicantsController(this._repository);

  final ProfileRepository _repository;

  final applicants = <JobApplicationModel>[].obs;
  final isLoading = true.obs;
  String? _jobPostId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as JobApplicantsArgs?;
    _jobPostId = args?.jobPostId;
    loadApplicants();
  }

  Future<void> loadApplicants() async {
    if (_jobPostId == null) return;
    isLoading.value = true;
    try {
      applicants.assignAll(await _repository.getJobApplicants(_jobPostId!));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> accept(JobApplicationModel application) async {
    await _repository.updateApplicationStatus(application.id, ApplicationStatus.accepted);
    await loadApplicants();
    _showFeedbackSuccess();
  }

  Future<void> reject(JobApplicationModel application) async {
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
    await _repository.updateApplicationStatus(application.id, ApplicationStatus.rejected);
    await loadApplicants();
    _showFeedbackSuccess();
  }

  void viewDetails(JobApplicationModel application) {
    if (_jobPostId == null) return;
    Get.toNamed(
      AppRoutes.applicantDetail,
      arguments: ApplicantDetailArgs(
        applicationId: application.id,
        jobPostId: _jobPostId!,
      ),
    )?.then((_) => loadApplicants());
  }

  void _showFeedbackSuccess() {
    ApplicationFeedbackSuccess.show();
  }
}

class JobApplicantsScreen extends GetView<JobApplicantsController> {
  const JobApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application list', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        if (controller.applicants.isEmpty) {
          return const EmptyStateWidget(
            title: 'No applicants yet',
            subtitle: 'Share your job post to get applications',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.applicants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) => _ApplicantCard(
            application: controller.applicants[index],
            onAccept: () => controller.accept(controller.applicants[index]),
            onReject: () => controller.reject(controller.applicants[index]),
            onDetails: () => controller.viewDetails(controller.applicants[index]),
          ),
        );
      }),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.application,
    required this.onAccept,
    required this.onReject,
    required this.onDetails,
  });

  final JobApplicationModel application;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onDetails;

  String get _rankLabel => switch (application.rank) {
        1 => '1st',
        2 => '2nd',
        3 => '3rd',
        _ => '${application.rank}th',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.applicantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (application.headline != null)
                        Text(application.headline!, style: TextStyle(color: context.appColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _rankLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (application.location != null)
              _InfoLine(icon: Icons.location_on_outlined, text: application.location!),
            if (application.email != null)
              _InfoLine(icon: Icons.email_outlined, text: application.email!),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                RelativeTime.format(application.appliedAt),
                style: TextStyle(fontSize: 12, color: context.appColors.muted),
              ),
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    onPressed: application.status == ApplicationStatus.accepted
                        ? null
                        : onAccept,
                    background: Theme.of(context).colorScheme.primary,
                    foreground: Colors.white,
                    disabledBackground: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    onPressed: application.status == ApplicationStatus.rejected
                        ? null
                        : onReject,
                    background: const Color(0xFFE76363),
                    foreground: Colors.white,
                    disabledBackground:
                        const Color(0xFFE76363).withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Details',
                    onPressed: onDetails,
                    background: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF3A3A4E)
                        : const Color(0xFFE8E8EC),
                    foreground: context.appColors.heading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.disabledBackground,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final Color? disabledBackground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: disabledBackground ?? background.withValues(alpha: 0.4),
          disabledForegroundColor: foreground.withValues(alpha: 0.7),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: foreground,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.appColors.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: context.appColors.muted, fontSize: 13))),
        ],
      ),
    );
  }
}

class JobApplicantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JobApplicantsController(Get.find<ProfileRepository>()));
  }
}
