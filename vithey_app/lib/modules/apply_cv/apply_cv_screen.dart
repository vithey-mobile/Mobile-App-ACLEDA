import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/modules/apply_cv/apply_cv_controller.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/application_description_field.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/apply_job_context.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/cv_upload_zone.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/selected_cv_card.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class ApplyCvScreen extends GetView<ApplyCvController> {
  const ApplyCvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Upload CV', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.appColors.border),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.phase.value == ApplyCvPhase.loadingJob) {
            return const LoadingWidget();
          }

          final eligible = controller.eligibility.value?.eligibility == JobEligibility.eligible;
          final enabled = eligible && !controller.isSubmitting.value;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ApplyJobContext(
                        job: controller.job.value,
                        eligibility: controller.eligibility.value,
                        isLoading: false,
                        onRetry: controller.retryLoad,
                      ),
                      if (eligible) ...[
                        ApplicationDescriptionField(
                          controller: controller.descriptionController,
                          enabled: enabled,
                        ),
                        const SizedBox(height: 8),
                        _buildCvSection(enabled),
                      ],
                      if (controller.submitError.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            controller.submitError.value,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  label: controller.submitLabel.value,
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.canSubmit ? controller.submit : null,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCvSection(bool enabled) {
    final saved = controller.savedCv.value;
    final local = controller.localCv.value;
    final mode = controller.selectionMode.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (saved != null && local == null && mode == CvSelectionMode.saved)
          SavedSelectedCvCard(
            savedCv: saved,
            enabled: enabled,
            onReplace: () => controller.pickLocalCv(updateDefault: false),
            onRemove: controller.clearCvSelection,
          ),
        if (local != null)
          LocalSelectedCvCard(
            file: local,
            errorText: controller.fileError.value,
            enabled: enabled,
            showSaveAsDefault: mode == CvSelectionMode.localApplicationOnly,
            saveAsDefault: controller.saveAsDefault.value,
            onReplace: () => controller.pickLocalCv(updateDefault: mode == CvSelectionMode.localUpdateDefault),
            onRemove: controller.removeLocalCv,
            onSaveAsDefaultChanged: controller.toggleSaveAsDefault,
          ),
        if (saved != null && (local != null || mode != CvSelectionMode.saved))
          SavedCvOption(
            savedCv: saved,
            selected: mode == CvSelectionMode.saved,
            enabled: enabled,
            onSelect: controller.useSavedCv,
          ),
        if (local == null && mode != CvSelectionMode.saved)
          CvUploadZone(
            policyLabel: controller.acceptedPolicyLabel,
            enabled: enabled,
            onTap: () => controller.pickLocalCv(updateDefault: false),
            onUpdateDefault: () => controller.pickLocalCv(updateDefault: true),
          ),
      ],
    );
  }
}
