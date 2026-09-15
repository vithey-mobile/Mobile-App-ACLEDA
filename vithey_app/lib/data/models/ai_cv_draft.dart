/// Structured CV draft for template fill + editing.
///
/// This is **CV-specific data**. Editing it must never mutate the user's
/// profile/account. Profile is only read when generating a draft snapshot.
class AiCvDraft {
  const AiCvDraft({
    required this.fullName,
    required this.summary,
    required this.skills,
    required this.education,
    required this.experience,
    required this.projects,
    required this.contact,
    this.jobTitle = '',
    this.phone = '',
    this.email = '',
    this.location = '',
    this.website = '',
    this.avatarUrl,
    this.languages = const [],
    this.references = const [],
    this.certifications = const [],
    this.achievements = const [],
    this.hobbies = const [],
    this.softSkills = const [],
    this.templateId,
    this.incompleteProfile = false,
    this.incompleteMessage,
  });

  final String fullName;
  final String jobTitle;
  final String summary;
  final List<String> skills;
  final List<String> softSkills;
  final List<String> education;
  final List<String> experience;
  final List<String> projects;
  final List<String> languages;
  final List<String> references;
  final List<String> certifications;
  final List<String> achievements;
  final List<String> hobbies;

  /// Legacy single-line contact (kept for older UI / PDF helpers).
  final String contact;

  final String phone;
  final String email;
  final String location;
  final String website;
  final String? avatarUrl;

  /// Selected gallery template id (layout styling).
  final String? templateId;
  final bool incompleteProfile;
  final String? incompleteMessage;

  /// Prefer structured contact; fall back to [contact].
  String get contactDisplay {
    final parts = <String>[
      if (phone.trim().isNotEmpty) phone.trim(),
      if (email.trim().isNotEmpty) email.trim(),
      if (location.trim().isNotEmpty) location.trim(),
      if (website.trim().isNotEmpty) website.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(' · ');
    return contact.trim();
  }

  bool get hasLanguages => languages.any((e) => e.trim().isNotEmpty);
  bool get hasReferences => references.any((e) => e.trim().isNotEmpty);
  bool get hasCertifications =>
      certifications.any((e) => e.trim().isNotEmpty);
  bool get hasAchievements => achievements.any((e) => e.trim().isNotEmpty);
  bool get hasHobbies => hobbies.any((e) => e.trim().isNotEmpty);
  bool get hasSoftSkills => softSkills.any((e) => e.trim().isNotEmpty);
  bool get hasProjects => projects.any((e) => e.trim().isNotEmpty);

  AiCvDraft copyWith({
    String? fullName,
    String? jobTitle,
    String? summary,
    List<String>? skills,
    List<String>? softSkills,
    List<String>? education,
    List<String>? experience,
    List<String>? projects,
    List<String>? languages,
    List<String>? references,
    List<String>? certifications,
    List<String>? achievements,
    List<String>? hobbies,
    String? contact,
    String? phone,
    String? email,
    String? location,
    String? website,
    String? avatarUrl,
    String? templateId,
    bool? incompleteProfile,
    String? incompleteMessage,
  }) {
    return AiCvDraft(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      softSkills: softSkills ?? this.softSkills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      languages: languages ?? this.languages,
      references: references ?? this.references,
      certifications: certifications ?? this.certifications,
      achievements: achievements ?? this.achievements,
      hobbies: hobbies ?? this.hobbies,
      contact: contact ?? this.contact,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      website: website ?? this.website,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      templateId: templateId ?? this.templateId,
      incompleteProfile: incompleteProfile ?? this.incompleteProfile,
      incompleteMessage: incompleteMessage ?? this.incompleteMessage,
    );
  }

  bool get isEmptyDraft =>
      summary.trim().isEmpty &&
      skills.isEmpty &&
      education.isEmpty &&
      experience.isEmpty;

  /// Shrinks text only when extremely long so preview can scale to fit.
  /// Keeps the **same sections/items** as the full draft — compact mode
  /// relies on smaller layout scale, not dropping data.
  AiCvDraft fittedForPreview({required bool compact}) {
    String clip(String value, int maxChars) {
      final t = value.trim();
      if (t.isEmpty || t.length <= maxChars) return t;
      return '${t.substring(0, maxChars).trimRight()}…';
    }

    List<String> clipLines(
      List<String> items, {
      required int maxChars,
    }) {
      return items
          .map((e) => clip(e, maxChars))
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }

    // Same data in gallery + editor; only soft-cap runaway string length.
    final maxLine = compact ? 96 : 160;
    final maxSummary = compact ? 280 : 420;

    return copyWith(
      fullName: clip(fullName, compact ? 48 : 64),
      jobTitle: clip(jobTitle, compact ? 56 : 72),
      summary: clip(summary, maxSummary),
      skills: clipLines(skills, maxChars: maxLine),
      softSkills: clipLines(softSkills, maxChars: maxLine),
      education: clipLines(education, maxChars: maxLine),
      experience: clipLines(experience, maxChars: maxLine),
      projects: clipLines(projects, maxChars: maxLine),
      languages: clipLines(languages, maxChars: maxLine),
      references: clipLines(references, maxChars: maxLine),
      certifications: clipLines(certifications, maxChars: maxLine),
      achievements: clipLines(achievements, maxChars: maxLine),
      hobbies: clipLines(hobbies, maxChars: maxLine),
      contact: clip(contact, compact ? 100 : 140),
      phone: clip(phone, 40),
      email: clip(email, 56),
      location: clip(location, 64),
      website: clip(website, 56),
    );
  }
}
