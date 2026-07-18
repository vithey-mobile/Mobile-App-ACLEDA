import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class SubmittedDocumentCard extends StatelessWidget {
  const SubmittedDocumentCard({super.key, this.fileName});

  /// Uploaded file from the verification form. When null/empty, only the
  /// Student ID Card status row is shown.
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final uploadedName = fileName?.trim();
    final hasUploadedFile =
        uploadedName != null && uploadedName.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submitted Documents',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.badge_outlined,
                color: context.appColors.muted,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Student ID Card',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.appColors.heading,
                  ),
                ),
              ),
              const Text(
                'Uploaded',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (hasUploadedFile) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: context.appColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _iconForName(uploadedName),
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    uploadedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.appColors.heading,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_outlined;
    }
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}
