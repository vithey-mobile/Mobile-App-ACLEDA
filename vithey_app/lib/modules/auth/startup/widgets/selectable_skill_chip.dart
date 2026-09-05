import 'package:flutter/material.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/startup_selection_style.dart';

/// Startup 1 pill chip — unique shape; shared selection chrome.
class SelectableSkillChip extends StatelessWidget {
  const SelectableSkillChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = StartupSelectionStyle.fill(context, selected: selected);
    final border = StartupSelectionStyle.border(context, selected: selected);
    final iconColor = StartupSelectionStyle.icon(context, selected: selected);
    final labelColor = StartupSelectionStyle.label(context, selected: selected);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
