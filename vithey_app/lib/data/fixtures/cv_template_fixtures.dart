import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/cv_template.dart';

/// CV template catalog for the gallery (15 designs from screen image refs).
abstract final class CvTemplateFixtures {
  static const categories = ['All', 'Professional', 'Creative', 'Modern'];
  static const styles = ['All', 'Sidebar', 'Header', 'Minimal'];
  static const languages = ['All', 'English', 'Khmer'];

  static const List<CvTemplate> all = [
    // —— Sidebar (5) ——
    CvTemplate(
      id: 'tpl-sidebar-1',
      name: 'Lorna Soft',
      category: 'Professional',
      style: 'Sidebar',
      language: 'English',
      layout: CvTemplateLayout.sidebar,
      designId: 'sidebar_1',
      accentColor: Color(0xFF5B7C9D),
      secondaryColor: Color(0xFFE8EEF4),
    ),
    CvTemplate(
      id: 'tpl-sidebar-2',
      name: 'John Bold Blue',
      category: 'Creative',
      style: 'Sidebar',
      language: 'English',
      layout: CvTemplateLayout.sidebar,
      designId: 'sidebar_2',
      accentColor: Color(0xFF2F6FED),
      secondaryColor: Color(0xFF1B3A5F),
    ),
    CvTemplate(
      id: 'tpl-sidebar-3',
      name: 'Dev Navy',
      category: 'Modern',
      style: 'Sidebar',
      language: 'English',
      layout: CvTemplateLayout.sidebar,
      designId: 'sidebar_3',
      accentColor: Color(0xFF3B6BB0),
      secondaryColor: Color(0xFF1A2C4E),
    ),
    CvTemplate(
      id: 'tpl-sidebar-4',
      name: 'Jonathan Curve',
      category: 'Professional',
      style: 'Sidebar',
      language: 'English',
      layout: CvTemplateLayout.sidebar,
      designId: 'sidebar_4',
      accentColor: Color(0xFFC9D9E8),
      secondaryColor: Color(0xFF1B2E4B),
    ),
    CvTemplate(
      id: 'tpl-sidebar-5',
      name: 'Sahib Teal',
      category: 'Creative',
      style: 'Sidebar',
      language: 'English',
      layout: CvTemplateLayout.sidebar,
      designId: 'sidebar_5',
      accentColor: Color(0xFF4A7C8C),
      secondaryColor: Color(0xFF3D6B7A),
    ),
    // —— Header (5) ——
    CvTemplate(
      id: 'tpl-header-1',
      name: 'Howard Maroon',
      category: 'Professional',
      style: 'Header',
      language: 'English',
      layout: CvTemplateLayout.header,
      designId: 'header_1',
      accentColor: Color(0xFF80303E),
    ),
    CvTemplate(
      id: 'tpl-header-2',
      name: 'Richard Soft',
      category: 'Modern',
      style: 'Header',
      language: 'English',
      layout: CvTemplateLayout.header,
      designId: 'header_2',
      accentColor: Color(0xFF343A4E),
      secondaryColor: Color(0xFFE6E9EF),
    ),
    CvTemplate(
      id: 'tpl-header-3',
      name: 'Sanchez Timeline',
      category: 'Professional',
      style: 'Header',
      language: 'English',
      layout: CvTemplateLayout.header,
      designId: 'header_3',
      accentColor: Color(0xFF2D343E),
      secondaryColor: Color(0xFFE1E1E1),
    ),
    CvTemplate(
      id: 'tpl-header-4',
      name: 'Donna Warm',
      category: 'Creative',
      style: 'Header',
      language: 'English',
      layout: CvTemplateLayout.header,
      designId: 'header_4',
      accentColor: Color(0xFF3A2F2A),
      secondaryColor: Color(0xFFE8DFD6),
    ),
    CvTemplate(
      id: 'tpl-header-5',
      name: 'Harry Navy Gold',
      category: 'Modern',
      style: 'Header',
      language: 'English',
      layout: CvTemplateLayout.header,
      designId: 'header_5',
      accentColor: Color(0xFF1B2A4A),
      secondaryColor: Color(0xFFC9A227),
    ),
    // —— Minimal (5) ——
    CvTemplate(
      id: 'tpl-minimal-1',
      name: 'John Clean',
      category: 'Professional',
      style: 'Minimal',
      language: 'English',
      layout: CvTemplateLayout.minimal,
      designId: 'minimal_1',
      accentColor: Color(0xFF111827),
    ),
    CvTemplate(
      id: 'tpl-minimal-2',
      name: 'Classic Frame',
      category: 'Modern',
      style: 'Minimal',
      language: 'English',
      layout: CvTemplateLayout.minimal,
      designId: 'minimal_2',
      accentColor: Color(0xFF374151),
    ),
    CvTemplate(
      id: 'tpl-minimal-3',
      name: 'Border Soft',
      category: 'Modern',
      style: 'Minimal',
      language: 'English',
      layout: CvTemplateLayout.minimal,
      designId: 'minimal_3',
      accentColor: Color(0xFF1F2937),
    ),
    CvTemplate(
      id: 'tpl-minimal-4',
      name: 'Nicole Formal',
      category: 'Professional',
      style: 'Minimal',
      language: 'English',
      layout: CvTemplateLayout.minimal,
      designId: 'minimal_4',
      accentColor: Color(0xFF000000),
    ),
    CvTemplate(
      id: 'tpl-minimal-5',
      name: 'Nicole Certify',
      category: 'Professional',
      style: 'Minimal',
      language: 'English',
      layout: CvTemplateLayout.minimal,
      designId: 'minimal_5',
      accentColor: Color(0xFF111111),
    ),
  ];

