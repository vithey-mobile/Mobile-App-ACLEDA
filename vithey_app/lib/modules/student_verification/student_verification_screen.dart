import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/student_verification/widgets/student_id_upload_box.dart';
import 'package:aub_connect_app/modules/student_verification/widgets/verification_info_card.dart';

class StudentVerificationController extends GetxController {
  StudentVerificationController(this._repository);

  final StudentVerificationRepository _repository;

  final studentIdController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final selectedDocumentName = RxnString();
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _prefillFromStatus();
  }

  Future<void> _prefillFromStatus() async {
    final current = await _repository.getMyVerification();
    if (current.studentId != null) studentIdController.text = current.studentId!;
    if (current.universityEmail != null) emailController.text = current.universityEmail!;
    if (current.documentFileName != null) selectedDocumentName.value = current.documentFileName;
  }

  Future<void> pickDocument() async {
    selectedDocumentName.value = 'student_id_card.pdf';
  }

  void removeDocument() => selectedDocumentName.value = null;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSubmitting.value) return;

    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final current = await _repository.getMyVerification();
      if (current.status == VerificationStatus.pending) {
        Get.offNamed(AppRoutes.verificationStatus);
        return;
      }
      if (current.status == VerificationStatus.verified) {
        Get.offNamed(AppRoutes.finance);
        return;
      }

      final result = await _repository.submitVerification(
        studentId: studentIdController.text.trim(),
        universityEmail: emailController.text.trim(),
        documentFileName: selectedDocumentName.value,
      );
      if (result.status == VerificationStatus.verified) {
        Get.offNamed(AppRoutes.finance);
      } else {
        Get.offNamed(AppRoutes.verificationStatus);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  String? validateStudentId(String? value) => _repository.validateStudentId(value ?? '');

  String? validateEmail(String? value) => _repository.validateUniversityEmail(value ?? '');

  @override
  void onClose() {
    studentIdController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

class StudentVerificationScreen extends GetView<StudentVerificationController> {
  const StudentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
        title: const Text('Student Verification', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CustomTextField(
                controller: controller.studentIdController,
                label: 'Student ID',
                hint: 'Enter your student ID',
                validator: controller.validateStudentId,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.emailController,
                label: 'Student Email',
                hint: 'your.email@aub.edu.kh',
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 20),
              Obx(() => StudentIdUploadBox(
                    fileName: controller.selectedDocumentName.value,
                    onPick: controller.pickDocument,
                    onRemove: controller.removeDocument,
                  )),
              const SizedBox(height: 20),
              const VerificationInfoCard(),
              if (controller.errorMessage.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(controller.errorMessage.value, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    label: 'Verify Student Status',
                    icon: Icons.arrow_forward,
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
