import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/ai_career_readiness.dart';
import 'package:aub_connect_app/data/models/ai_skill_score.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Block 4 — Skill Score / Career readiness (AI-SK-03…07, mock data).
///
/// Shown on the **own** Profile All tab only. Visitor profiles never see
/// the AI breakdown (AI-SK-08): the parent gates on `isOwnProfile` and
/// this widget hides itself when `USE_AI_SKILLS` is off.
class ProfileSkillScoreCard extends StatefulWidget {
  const ProfileSkillScoreCard({super.key});

  @override
  State<ProfileSkillScoreCard> createState() => _ProfileSkillScoreCardState();
}

class _ProfileSkillScoreCardState extends State<ProfileSkillScoreCard> {
  late Future<AiCareerReadiness> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    List<ProfileSkill>? skills;
    if (Get.isRegistered<ProfileController>()) {
      skills = Get.find<ProfileController>().profile.value?.skills;
    }
    _future = Get.find<AiRepository>().skillScores(skills: skills);
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<FeatureFlags>().useAiSkills) return const SizedBox.shrink();
    return FutureBuilder<AiCareerReadiness>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoadingWidget(),
          );
        }
        final readiness = snapshot.data;
        if (readiness == null) return const SizedBox.shrink();
        return _Card(readiness: readiness);
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.readiness});

  final AiCareerReadiness readiness;

  String get _label {
    final score = readiness.overallScore;
    if (score >= 80) return 'Job-ready';
    if (score >= 65) return 'Strong';
    if (score >= 50) return 'Getting there';
    return 'Early days';
  }

  void _openChatbot(String prompt) =>
      Get.toNamed(AppRoutes.chatbot, arguments: prompt);

  @override
  Widget build(BuildContext context) {
    final skills = readiness.topSkills;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.inputFill.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _OverallRing(score: readiness.overallScore),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Career readiness',
                      style: context.text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _label,
                      style: context.text.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your skills, posts, applications and attachments',
                      style: context.text.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Skills',
              style: context.text.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final skill in skills) ...[
              _SkillScoreRow(skill: skill),
              if (skill != skills.last) const SizedBox(height: 10),
            ],
          ],
          if (readiness.suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Top 3 skills to improve',
              style: context.text.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final suggestion in readiness.suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VitheyIcon(
                      LucideIcons.lightbulb,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: context.text.bodySmall?.copyWith(
                          height: 1.35,
                          color: context.appColors.heading,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Improve skills',
                  variant: CustomButtonVariant.primary,
                  onPressed: () {
                    final weakest = skills.isEmpty
                        ? 'my weakest skill'
                        : skills.last.skillName;
                    _openChatbot(
                      'I want to improve my $weakest skill. '
                      'Can you give me a simple learning plan?',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Test my skills',
                  variant: CustomButtonVariant.outline,
                  onPressed: () {
                    // AI-SK-05: micro-assessment via chatbot.
                    final topSkill = skills.isEmpty
                        ? 'Flutter'
                        : skills.first.skillName;
                    _openChatbot('Ask me 3 $topSkill questions');
                  },
                ),
              ),
            ],
          ),
          const _HowScoreIsCalculated(),
        ],
      ),
    );
  }
}

/// Overall readiness ring (0–100) — same ring style as profile skill rings.
class _OverallRing extends StatelessWidget {
  const _OverallRing({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: score.clamp(0, 100) / 100,
              strokeWidth: 7,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
              backgroundColor: context.appColors.inputFill,
              color: AppColors.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: context.text.headlineSmall,
              ),
              Text(
                '/100',
                style: context.text.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Per-skill compact row: AI score only (no manual self-rating).
class _SkillScoreRow extends StatelessWidget {
  const _SkillScoreRow({required this.skill});

  final AiSkillScore skill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                skill.skillName,
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.appColors.heading,
                ),
              ),
            ),
            Text(
              'AI ${skill.aiScore}%',
              style: context.text.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _Bar(value: skill.aiScore, color: AppColors.primary),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 5,
        child: LinearProgressIndicator(
          value: value.clamp(0, 100) / 100,
          minHeight: 5,
          backgroundColor: context.appColors.inputFill,
          color: color,
        ),
      ),
    );
  }
}

/// AI-SK-07: transparent helper — simple rules, no black box.
class _HowScoreIsCalculated extends StatefulWidget {
  const _HowScoreIsCalculated();

  @override
  State<_HowScoreIsCalculated> createState() => _HowScoreIsCalculatedState();
}

class _HowScoreIsCalculatedState extends State<_HowScoreIsCalculated> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(VitheyRadii.field),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VitheyIcon(
                  LucideIcons.circleHelp,
                  size: 16,
                  color: context.appColors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  'How this score is calculated',
                  style: context.text.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                VitheyIcon(
                  _expanded
                      ? LucideIcons.chevronUp
                      : LucideIcons.chevronDown,
                  size: 16,
                  color: context.appColors.muted,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 22),
            child: Text(
              'Your AI score uses activity signals (related posts, applications, '
              'chat practice) and any proof attachments you link when adding or '
              'updating a skill. It is a guide, not a grade — linking evidence '
              'or practising raises your score.',
              style: context.text.labelMedium?.copyWith(height: 1.4),
            ),
          ),
      ],
    );
  }
}
