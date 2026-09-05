import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(color: colors.subtleShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined, size: 18, color: primary),
              const SizedBox(width: 8),
              Text('Skills', style: TextStyle(color: colors.muted, fontSize: 13)),
            ],
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
              icon: Icons.add_circle_outline,
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
    if (oldWidget.skill.name != widget.skill.name && _nameController.text != widget.skill.name) {
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
    final proficiency = widget.skill.proficiency.clamp(0, 100).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: VitheyField(
                  controller: _nameController,
                  hint: 'Skill name',
                  onChanged: widget.onNameChanged,
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: Icon(Icons.close, color: colors.muted, size: 20),
                tooltip: 'Remove skill',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Proficiency', style: TextStyle(fontSize: 12, color: colors.muted)),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: proficiency,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: null,
                ),
              ),
              Text('${proficiency.round()}%', style: TextStyle(fontSize: 12, color: colors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
