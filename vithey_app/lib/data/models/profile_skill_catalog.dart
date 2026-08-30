import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/skill_assets.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';

/// A selectable skill leaf or category entry with optional logo / icon.
class CatalogSkill {
  const CatalogSkill({
    required this.id,
    required this.label,
    this.iconUrl,
    this.icon,
  });

  final String id;
  final String label;

  /// Legacy remote logo URL (unused for bundled skill assets).
  final String? iconUrl;

  /// Fallback / category Material icon.
  final IconData? icon;
}

/// Coding subcategory after selecting Coding.
const codingCategories = [
  CatalogSkill(id: 'frontend', label: 'Frontend', icon: Icons.web_outlined),
  CatalogSkill(id: 'backend', label: 'Backend', icon: Icons.dns_outlined),
  CatalogSkill(id: 'other', label: 'Other', icon: Icons.more_horiz),
];

CatalogSkill _assetSkill(String id, String label, {IconData? icon}) =>
    CatalogSkill(id: id, label: label, icon: icon);

final codingFrontendSkills = <CatalogSkill>[
  _assetSkill('flutter', 'Flutter'),
  _assetSkill('html', 'HTML'),
  _assetSkill('css', 'CSS'),
  _assetSkill('javascript', 'JavaScript'),
  _assetSkill('react', 'React'),
  _assetSkill('nextjs', 'Next.js'),
  _assetSkill('vuejs', 'Vue.js'),
  _assetSkill('angular', 'Angular'),
  _assetSkill('dart', 'Dart'),
  const CatalogSkill(id: 'other', label: 'Other', icon: Icons.more_horiz),
];

final codingBackendSkills = <CatalogSkill>[
  _assetSkill('java', 'Java'),
  _assetSkill('spring', 'Spring Boot'),
  _assetSkill('kotlin', 'Kotlin'),
  _assetSkill('csharp', 'C#'),
  _assetSkill('php', 'PHP'),
  _assetSkill('laravel', 'Laravel'),
  _assetSkill('nodejs', 'Node.js'),
  _assetSkill('python', 'Python'),
  _assetSkill('django', 'Django'),
  _assetSkill('cplusplus', 'C++'),
  _assetSkill('mysql', 'MySQL'),
  _assetSkill('postgresql', 'PostgreSQL'),
  _assetSkill('mongodb', 'MongoDB'),
  _assetSkill('firebase', 'Firebase'),
  _assetSkill('docker', 'Docker'),
  const CatalogSkill(id: 'other', label: 'Other', icon: Icons.more_horiz),
];

/// Top-level profile skill categories (same labels as startup skills).
List<CatalogSkill> get topLevelSkillCatalog => [
      for (final s in startupSkills)
        CatalogSkill(
          id: s.id,
          label: s.label,
          icon: s.icon,
        ),
      const CatalogSkill(id: 'other', label: 'Other', icon: Icons.more_horiz),
    ];

/// All known catalog entries for icon lookup by label / id.
List<CatalogSkill> get allCatalogSkills => [
      ...codingFrontendSkills.where((s) => s.id != 'other'),
      ...codingBackendSkills.where((s) => s.id != 'other'),
    ];

