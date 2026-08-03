import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';

/// Devicon PNG base (official tech logos).
const _devicon =
    'https://raw.githubusercontent.com/devicons/devicon/master/icons';

String _dev(String path) => '$_devicon/$path';

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

  /// Remote official logo URL (devicon).
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

final codingFrontendSkills = <CatalogSkill>[
  CatalogSkill(
    id: 'flutter',
    label: 'Flutter',
    iconUrl: _dev('flutter/flutter-original.png'),
  ),
  CatalogSkill(
    id: 'dart',
    label: 'Dart',
    iconUrl: _dev('dart/dart-original.png'),
  ),
  CatalogSkill(
    id: 'html',
    label: 'HTML',
    iconUrl: _dev('html5/html5-original.png'),
  ),
  CatalogSkill(
    id: 'css',
    label: 'CSS',
    iconUrl: _dev('css3/css3-original.png'),
  ),
  CatalogSkill(
    id: 'javascript',
    label: 'JavaScript',
    iconUrl: _dev('javascript/javascript-original.png'),
  ),
  CatalogSkill(
    id: 'typescript',
    label: 'TypeScript',
    iconUrl: _dev('typescript/typescript-original.png'),
  ),
  CatalogSkill(
    id: 'react',
    label: 'React',
    iconUrl: _dev('react/react-original.png'),
  ),
  CatalogSkill(
    id: 'react_native',
    label: 'React Native',
    iconUrl: _dev('react/react-original.png'),
  ),
  CatalogSkill(
    id: 'nextjs',
    label: 'Next.js',
    iconUrl: _dev('nextjs/nextjs-original.png'),
  ),
  CatalogSkill(
    id: 'vuejs',
    label: 'Vue.js',
    iconUrl: _dev('vuejs/vuejs-original.png'),
  ),
  CatalogSkill(
    id: 'nuxtjs',
    label: 'Nuxt.js',
    iconUrl: _dev('nuxtjs/nuxtjs-original.png'),
  ),
  CatalogSkill(
    id: 'angular',
    label: 'Angular',
    iconUrl: _dev('angularjs/angularjs-original.png'),
  ),
  CatalogSkill(
    id: 'svelte',
    label: 'Svelte',
    iconUrl: _dev('svelte/svelte-original.png'),
  ),
  CatalogSkill(
    id: 'tailwindcss',
    label: 'Tailwind CSS',
    iconUrl: _dev('tailwindcss/tailwindcss-original.png'),
  ),
  CatalogSkill(
    id: 'bootstrap',
    label: 'Bootstrap',
    iconUrl: _dev('bootstrap/bootstrap-original.png'),
  ),
  CatalogSkill(
    id: 'materialui',
    label: 'Material UI',
    iconUrl: _dev('materialui/materialui-original.png'),
  ),
  CatalogSkill(
    id: 'jquery',
    label: 'jQuery',
    iconUrl: _dev('jquery/jquery-original.png'),
  ),
  CatalogSkill(
    id: 'sass',
    label: 'Sass (SCSS)',
    iconUrl: _dev('sass/sass-original.png'),
  ),
  CatalogSkill(
    id: 'less',
    label: 'Less',
    iconUrl: _dev('less/less-plain-wordmark.png'),
  ),
  CatalogSkill(
    id: 'alpinejs',
    label: 'Alpine.js',
    iconUrl: _dev('alpinejs/alpinejs-original.png'),
  ),
  CatalogSkill(
    id: 'ionic',
    label: 'Ionic',
    iconUrl: _dev('ionic/ionic-original.png'),
  ),
  CatalogSkill(
    id: 'electron',
    label: 'Electron',
    iconUrl: _dev('electron/electron-original.png'),
  ),
  CatalogSkill(
    id: 'expo',
    label: 'Expo',
    iconUrl: _dev('react/react-original.png'),
  ),
  const CatalogSkill(id: 'other', label: 'Other', icon: Icons.more_horiz),
];

