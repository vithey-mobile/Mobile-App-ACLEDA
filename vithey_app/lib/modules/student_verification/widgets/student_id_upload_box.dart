import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

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
                  border: Border.all(color: context.appColors.border, width: 1.5),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 42, color: context.appColors.muted),
                    const SizedBox(height: 10),
                    const Text('Click to upload', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('PNG, JPG or PDF (max. 5MB)', style: TextStyle(color: context.appColors.muted, fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.appColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(fileName!, maxLines: 1, overflow: TextOverflow.ellipsis)),
                shad.Button.ghost(onPressed: onPick, child: const shad.Text('Replace')),
                IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
              ],
            ),
          ),
      ],
    );
  }
}
