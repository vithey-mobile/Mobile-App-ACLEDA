import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/student_verification/widgets/verification_next_steps_card.dart';
import 'package:aub_connect_app/modules/student_verification/widgets/verification_status_card.dart';
import 'package:aub_connect_app/modules/student_verification/widgets/verification_timeline.dart';
import 'package:aub_connect_app/modules/student_verification/widgets/submitted_document_card.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class VerificationStatusController extends GetxController {
  VerificationStatusController(this._repository);

  final StudentVerificationRepository _repository;

  final verification = Rxn<StudentVerificationModel>();
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final provisioningStatus = FinanceProvisioningStatus.ready.obs;

  Timer? _pollTimer;
  int _pollCount = 0;

  @override
  void onInit() {
    super.onInit();
    loadVerificationStatus();
  }

  Future<void> loadVerificationStatus() async {
    isLoading.value = true;
    try {
      verification.value = await _repository.getMyVerification();
      _configurePolling();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshVerificationStatus() async {
    isRefreshing.value = true;
    try {
      if (_repository.useMockApi && verification.value?.status == VerificationStatus.pending && _pollCount >= 2) {
        verification.value = await _repository.refreshForMockApproval();
      } else {
        verification.value = await _repository.getMyVerification();
      }
      _pollCount++;
      _configurePolling();
    } finally {
      isRefreshing.value = false;
    }
  }

  void _configurePolling() {
    _pollTimer?.cancel();
    if (verification.value?.status == VerificationStatus.pending) {
      _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => refreshVerificationStatus());
    }
  }

  void openVerificationForm() => Get.toNamed(AppRoutes.studentVerification);

  void contactSupport() {
    final ref = verification.value?.id ?? 'N/A';
    final prompt = 'I need help with my student verification. Reference: $ref';
    Get.toNamed(AppRoutes.chatbot, arguments: prompt);
  }

  Future<void> continueToFinance() async {
    await refreshVerificationStatus();
    if (verification.value?.status == VerificationStatus.verified) {
      Get.offNamed(AppRoutes.finance);
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}

class VerificationStatusScreen extends GetView<VerificationStatusController> {
  const VerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: context.scheme.onSurface,
        elevation: 0,
        title: const Text('Verification Status', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();

        final data = controller.verification.value;
        if (data == null) {
          return const Center(child: Text('Could not load verification status'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshVerificationStatus,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(_subtitleFor(data.status), style: TextStyle(color: context.scheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              VerificationStatusCard(status: data.status),
              const SizedBox(height: 20),
              ..._buildBodyFor(context, data),
            ],
          ),
        );
      }),
    );
  }

  String _subtitleFor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Your verification is pending';
      case VerificationStatus.verified:
        return 'Your student status is confirmed';
      case VerificationStatus.rejected:
        return 'Your verification needs attention';
      case VerificationStatus.notSubmitted:
        return 'You have not submitted verification yet';
    }
  }

  List<Widget> _buildBodyFor(BuildContext context, StudentVerificationModel data) {
    switch (data.status) {
      case VerificationStatus.pending:
        return [
          VerificationTimeline(submittedAt: data.submittedAt),
          const SizedBox(height: 16),
          SubmittedDocumentCard(fileName: data.documentFileName ?? 'Student ID Card'),
          const SizedBox(height: 16),
          const VerificationNextStepsCard(),
          const SizedBox(height: 20),
          CustomButton(label: 'Contact Support', onPressed: controller.contactSupport),
        ];
      case VerificationStatus.verified:
        return [
          if (data.verifiedAt != null)
            Text('Verified on ${_formatDate(data.verifiedAt!)}', style: TextStyle(color: context.scheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          CustomButton(label: 'Continue to Finance', onPressed: controller.continueToFinance),
        ];
      case VerificationStatus.rejected:
        return [
          if (data.rejectionReason != null)
            Text(data.rejectionReason!, style: TextStyle(color: context.scheme.onSurface, height: 1.4)),
          const SizedBox(height: 20),
          CustomButton(label: 'Update and Resubmit', onPressed: controller.openVerificationForm),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Contact Support',
            variant: CustomButtonVariant.outline,
            onPressed: controller.contactSupport,
          ),
        ];
      case VerificationStatus.notSubmitted:
        return [
          const SizedBox(height: 8),
          CustomButton(label: 'Verify Student Status', onPressed: controller.openVerificationForm),
        ];
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
