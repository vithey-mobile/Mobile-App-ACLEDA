import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';

class ShareSheet extends StatefulWidget {
  const ShareSheet({
    super.key,
    required this.post,
    required this.onShared,
  });

  final FeedPost post;
  final VoidCallback onShared;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  int _selected = 0;
  bool _isLoading = false;
  final _repo = Get.find<PostRepository>();

  Future<void> _submit(int option) async {
    if (_isLoading) return;
    setState(() {
      _selected = option;
      _isLoading = true;
    });

    try {
      if (option == 0) {
        await _repo.sharePublicly(widget.post.id);
        widget.onShared();
        Get.back();
        Get.snackbar(AppStrings.appName, 'Shared for everyone');
      } else {
        await _repo.savePrivately(widget.post.id);
        Get.back();
        Get.snackbar(AppStrings.appName, 'Saved privately');
      }
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not complete action');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.authMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How do you want to share this post?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _ShareOption(
            title: 'Share for everyone',
            selected: _selected == 0,
            loading: _isLoading && _selected == 0,
            onTap: () => _submit(0),
          ),
          const SizedBox(height: 8),
          _ShareOption(
            title: 'Save this post in private',
            selected: _selected == 1,
            loading: _isLoading && _selected == 1,
            onTap: () => _submit(1),
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.title,
    required this.selected,
    required this.onTap,
    this.loading = false,
  });

  final String title;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppColors.primary : AppColors.authBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.authMuted,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            if (loading) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}
