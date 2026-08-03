import 'package:flutter/material.dart';

class StartupProfileDraft {
  StartupProfileDraft({
    Set<String>? skillIds,
    Set<String>? interestIds,
    this.discoverySource,
  })  : skillIds = skillIds ?? <String>{},
        interestIds = interestIds ?? <String>{};

  final Set<String> skillIds;
  final Set<String> interestIds;
  String? discoverySource;
}

class SkillOption {
  const SkillOption({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

const startupSkills = [
  SkillOption(id: 'graphic_design', label: 'Graphic Design', icon: Icons.brush_outlined),
  SkillOption(id: 'management', label: 'Management', icon: Icons.account_tree_outlined),
  SkillOption(id: 'ai', label: 'AI', icon: Icons.public),
  SkillOption(id: 'social_media', label: 'Social Media Influence', icon: Icons.trending_up),
  SkillOption(id: 'data_analysis', label: 'Data Analysis', icon: Icons.analytics_outlined),
  SkillOption(id: 'content_video', label: 'Content Video', icon: Icons.play_circle_outline),
  SkillOption(id: 'coding', label: 'Coding', icon: Icons.code),
  SkillOption(id: 'marketing', label: 'Marketing', icon: Icons.campaign_outlined),
  SkillOption(id: 'sale', label: 'Sale', icon: Icons.person_outline),
  SkillOption(id: 'ui_ux', label: 'UI/UX Design', icon: Icons.design_services_outlined),
  SkillOption(id: 'photography', label: 'Photography', icon: Icons.photo_camera_outlined),
  SkillOption(id: 'writing', label: 'Writing', icon: Icons.edit_note_outlined),
  SkillOption(id: 'public_speaking', label: 'Public Speaking', icon: Icons.record_voice_over_outlined),
  SkillOption(id: 'translation', label: 'Translation', icon: Icons.translate_outlined),
];

const startupInterests = [
  SkillOption(id: 'academic_news', label: 'Academic News', icon: Icons.school_outlined),
  SkillOption(id: 'campus_events', label: 'Campus Events', icon: Icons.event_outlined),
  SkillOption(id: 'student_life', label: 'Student Life', icon: Icons.groups_outlined),
  SkillOption(id: 'workshops', label: 'Workshops', icon: Icons.folder_outlined),
  SkillOption(id: 'career_opportunities', label: 'Career Opportunities', icon: Icons.work_outline),
  SkillOption(id: 'digital_technology', label: 'Digital and Technology', icon: Icons.laptop_mac_outlined),
  SkillOption(id: 'sports', label: 'Sports', icon: Icons.sports_soccer_outlined),
  SkillOption(id: 'arts_culture', label: 'Arts and Cultures', icon: Icons.palette_outlined),
];

const startupDiscoveryOptions = [
  SkillOption(id: 'facebook', label: 'Facebook', icon: Icons.facebook),
  SkillOption(id: 'instagram', label: 'Instagram', icon: Icons.camera_alt_outlined),
  SkillOption(id: 'campus', label: 'Campus Event', icon: Icons.event_available_outlined),
  SkillOption(id: 'friend', label: 'Friend', icon: Icons.person_outline),
  SkillOption(id: 'other', label: 'Other', icon: Icons.more_horiz),
];
