import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class StudentIdUploadBox extends StatelessWidget {
  const StudentIdUploadBox({
    super.key,
    required this.fileName,
    required this.onPick,
    required this.onRemove,
  });

  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Student ID', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (fileName == null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.authBorder, width: 1.5),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 42, color: AppColors.authMuted),
                    SizedBox(height: 10),
                    Text('Click to upload', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('PNG, JPG or PDF (max. 5MB)', style: TextStyle(color: AppColors.authMuted, fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.authInputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.authBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(fileName!, maxLines: 1, overflow: TextOverflow.ellipsis)),
                TextButton(onPressed: onPick, child: const Text('Replace')),
                IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
              ],
            ),
          ),
      ],
    );
  }
}
