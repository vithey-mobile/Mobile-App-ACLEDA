import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:flutter/material.dart';

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
      child: VitheyField(
        controller: controller,
        label: 'Application Description (Optional)',
        hint: 'Write a short message to the employer…',
        enabled: enabled,
        maxLines: 4,
        maxLength: 2000,
      ),
    );
  }
}