/// Extra Material icons available in the “Choose Icon” picker (custom skills).
const pickableMaterialIcons = <CatalogSkill>[
  CatalogSkill(id: 'icon_star', label: 'Star', icon: Icons.star_outline),
  CatalogSkill(id: 'icon_favorite', label: 'Favorite', icon: Icons.favorite_border),
  CatalogSkill(id: 'icon_bolt', label: 'Bolt', icon: Icons.bolt_outlined),
  CatalogSkill(id: 'icon_lightbulb', label: 'Idea', icon: Icons.lightbulb_outline),
  CatalogSkill(id: 'icon_psychology', label: 'Mind', icon: Icons.psychology_outlined),
  CatalogSkill(id: 'icon_school', label: 'School', icon: Icons.school_outlined),
  CatalogSkill(id: 'icon_work', label: 'Work', icon: Icons.work_outline),
  CatalogSkill(id: 'icon_build', label: 'Build', icon: Icons.build_outlined),
  CatalogSkill(id: 'icon_handyman', label: 'Tools', icon: Icons.handyman_outlined),
  CatalogSkill(id: 'icon_science', label: 'Science', icon: Icons.science_outlined),
  CatalogSkill(id: 'icon_biotech', label: 'Biotech', icon: Icons.biotech_outlined),
  CatalogSkill(id: 'icon_memory', label: 'Chip', icon: Icons.memory),
  CatalogSkill(id: 'icon_terminal', label: 'Terminal', icon: Icons.terminal),
  CatalogSkill(id: 'icon_cloud', label: 'Cloud', icon: Icons.cloud_outlined),
  CatalogSkill(id: 'icon_security', label: 'Security', icon: Icons.security),
  CatalogSkill(id: 'icon_wifi', label: 'Network', icon: Icons.wifi),
  CatalogSkill(id: 'icon_storage', label: 'Storage', icon: Icons.storage_outlined),
  CatalogSkill(id: 'icon_database', label: 'Database', icon: Icons.data_object),
  CatalogSkill(id: 'icon_phone', label: 'Mobile', icon: Icons.phone_iphone),
  CatalogSkill(id: 'icon_laptop', label: 'Laptop', icon: Icons.laptop_mac),
  CatalogSkill(id: 'icon_desktop', label: 'Desktop', icon: Icons.desktop_windows_outlined),
  CatalogSkill(id: 'icon_palette', label: 'Palette', icon: Icons.palette_outlined),
  CatalogSkill(id: 'icon_brush', label: 'Brush', icon: Icons.brush_outlined),
  CatalogSkill(id: 'icon_design', label: 'Design', icon: Icons.design_services_outlined),
  CatalogSkill(id: 'icon_architecture', label: 'Architecture', icon: Icons.architecture),
  CatalogSkill(id: 'icon_camera', label: 'Camera', icon: Icons.photo_camera_outlined),
  CatalogSkill(id: 'icon_videocam', label: 'Video', icon: Icons.videocam_outlined),
  CatalogSkill(id: 'icon_music', label: 'Music', icon: Icons.music_note_outlined),
  CatalogSkill(id: 'icon_mic', label: 'Mic', icon: Icons.mic_none),
  CatalogSkill(id: 'icon_edit', label: 'Write', icon: Icons.edit_outlined),
  CatalogSkill(id: 'icon_article', label: 'Article', icon: Icons.article_outlined),
  CatalogSkill(id: 'icon_translate', label: 'Language', icon: Icons.translate),
  CatalogSkill(id: 'icon_campaign', label: 'Marketing', icon: Icons.campaign_outlined),
  CatalogSkill(id: 'icon_trending', label: 'Growth', icon: Icons.trending_up),
  CatalogSkill(id: 'icon_analytics', label: 'Analytics', icon: Icons.analytics_outlined),
  CatalogSkill(id: 'icon_insights', label: 'Insights', icon: Icons.insights),
  CatalogSkill(id: 'icon_groups', label: 'Team', icon: Icons.groups_outlined),
  CatalogSkill(id: 'icon_handshake', label: 'Deal', icon: Icons.handshake_outlined),
  CatalogSkill(id: 'icon_sports', label: 'Sports', icon: Icons.sports_soccer_outlined),
  CatalogSkill(id: 'icon_fitness', label: 'Fitness', icon: Icons.fitness_center),
  CatalogSkill(id: 'icon_restaurant', label: 'Food', icon: Icons.restaurant_outlined),
  CatalogSkill(id: 'icon_flight', label: 'Travel', icon: Icons.flight_outlined),
  CatalogSkill(id: 'icon_public', label: 'Globe', icon: Icons.public),
  CatalogSkill(id: 'icon_auto_awesome', label: 'Sparkle', icon: Icons.auto_awesome),
];

/// Icons shown in the custom-skill “Choose Icon” sheet.
List<CatalogSkill> get pickableSkillIcons {
  final seen = <String>{};
  final out = <CatalogSkill>[];
  for (final s in allCatalogSkills) {
    if (!SkillAssets.hasAsset(iconKey: s.id, label: s.label)) continue;
    if (!seen.add(s.id)) continue;
    out.add(s);
  }
  for (final s in pickableMaterialIcons) {
    if (!seen.add(s.id)) continue;
    out.add(s);
  }
  return out;
}

CatalogSkill? findCatalogSkill({String? iconKey, String? label}) {
  if (iconKey != null && iconKey.isNotEmpty) {
    for (final s in allCatalogSkills) {
      if (s.id == iconKey) return s;
    }
    for (final s in pickableMaterialIcons) {
      if (s.id == iconKey) return s;
    }
  }
  final name = label?.trim().toLowerCase();
  if (name == null || name.isEmpty) return null;
  for (final s in allCatalogSkills) {
    if (s.label.toLowerCase() == name) return s;
  }
  return null;
}

bool isCodingTopLevel(String label) => label.trim().toLowerCase() == 'coding';
