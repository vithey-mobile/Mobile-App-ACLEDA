import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';
import 'package:aub_connect_app/modules/startup/startup_controller.dart';
import 'package:aub_connect_app/modules/startup/widgets/discovery_source_row.dart';
import 'package:aub_connect_app/modules/startup/widgets/selectable_interest_card.dart';
import 'package:aub_connect_app/modules/startup/widgets/selectable_skill_chip.dart';

class StartupSkillsPage extends GetView<StartupController> {
  const StartupSkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'What are your skills?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select your top skills to stand out to employers.',
            style: TextStyle(color: context.appColors.muted, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GetBuilder<StartupController>(
            builder: (_) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: startupSkills.map((skill) {
                  final selected = controller.draft.skillIds.contains(skill.id);
                  return SelectableSkillChip(
                    label: skill.label,
                    icon: skill.icon,
                    selected: selected,
                    onTap: () => controller.toggleSkill(skill.id),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StartupInterestsPage extends GetView<StartupController> {
  const StartupInterestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'What are you interested in?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Choose your favorite topics to personalize your feed.',
            style: TextStyle(color: context.appColors.muted, fontSize: 12),
          ),
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
                return SelectableInterestCard(
                  label: item.label,
                  icon: item.icon,
                  selected: selected,
                  onTap: () => controller.toggleInterest(item.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class StartupDiscoveryPage extends GetView<StartupController> {
  const StartupDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'How did you find us?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select one option to help us improve your experience.',
            style: TextStyle(color: context.appColors.muted, fontSize: 12),
          ),
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
                return DiscoverySourceRow(
                  label: item.label,
                  icon: item.icon,
                  selected: selected,
                  onTap: () => controller.selectDiscovery(item.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
