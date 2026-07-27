import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/modules/apply_cv/apply_cv_controller.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/application_description_field.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/apply_job_context.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/apply_job_stepper.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/cv_upload_zone.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/privacy_footer_note.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/position_selector.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/review_cv_card.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/selected_cv_card.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/what_happens_next_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ApplyCvScreen extends GetView<ApplyCvController> {
  const ApplyCvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await controller.handleBack();
        if (shouldPop) Get.back();
      },
      child: Scaffold(
        backgroundColor: context.appColors.bodyBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.appColors.bodyBackground,
          foregroundColor: context.appColors.heading,
          title: const Text(AppStrings.applyJobTitle, style: TextStyle(fontWeight: FontWeight.bold)),
          leading: BackButton(
            onPressed: () async {
              final shouldPop = await controller.handleBack();
              if (shouldPop) Get.back();
            },
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.phase.value == ApplyCvPhase.loadingJob) {
              return const LoadingWidget();
            }
            if (controller.phase.value == ApplyCvPhase.error) {
              return AppErrorWidget(
                message: controller.submitError.value,
                onRetry: controller.retryLoad,
              );
            }

            final stepIndex = controller.currentStep.value == ApplyCvStep.upload ? 0 : 1;
            return Column(
              children: [
                ApplyJobStepper(currentStep: stepIndex),
                Expanded(
                  child: controller.currentStep.value == ApplyCvStep.upload
                      ? _UploadStep(controller: controller)
                      : _ReviewStep(controller: controller),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _UploadStep extends StatelessWidget {
  const _UploadStep({required this.controller});

  final ApplyCvController controller;

  @override
  Widget build(BuildContext context) {
    final eligible = controller.eligibility.value?.eligibility == JobEligibility.eligible;
    final enabled = eligible && !controller.isSubmitting.value;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text(
                    AppStrings.uploadYourCv,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.appColors.heading,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Text(
                    AppStrings.uploadCvSubtitle,
                    style: TextStyle(color: context.appColors.muted, fontSize: 14),
                  ),
                ),
                // Screen 1 mock has no job context block — only show when blocked.
                if (!eligible)
                  ApplyJobContext(
                    job: controller.job.value,
                    eligibility: controller.eligibility.value,
                    isLoading: false,
                    onRetry: controller.retryLoad,
                    compact: true,
                  ),
                if (eligible) ...[
                  PositionSelector(
                    positions: controller.availablePositions,
                    selected: controller.selectedPosition.value,
                    enabled: enabled,
                    onChanged: controller.selectPosition,
                  ),
                  _buildCvSection(enabled),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              if (controller.isAlreadyApplied)
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: AppStrings.viewApplicationStatus,
                    icon: Icons.visibility_outlined,
                    onPressed: controller.viewApplicationStatus,
                  ),
                )
              else if (!eligible)
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: AppStrings.back,
                    variant: CustomButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed:
                        controller.canContinue ? controller.goToReview : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: onPrimary,
                      disabledBackgroundColor: primary.withValues(alpha: 0.4),
                      disabledForegroundColor: onPrimary.withValues(alpha: 0.8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      AppStrings.continueLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              if (eligible) const PrivacyFooterNote(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCvSection(bool enabled) {
    final saved = controller.savedCv.value;
    final local = controller.localCv.value;
    final mode = controller.selectionMode.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          )
        else if (saved != null && mode == CvSelectionMode.saved)
          SavedSelectedCvCard(
            savedCv: saved,
            enabled: enabled,
            onReplace: () => controller.pickLocalCv(updateDefault: false),
            onRemove: controller.clearCvSelection,
          )
        else
          CvUploadZone(
            policyLabel: controller.acceptedPolicyLabel,
            enabled: enabled,
            onTap: () => controller.pickLocalCv(updateDefault: false),
          ),
        if (saved != null && mode != CvSelectionMode.saved && local == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: shad.Button.outline(
              onPressed: enabled ? controller.useSavedCv : null,
              leading: const Icon(Icons.description_outlined, color: AppColors.primary),
              child: shad.Text('${AppStrings.useSavedCv}: ${saved.fileName}'),
            ),
          ),
        if (controller.fileError.value.isNotEmpty && local == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              controller.fileError.value,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.controller});

  final ApplyCvController controller;

  @override
  Widget build(BuildContext context) {
    final enabled = !controller.isSubmitting.value;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text(
                    AppStrings.reviewYourCv,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text(
                    AppStrings.reviewCvSubtitle,
                    style: TextStyle(color: context.appColors.muted),
                  ),
                ),
                ReviewCvCard(
                  fileName: controller.selectedFileName,
                  sizeLabel: controller.selectedFileSizeLabel,
                  enabled: enabled,
                  onRemove: controller.removeCvAndGoBack,
                ),
                if (controller.showPositionSelector || controller.organizationName.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Applying for ${controller.positionLabel}'
                      '${controller.organizationName.isNotEmpty ? ' at ${controller.organizationName}' : ''}',
                      style: TextStyle(fontSize: 13, color: context.appColors.muted),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const WhatHappensNextList(),
                ApplicationDescriptionField(
                  controller: controller.descriptionController,
                  enabled: enabled,
                ),
                if (controller.submitError.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              CustomButton(
                label: controller.submitLabel.value,
                isLoading: controller.isSubmitting.value,
                onPressed: controller.canSubmit ? controller.submit : null,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: enabled ? controller.goToUpload : null,
                icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
                label: const Text(AppStrings.back, style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
