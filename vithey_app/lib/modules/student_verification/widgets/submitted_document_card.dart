import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class SubmittedDocumentCard extends StatelessWidget {
  const SubmittedDocumentCard({super.key, required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.authBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Submitted Documents', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.upload_file, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(fileName)),
              const Text('Uploaded', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
