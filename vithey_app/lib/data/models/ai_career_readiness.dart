import 'package:aub_connect_app/data/models/ai_skill_score.dart';

/// Overall career readiness (Block 4 — AI-SK-03, AI-SK-04).
///
/// Aggregate of per-skill AI scores plus top-3 improvement suggestions.
class AiCareerReadiness {
  const AiCareerReadiness({
    required this.overallScore,
    required this.topSkills,
    required this.suggestions,
  });

  /// Overall readiness 0–100 (weighted from per-skill AI scores).
  final int overallScore;

  /// Per-skill scores, strongest first.
  final List<AiSkillScore> topSkills;

  /// Up to 3 next skills to improve (AI-SK-04).
  final List<String> suggestions;

  factory AiCareerReadiness.fromJson(Map<String, dynamic> json) {
    final skillsRaw = json['top_skills'];
    final skills = <AiSkillScore>[];
    if (skillsRaw is List) {
      for (final item in skillsRaw) {
        if (item is Map<String, dynamic>) {
          skills.add(AiSkillScore.fromJson(item));
        } else if (item is Map) {
          skills.add(AiSkillScore.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    final suggestionsRaw = json['suggestions'];
    return AiCareerReadiness(
      overallScore: (json['overall_score'] as num?)?.toInt() ?? 0,
      topSkills: skills,
      suggestions: suggestionsRaw is List
          ? [
              for (final s in suggestionsRaw)
                if (s != null) s.toString(),
            ]
          : const [],
    );
  }
}
