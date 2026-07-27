import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_tile_divider.dart';

class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.label,
    required this.subtitle,
  });

  final String code;
  final String label;
  final String subtitle;
}

const languageOptions = [
  LanguageOption(code: 'en', label: 'English (US)', subtitle: 'English'),
  LanguageOption(code: 'km', label: 'Khmer', subtitle: 'ភាសាខ្មែរ'),
];

class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({
    super.key,
    required this.selectedCode,
    required this.onSelect,
  });

  final String selectedCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.heading,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.appColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.subtleShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < languageOptions.length; i++) ...[
                      if (i > 0) const SettingsTileDivider(),
                      _LanguageOptionTile(
                        option: languageOptions[i],
                        isSelected: selectedCode == languageOptions[i].code,
                        onTap: () => onSelect(languageOptions[i].code),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;

    return Material(
      color: context.appColors.cardSurface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.language_outlined, color: primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.heading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: TextStyle(fontSize: 12, color: context.appColors.muted),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check, color: primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
