import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:intl/intl.dart';

class ProfileSkillRing extends StatelessWidget {
  const ProfileSkillRing({
    super.key,
    required this.skill,
    this.size = 68,
  });

  final ProfileSkill skill;
  final double size;

  static const _palette = [
    AppColors.primary,
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFF2196F3),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[skill.name.hashCode.abs() % _palette.length];
    final progress = (skill.proficiency.clamp(0, 100)) / 100;

    return SizedBox(
      width: size + 8,
      child: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: context.appColors.inputFill,
                  color: color,
                ),
                Text(
                  '${skill.proficiency}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            skill.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ProfileSkillsRow extends StatelessWidget {
  const ProfileSkillsRow({super.key, required this.skills});

  final List<ProfileSkill> skills;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: skills.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => ProfileSkillRing(skill: skills[index]),
          ),
        ),
      ],
    );
  }
}

class ProfilePersonalDetails extends StatelessWidget {
  const ProfilePersonalDetails({
    super.key,
    required this.profile,
    required this.isOwnProfile,
  });

  final UserProfileModel profile;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (profile.location != null) {
      rows.add(_DetailRow(icon: Icons.location_on_outlined, text: profile.location!));
    }
    if (profile.dateOfBirth != null) {
      rows.add(_DetailRow(
        icon: Icons.cake_outlined,
        text: DateFormat('MMMM dd yyyy').format(profile.dateOfBirth!),
      ));
    }
    if (profile.workplace != null) {
      rows.add(_DetailRow(icon: Icons.business_outlined, text: profile.workplace!));
    }
    for (final school in profile.education) {
      rows.add(_DetailRow(icon: Icons.school_outlined, text: school));
    }
    if (profile.university != null && !profile.education.contains(profile.university)) {
      rows.add(_DetailRow(icon: Icons.school_outlined, text: profile.university!));
    }
    if (profile.portfolioUrl != null) {
      rows.add(_DetailRow(icon: Icons.link, text: profile.portfolioUrl!));
    }
    if (isOwnProfile && profile.phone != null) {
      rows.add(_DetailRow(icon: Icons.phone_outlined, text: profile.phone!));
    }
    if (isOwnProfile && profile.email != null) {
      rows.add(_DetailRow(icon: Icons.email_outlined, text: profile.email!));
    }

    if (rows.isEmpty) {
      return Text(
        isOwnProfile ? 'Add your details in Edit profile info' : 'No public information',
        style: TextStyle(color: context.appColors.muted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.appColors.muted),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.35))),
        ],
      ),
    );
  }
}
