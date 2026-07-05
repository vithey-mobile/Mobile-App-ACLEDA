import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class ApplicationDescriptionField extends StatelessWidget {
  const ApplicationDescriptionField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Description (Optional)',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.authHeading),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: 4,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'Write a short message to the employer…',
              filled: true,
              fillColor: AppColors.authInputFill,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
