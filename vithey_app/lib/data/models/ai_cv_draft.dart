/// Structured AI-generated CV draft (editable before save).
class AiCvDraft {
  const AiCvDraft({
    required this.fullName,
    required this.summary,
    required this.skills,
    required this.education,
    required this.experience,
    required this.projects,
    required this.contact,
    this.templateId,
    this.incompleteProfile = false,
    this.incompleteMessage,
  });

  final String fullName;
  final String summary;
  final List<String> skills;
  final List<String> education;
  final List<String> experience;
  final List<String> projects;
  final String contact;

  /// Selected gallery template id (layout styling).
  final String? templateId;
  final bool incompleteProfile;
  final String? incompleteMessage;

  AiCvDraft copyWith({
    String? fullName,
    String? summary,
    List<String>? skills,
    List<String>? education,
    List<String>? experience,
    List<String>? projects,
    String? contact,
    String? templateId,
    bool? incompleteProfile,
    String? incompleteMessage,
  }) {
    return AiCvDraft(
      fullName: fullName ?? this.fullName,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      contact: contact ?? this.contact,
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
}
