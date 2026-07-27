import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class AccountSkillsSection extends StatelessWidget {
  const AccountSkillsSection({super.key, required this.skills});

  final List<ProfileSkill> skills;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = context.scheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: colors.subtleShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined, size: 18, color: primary),
              const SizedBox(width: 8),
              Text('Skills', style: TextStyle(color: colors.muted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          if (skills.isEmpty)
            Text('No skills added', style: TextStyle(fontSize: 16, color: colors.muted))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => _SkillChip(skill: skill)).toList(),
            ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill});

  final ProfileSkill skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.appColors.heading,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${skill.proficiency}%',
            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