  /// Default layout used for "Create blank".
  static const blank = CvTemplate(
    id: 'tpl-blank',
    name: 'Blank',
    category: 'Modern',
    style: 'Minimal',
    language: 'English',
    layout: CvTemplateLayout.blank,
    designId: 'blank',
    accentColor: Color(0xFF6B7280),
  );

  static CvTemplate? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    if (id == blank.id) return blank;
    for (final t in all) {
      if (t.id == id) return t;
    }
    // Legacy ids from older gallery builds → first matching family.
    const legacy = <String, String>{
      'tpl-sidebar-light': 'tpl-sidebar-1',
      'tpl-sidebar-dark': 'tpl-sidebar-3',
      'tpl-header-photo': 'tpl-header-1',
      'tpl-header-strip': 'tpl-header-4',
      'tpl-sidebar-teal': 'tpl-sidebar-5',
      'tpl-minimal-en': 'tpl-minimal-1',
      'tpl-sidebar-kh': 'tpl-sidebar-1',
      'tpl-minimal-kh': 'tpl-minimal-2',
      'tpl-header-creative': 'tpl-header-2',
    };
    final mapped = legacy[id];
    if (mapped != null) return byId(mapped);
    return null;
  }

  static CvTemplate requireById(String? id) => byId(id) ?? all.first;

  static List<CvTemplate> filter({
    String query = '',
    String category = 'All',
    String style = 'All',
    String language = 'All',
  }) {
    final q = query.trim().toLowerCase();
    return all.where((t) {
      if (category != 'All' && t.category != category) return false;
      if (style != 'All' && t.style != style) return false;
      if (language != 'All' && t.language != language) return false;
      if (q.isEmpty) return true;
      return t.name.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.style.toLowerCase().contains(q) ||
          t.designId.toLowerCase().contains(q);
    }).toList();
  }

  /// Sample draft for gallery thumbnails (not user data).
  static const sampleDraft = AiCvDraft(
    fullName: 'Alex Rivera',
    jobTitle: 'Product Designer',
    summary:
        'Product designer and Flutter enthusiast building career tools for students.',
    skills: ['Flutter', 'UI Design', 'Figma', 'Dart'],
    softSkills: ['Communication', 'Teamwork'],
    education: ['AUB · Computer Science · 2022-2026'],
    experience: ['Intern Designer at Studio North · 2024-Present'],
    projects: ['Vithey CV Builder'],
    languages: ['English (Fluent)', 'Khmer (Native)'],
    references: ['Jordan Lee · Mentor · jordan@example.com'],
    certifications: ['Google UX Certificate · 2024'],
    achievements: ['Hackathon finalist · 2025'],
    hobbies: ['Design', 'Reading'],
    contact: 'alex@example.com · Phnom Penh',
    phone: '+855 12 345 678',
    email: 'alex@example.com',
    location: 'Phnom Penh',
    website: 'alex.design',
  );
}
