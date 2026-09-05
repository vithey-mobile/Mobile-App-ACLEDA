import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PrivacyFooterNote extends StatelessWidget {
  const PrivacyFooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 14, color: context.appColors.muted),
          const SizedBox(width: 6),
          Text(
            AppStrings.privacyNote,
            style: TextStyle(fontSize: 12, color: context.appColors.muted),
          ),
        ],
      ),
    );
  }
}
