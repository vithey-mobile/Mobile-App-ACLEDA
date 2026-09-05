import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';

class JobApplicantsController extends GetxController {
  JobApplicantsController(this._repository);

  final ProfileRepository _repository;

  final applicants = <JobApplicationModel>[].obs;
  final isLoading = true.obs;
  String? _jobPostId;
  String? _jobTitle;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as JobApplicantsArgs?;
    _jobPostId = args?.jobPostId;
    _jobTitle = args?.jobTitle;
    loadApplicants();
  }

  String get title => _jobTitle ?? 'Applicants';

  Future<void> loadApplicants() async {
    if (_jobPostId == null) return;
    isLoading.value = true;
    try {
      applicants.assignAll(await _repository.getJobApplicants(_jobPostId!));
    } finally {
      isLoading.value = false;
    }
  }

  void viewCv(JobApplicationModel application) {
    Get.toNamed(
      AppRoutes.applicantCvPreview,
      arguments: ApplicantCvArgs(
        applicationId: application.id,
        applicantName: application.applicantName,
        cvFileName: application.cvFileName,
      ),
    )?.then((_) => loadApplicants());
  }
}

class JobApplicantsScreen extends GetView<JobApplicantsController> {
  const JobApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.title)),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        if (controller.applicants.isEmpty) {
          return const EmptyStateWidget(title: 'No applicants yet', subtitle: 'Share your job post to get applications');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.applicants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final app = controller.applicants[index];
            return Card(
              child: ListTile(
                leading: UserAvatar(name: app.applicantName, radius: 22),
                title: Text(app.applicantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (app.headline != null) Text(app.headline!),
                    Text('Applied ${RelativeTime.format(app.appliedAt)}'),
                    Text(_statusLabel(app.status), style: TextStyle(color: _statusColor(app.status))),
                  ],
                ),
                trailing: TextButton(
                  onPressed: () => controller.viewCv(app),
                  child: const Text('View CV'),
                ),
                onTap: () => controller.viewCv(app),
              ),
            );
          },
        );
      }),
    );
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.reviewed:
        return 'Reviewed';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      default:
        return AppColors.pending;
    }
  }
}

class JobApplicantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JobApplicantsController(Get.find<ProfileRepository>()));
  }
}
