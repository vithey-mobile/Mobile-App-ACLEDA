import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';

class EditAccountSettingsController extends GetxController {
  EditAccountSettingsController(this._profileRepository);

  final ProfileRepository _profileRepository;

  final profile = Rxn<UserProfileModel>();
  final skills = <ProfileSkill>[].obs;
  final dateOfBirth = Rxn<DateTime>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isSaving = false.obs;
  final isUploadingAvatar = false.obs;

  late final fullNameController = TextEditingController();
  late final bioController = TextEditingController();
  late final emailController = TextEditingController();
  late final phoneController = TextEditingController();
  late final locationController = TextEditingController();
  late final universityController = TextEditingController();
  late final majorController = TextEditingController();
  late final graduationYearController = TextEditingController();
  late final educationController = TextEditingController();
  late final workplaceController = TextEditingController();
  late final telegramController = TextEditingController();
  late final facebookController = TextEditingController();
  late final portfolioController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    bioController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    universityController.dispose();
    majorController.dispose();
    graduationYearController.dispose();
    educationController.dispose();
    workplaceController.dispose();
    telegramController.dispose();
    facebookController.dispose();
    portfolioController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final loaded = await _profileRepository.getProfile(ProfileRepository.currentUserId);
      profile.value = loaded;
      _bindFields(loaded);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _bindFields(UserProfileModel loaded) {
    fullNameController.text = loaded.fullName;
    bioController.text = loaded.bio ?? '';
    emailController.text = loaded.email ?? '';
    phoneController.text = loaded.phone ?? '';
    locationController.text = loaded.location ?? '';
    universityController.text = loaded.university ?? '';
    majorController.text = loaded.major ?? '';
    graduationYearController.text = loaded.graduationYear?.toString() ?? '';
    educationController.text = loaded.education.join('\n');
    workplaceController.text = loaded.workplace ?? '';
    telegramController.text = loaded.telegramLink ?? '';
    facebookController.text = loaded.facebookLink ?? '';
    portfolioController.text = loaded.portfolioUrl ?? '';
    dateOfBirth.value = loaded.dateOfBirth;
    skills.assignAll(loaded.skills);
  }

  List<String> _parseEducation() {
    return educationController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<ProfileSkill> _normalizedSkills() {
    return skills
        .where((skill) => skill.name.trim().isNotEmpty)
        .map((skill) => ProfileSkill(name: skill.name.trim(), proficiency: skill.proficiency.clamp(0, 100)))
        .toList();
  }

  Future<void> pickDateOfBirth() async {
    final initial = dateOfBirth.value ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) dateOfBirth.value = picked;
  }

  void addSkill() {
    skills.add(const ProfileSkill(name: '', proficiency: 50));
  }

  void removeSkill(int index) {
    if (index < 0 || index >= skills.length) return;
    skills.removeAt(index);
  }

  void updateSkill(int index, {String? name}) {
    if (index < 0 || index >= skills.length) return;
    final current = skills[index];
    skills[index] = ProfileSkill(
      name: name ?? current.name,
      proficiency: current.proficiency,
    );
    skills.assignAll(List<ProfileSkill>.from(skills));
  }

  Future<void> changeAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;

    isUploadingAvatar.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (profile.value == null) return;

      final updated = await _profileRepository.updateProfile(avatarUrl: file.path);
      profile.value = updated;
      Get.snackbar('Vithey', 'Avatar updated');
    } catch (e) {
      Get.snackbar('Vithey', 'Avatar upload failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> save() async {
    final name = fullNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Vithey', 'Full name is required');
      return;
    }

    final normalizedSkills = _normalizedSkills();

    isSaving.value = true;
    try {
      final current = profile.value;
      if (current == null) return;

      final yearText = graduationYearController.text.trim();
      final year = yearText.isEmpty ? null : int.tryParse(yearText);

      final updated = await _profileRepository.updateProfile(
        fullName: name,
        bio: bioController.text.trim(),
        phone: phoneController.text.trim(),
        location: locationController.text.trim(),
        university: universityController.text.trim(),
        major: majorController.text.trim(),
        graduationYear: year,
        workplace: workplaceController.text.trim(),
        portfolioUrl: portfolioController.text.trim(),
        telegramLink: telegramController.text.trim(),
        facebookLink: facebookController.text.trim(),
        avatarUrl: current.avatarUrl,
        education: _parseEducation(),
        skills: normalizedSkills,
        dateOfBirth: dateOfBirth.value,
      );

      profile.value = updated;
      isSaving.value = false;
      if (Get.previousRoute == AppRoutes.settingsAccount) {
        Get.back(result: true);
      } else {
        Get.offNamed(AppRoutes.settingsAccount);
      }
      Get.snackbar('Vithey', 'Account updated');
    } catch (e) {
      Get.snackbar('Vithey', 'Failed to save account');
    } finally {
      if (isSaving.value) {
        isSaving.value = false;
      }
    }
  }
}
