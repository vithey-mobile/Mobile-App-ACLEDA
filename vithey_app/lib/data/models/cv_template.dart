import 'package:flutter/material.dart';

/// Visual layout families for AI / blank CV templates.
enum CvTemplateLayout {
  blank,
  sidebar,
  header,
  minimal,
}

/// Catalog entry for a CV design (gallery + renderer + PDF).
class CvTemplate {
  const CvTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.style,
    required this.language,
    required this.layout,
    required this.accentColor,
    required this.designId,
    this.secondaryColor,
  });

  final String id;
  final String name;

  /// Professional | Creative | Modern
  final String category;

  /// Sidebar | Header | Minimal
  final String style;

  /// English | Khmer — section labels only.
  final String language;

  final CvTemplateLayout layout;

  /// Matches reference image key, e.g. `sidebar_1`, `header_3`, `minimal_5`.
  final String designId;

  final Color accentColor;
  final Color? secondaryColor;

  bool get isBlank => layout == CvTemplateLayout.blank;

  /// Localized section labels for [language].
  CvTemplateLabels get labels =>
      language == 'Khmer' ? CvTemplateLabels.khmer : CvTemplateLabels.english;
}

class CvTemplateLabels {
  const CvTemplateLabels({
    required this.aboutMe,
    required this.experience,
    required this.education,
    required this.skills,
    required this.projects,
    required this.contact,
    required this.languages,
    required this.references,
    required this.certifications,
    required this.achievements,
    required this.hobbies,
  });

  final String aboutMe;
  final String experience;
  final String education;
  final String skills;
  final String projects;
  final String contact;
  final String languages;
  final String references;
  final String certifications;
  final String achievements;
  final String hobbies;

  static const english = CvTemplateLabels(
    aboutMe: 'About Me',
    experience: 'Experience',
    education: 'Education',
    skills: 'Skills',
    projects: 'Projects',
    contact: 'Contact',
    languages: 'Languages',
    references: 'References',
    certifications: 'Certifications',
    achievements: 'Achievements',
    hobbies: 'Hobbies',
  );

  static const khmer = CvTemplateLabels(
    aboutMe: 'អំពីខ្ញុំ',
    experience: 'បទពិសោធន៍',
    education: 'ការសិក្សា',
    skills: 'ជំនាញ',
    projects: 'គម្រោង',
    contact: 'ទំនាក់ទំនង',
    languages: 'ភាសា',
    references: 'អ្នកធានា',
    certifications: 'វិញ្ញាបនបត្រ',
    achievements: 'សមិទ្ធផល',
    hobbies: 'ចំណង់ចំណូលចិត្ត',
  );
}
