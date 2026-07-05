import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';

class AccountSettingsController extends GetxController {
  AccountSettingsController(this._profileRepository);

  final ProfileRepository _profileRepository;

  final profile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isUploadingAvatar = false.obs;

  final email = 'vithey.user@aub.edu.kh'.obs;
  final phone = '+855 12 345 678'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccount();
  }

  Future<void> loadAccount() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      profile.value = await _profileRepository.getProfile(ProfileRepository.currentUserId);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String get academicInfo {
    final p = profile.value;
    if (p == null) return '—';
    final parts = <String>[
      if (p.major != null) p.major!,
      if (p.graduationYear != null) 'Class of ${p.graduationYear}',
      if (p.university != null) p.university!,
    ];
    return parts.isEmpty ? 'Not set' : parts.join(' · ');
  }

  Future<void> changeAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;

    isUploadingAvatar.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      profile.value = profile.value?.copyWith(avatarUrl: file.path);
      Get.snackbar('Vithey', 'Avatar updated');
    } catch (e) {
      Get.snackbar('Vithey', 'Avatar upload failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void openEditInfo() {
    final p = profile.value;
    if (p == null) return;

    final nameController = TextEditingController(text: p.fullName);
    final bioController = TextEditingController(text: p.bio ?? '');
    final universityController = TextEditingController(text: p.university ?? '');
    final majorController = TextEditingController(text: p.major ?? '');
    final yearController = TextEditingController(text: p.graduationYear?.toString() ?? '');

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Edit Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 12),
                TextField(controller: bioController, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 2),
                const SizedBox(height: 12),
                TextField(controller: universityController, decoration: const InputDecoration(labelText: 'University')),
                const SizedBox(height: 12),
                TextField(controller: majorController, decoration: const InputDecoration(labelText: 'Major')),
                const SizedBox(height: 12),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Graduation Year'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    profile.value = p.copyWith(
                      fullName: nameController.text.trim(),
                      bio: bioController.text.trim(),
                      university: universityController.text.trim(),
                      major: majorController.text.trim(),
                      graduationYear: int.tryParse(yearController.text.trim()),
                    );
                    Get.back();
                    Get.snackbar('Vithey', 'Profile updated');
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    );
  }
}
