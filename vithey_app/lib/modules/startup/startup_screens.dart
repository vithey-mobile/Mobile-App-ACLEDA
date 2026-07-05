import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';
import 'package:aub_connect_app/modules/startup/startup_controller.dart';

class StartupSkillsScreen extends GetView<StartupController> {
  const StartupSkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.currentStep.value = 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StartupHeader(onSkip: controller.skipAll),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('What are your skills?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Select your top skills to stand out to employers.', style: TextStyle(color: AppColors.authMuted, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GetBuilder<StartupController>(
                builder: (_) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: startupSkills.map((skill) {
                      final selected = controller.draft.skillIds.contains(skill.id);
                      return FilterChip(
                        avatar: Icon(skill.icon, size: 16, color: AppColors.authMuted),
                        label: Text(skill.label),
                        selected: selected,
                        onSelected: (_) => controller.toggleSkill(skill.id),
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            StartupStepIndicator(currentStep: 1),
            StartupBottomNav(
              showBack: false,
              onBack: null,
              onNext: controller.nextFromSkills,
            ),
          ],
        ),
      ),
    );
  }
}

class StartupInterestsScreen extends GetView<StartupController> {
  const StartupInterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.currentStep.value = 2;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StartupHeader(onSkip: controller.skipAll),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('What are you interested in?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Choose your favorite topics to personalize your feed.', style: TextStyle(color: AppColors.authMuted, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GetBuilder<StartupController>(
                builder: (_) => GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.9,
                  ),
                  itemCount: startupInterests.length,
                  itemBuilder: (_, index) {
                    final item = startupInterests[index];
                    final selected = controller.draft.interestIds.contains(item.id);
                    return InkWell(
                      onTap: () => controller.toggleInterest(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.authInputFill,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.authBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item.icon, size: 18, color: AppColors.authMuted),
                            const Spacer(),
                            Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            StartupStepIndicator(currentStep: 2),
            StartupBottomNav(
              onBack: controller.backFromInterests,
              onNext: controller.nextFromInterests,
            ),
          ],
        ),
      ),
    );
  }
}

class StartupDiscoveryScreen extends GetView<StartupController> {
  const StartupDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.currentStep.value = 3;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StartupHeader(onSkip: controller.skipAll),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('How did you find us?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Select one option to help us improve your experience.', style: TextStyle(color: AppColors.authMuted, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GetBuilder<StartupController>(
                builder: (_) => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: startupDiscoveryOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final item = startupDiscoveryOptions[index];
                    final selected = controller.draft.discoverySource == item.id;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: selected ? AppColors.primary : AppColors.authBorder),
                      ),
                      tileColor: selected ? AppColors.primary.withOpacity(0.08) : AppColors.authInputFill,
                      leading: Icon(item.icon),
                      title: Text(item.label),
                      onTap: () => controller.selectDiscovery(item.id),
                    );
                  },
                ),
              ),
            ),
            StartupStepIndicator(currentStep: 3),
            StartupBottomNav(
              onBack: controller.backFromDiscovery,
              onNext: () => controller.finish(),
              nextLabel: 'Finish',
            ),
          ],
        ),
      ),
    );
  }
}
