import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_skills.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._repository);

  final ProfileRepository _repository;

  final profile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final isSaving = false.obs;

  final bioController = TextEditingController();
  final locationController = TextEditingController();
  final workplaceController = TextEditingController();
  final portfolioController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final universityController = TextEditingController();
  final majorController = TextEditingController();
  final graduationYearController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final loaded = await _repository.getProfile(ProfileRepository.currentUserId);
      profile.value = loaded;
      bioController.text = loaded.bio ?? '';
      locationController.text = loaded.location ?? '';
      workplaceController.text = loaded.workplace ?? '';
      portfolioController.text = loaded.portfolioUrl ?? '';
      phoneController.text = loaded.phone ?? '';
      emailController.text = loaded.email ?? '';
      universityController.text = loaded.university ?? '';
      majorController.text = loaded.major ?? '';
      graduationYearController.text = loaded.graduationYear?.toString() ?? '';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    isSaving.value = true;
    try {
      final yearText = graduationYearController.text.trim();
      final year = yearText.isEmpty ? null : int.tryParse(yearText);
      profile.value = await _repository.updateProfile(
        bio: bioController.text.trim(),
        location: locationController.text.trim(),
        workplace: workplaceController.text.trim(),
        portfolioUrl: portfolioController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        university: universityController.text.trim(),
        major: majorController.text.trim(),
        graduationYear: year,
      );
      Get.back(result: true);
      Get.snackbar(AppStrings.appName, 'Profile updated');
    } catch (e) {
      Get.snackbar(AppStrings.appName, e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    bioController.dispose();
    locationController.dispose();
    workplaceController.dispose();
    portfolioController.dispose();
    phoneController.dispose();
    emailController.dispose();
    universityController.dispose();
    majorController.dispose();
    graduationYearController.dispose();
    super.onClose();
  }
}

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit personal info', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isSaving.value ? null : controller.save,
              child: controller.isSaving.value
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final p = controller.profile.value;
        if (controller.isLoading.value || p == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileSkillsRow(skills: p.skills),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => Get.snackbar(AppStrings.appName, 'Skill editing will use profile API v2'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Skill'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Personal details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            CustomTextField(controller: controller.bioController, label: 'Bio', maxLines: 3),
            CustomTextField(controller: controller.locationController, label: 'Location'),
            if (p.dateOfBirth != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake_outlined),
                title: Text(DateFormat('MMMM dd yyyy').format(p.dateOfBirth!)),
                subtitle: const Text('Date of birth'),
              ),
            const SizedBox(height: 16),
            const Text('Work & education', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            CustomTextField(controller: controller.workplaceController, label: 'Workplace'),
            CustomTextField(controller: controller.universityController, label: 'University'),
            CustomTextField(controller: controller.majorController, label: 'Major'),
            CustomTextField(
              controller: controller.graduationYearController,
              label: 'Graduation year',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Links & contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            CustomTextField(controller: controller.portfolioController, label: 'Portfolio URL'),
            CustomTextField(controller: controller.phoneController, label: 'Phone', keyboardType: TextInputType.phone),
            CustomTextField(controller: controller.emailController, label: 'Email', keyboardType: TextInputType.emailAddress),
          ],
        );
      }),
    );
  }
}

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController(Get.find<ProfileRepository>()));
  }
}
