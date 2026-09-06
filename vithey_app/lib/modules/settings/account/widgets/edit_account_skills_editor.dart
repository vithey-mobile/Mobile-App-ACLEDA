import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/models/ai_skill_scorer.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class EditAccountSkillsEditor extends StatelessWidget {
  const EditAccountSkillsEditor({
    super.key,
    required this.skills,
    required this.onAdd,
    required this.onRemove,
    required this.onUpdate,
  });

  final List<ProfileSkill> skills;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int index, {String? name}) onUpdate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = context.scheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.subtleShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VitheyIcon(LucideIcons.brain, size: 18, color: primary),
              const SizedBox(width: 8),
              Text('Skills', style: context.text.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'AI sets each score when you update a skill.',
            style: context.text.bodySmall?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (skills.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('No skills yet', style: TextStyle(color: colors.muted)),
            ),
          ...skills.asMap().entries.map((entry) {
            final index = entry.key;
            final skill = entry.value;
            return _SkillRow(
              key: ValueKey('skill-$index-${skill.name}-${skill.proficiency}'),
              skill: skill,
              onRemove: () => onRemove(index),
              onNameChanged: (name) => onUpdate(index, name: name),
            );
          }),
          Center(
            child: CustomButton(
              label: 'Add Skill',
              icon: LucideIcons.circlePlus,
              variant: CustomButtonVariant.ghost,
              foregroundColor: AppColors.primary,
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatefulWidget {
  const _SkillRow({
    super.key,
    required this.skill,
    required this.onRemove,
    required this.onNameChanged,
  });

  final ProfileSkill skill;
  final VoidCallback onRemove;
  final ValueChanged<String> onNameChanged;

  @override
  State<_SkillRow> createState() => _SkillRowState();
}

class _SkillRowState extends State<_SkillRow> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.skill.name);
  }

  @override
  void didUpdateWidget(covariant _SkillRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skill.name != widget.skill.name &&
        _nameController.text != widget.skill.name) {
      _nameController.text = widget.skill.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final aiPercent = AiSkillScorer.scoreSkill(widget.skill);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(VitheyRadii.field),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: VitheyField(
              controller: _nameController,
              hint: 'Skill name',
              onChanged: widget.onNameChanged,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AI $aiPercent%',
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          VitheyIconButton(
            icon: LucideIcons.x,
            variant: VitheyIconButtonVariant.destructive,
            tooltip: 'Remove skill',
            onTap: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
