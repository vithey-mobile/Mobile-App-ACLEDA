import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:flutter/material.dart';

class EditAccountFieldCard extends StatelessWidget {
  const EditAccountFieldCard({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return VitheyInfoCard(
      icon: icon,
      label: label,
      child: VitheyField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}