final codingBackendSkills = <CatalogSkill>[
  CatalogSkill(
    id: 'java',
    label: 'Java',
    iconUrl: _dev('java/java-original.png'),
  ),
  CatalogSkill(
    id: 'spring',
    label: 'Spring Boot',
    iconUrl: _dev('spring/spring-original.png'),
  ),
  CatalogSkill(
    id: 'kotlin',
    label: 'Kotlin',
    iconUrl: _dev('kotlin/kotlin-original.png'),
  ),
  CatalogSkill(
    id: 'csharp',
    label: 'C#',
    iconUrl: _dev('csharp/csharp-original.png'),
  ),
  CatalogSkill(
    id: 'dotnet',
    label: 'ASP.NET',
    iconUrl: _dev('dotnetcore/dotnetcore-original.png'),
  ),
  CatalogSkill(
    id: 'php',
    label: 'PHP',
    iconUrl: _dev('php/php-original.png'),
  ),
  CatalogSkill(
    id: 'laravel',
    label: 'Laravel',
    iconUrl: _dev('laravel/laravel-original.png'),
  ),
  CatalogSkill(
    id: 'codeigniter',
    label: 'CodeIgniter',
    iconUrl: _dev('codeigniter/codeigniter-plain.png'),
  ),
  CatalogSkill(
    id: 'nodejs',
    label: 'Node.js',
    iconUrl: _dev('nodejs/nodejs-original.png'),
  ),
  CatalogSkill(
    id: 'express',
    label: 'Express.js',
    iconUrl: _dev('express/express-original.png'),
  ),
  CatalogSkill(
    id: 'nestjs',
    label: 'NestJS',
    iconUrl: _dev('nestjs/nestjs-original.png'),
  ),
  CatalogSkill(
    id: 'python',
    label: 'Python',
    iconUrl: _dev('python/python-original.png'),
  ),
  CatalogSkill(
    id: 'django',
    label: 'Django',
    iconUrl: _dev('django/django-plain.png'),
  ),
  CatalogSkill(
    id: 'flask',
    label: 'Flask',
    iconUrl: _dev('flask/flask-original.png'),
  ),
  CatalogSkill(
    id: 'fastapi',
    label: 'FastAPI',
    iconUrl: _dev('fastapi/fastapi-original.png'),
  ),
  CatalogSkill(
    id: 'rails',
    label: 'Ruby on Rails',
    iconUrl: _dev('rails/rails-original-wordmark.png'),
  ),
  CatalogSkill(
    id: 'go',
    label: 'Go',
    iconUrl: _dev('go/go-original.png'),
  ),
  CatalogSkill(
    id: 'rust',
    label: 'Rust',
    iconUrl: _dev('rust/rust-original.png'),
  ),
  CatalogSkill(
    id: 'cplusplus',
    label: 'C++',
    iconUrl: _dev('cplusplus/cplusplus-original.png'),
  ),
  CatalogSkill(
    id: 'mysql',
    label: 'MySQL',
    iconUrl: _dev('mysql/mysql-original.png'),
  ),
  CatalogSkill(
    id: 'postgresql',
    label: 'PostgreSQL',
    iconUrl: _dev('postgresql/postgresql-original.png'),
  ),
  CatalogSkill(
    id: 'mongodb',
    label: 'MongoDB',
    iconUrl: _dev('mongodb/mongodb-original.png'),
  ),
  CatalogSkill(
    id: 'redis',
    label: 'Redis',
    iconUrl: _dev('redis/redis-original.png'),
  ),
  CatalogSkill(
    id: 'firebase',
    label: 'Firebase',
    iconUrl: _dev('firebase/firebase-plain.png'),
  ),
  CatalogSkill(
    id: 'graphql',
    label: 'GraphQL',
    iconUrl: _dev('graphql/graphql-plain.png'),
  ),
  CatalogSkill(
    id: 'docker',
    label: 'Docker',
    iconUrl: _dev('docker/docker-original.png'),
  ),
  CatalogSkill(
    id: 'kubernetes',
    label: 'Kubernetes',
    iconUrl: _dev('kubernetes/kubernetes-plain.png'),
  ),
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

final _extraKnownSkills = <CatalogSkill>[
  CatalogSkill(
    id: 'git',
    label: 'Git',
    iconUrl: _dev('git/git-original.png'),
  ),
  const CatalogSkill(
    id: 'rest_api',
    label: 'REST API',
    icon: Icons.api_outlined,
  ),
];

/// All known catalog entries for icon lookup by label / id.
List<CatalogSkill> get allCatalogSkills => [
      ...topLevelSkillCatalog.where((s) => s.id != 'other'),
      ...codingFrontendSkills.where((s) => s.id != 'other'),
      ...codingBackendSkills.where((s) => s.id != 'other'),
      ..._extraKnownSkills,
    ];

/// Extra Material icons available in the “Choose Icon” picker.
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
  for (final s in [...pickableMaterialIcons, ...allCatalogSkills]) {
    if (!seen.add(s.id)) continue;
    if (s.icon == null && (s.iconUrl == null || s.iconUrl!.isEmpty)) continue;
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
