import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:intl/intl.dart';

class MessageActionRow extends StatefulWidget {
  const MessageActionRow({
    super.key,
    required this.message,
    required this.onCopy,
    required this.onShare,
    this.onRegenerate,
  });

  final AiMessage message;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onRegenerate;

  @override
  State<MessageActionRow> createState() => _MessageActionRowState();
}

class _MessageActionRowState extends State<MessageActionRow> {
  /// null = none, true = liked, false = disliked
  bool? _feedback;

  void _setFeedback(bool liked) {
    setState(() {
      _feedback = _feedback == liked ? null : liked;
    });
  }

  Future<void> _showSources(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sources = _defaultSources;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: context.appColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const AppLogo(size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Sources',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.heading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Reference resources used for this reply',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                ...sources.map(
                  (source) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.appColors.inputFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              context.appColors.border.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.appColors.border
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            child: Image.asset(
                              source.logoAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  source.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: context.appColors.heading,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  source.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.appColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.muted;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          _ActionIcon(
            icon: Icons.copy_rounded,
            tooltip: 'Copy',
            color: muted,
            onPressed: widget.onCopy,
          ),
          if (widget.onRegenerate != null)
            _ActionIcon(
              icon: Icons.refresh_rounded,
              tooltip: 'Regenerate',
              color: muted,
              onPressed: widget.onRegenerate!,
            ),
          _ActionIcon(
            icon: Icons.share_outlined,
            tooltip: 'Share',
            color: muted,
            onPressed: widget.onShare,
          ),
          _ActionIcon(
            icon: _feedback == true
                ? Icons.thumb_up_alt_rounded
                : Icons.thumb_up_alt_outlined,
            tooltip: 'Like',
            color: _feedback == true ? AppColors.primary : muted,
            onPressed: () => _setFeedback(true),
          ),
          _ActionIcon(
            icon: _feedback == false
                ? Icons.thumb_down_alt_rounded
                : Icons.thumb_down_alt_outlined,
            tooltip: 'Unlike',
            color: _feedback == false ? AppColors.primary : muted,
            onPressed: () => _setFeedback(false),
          ),
          Tooltip(
            message: 'Sources',
            child: InkWell(
              onTap: () => _showSources(context),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: AppLogo(size: 22),
              ),
            ),
          ),
          if (widget.message.status == AiMessageStatus.stopped) ...[
            const SizedBox(width: 4),
            Text(
              'Stopped',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
          const Spacer(),
          Text(
            _formatTimestamp(widget.message.createdAt),
            style: TextStyle(fontSize: 11, color: muted),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inHours < 24 &&
        now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return DateFormat('h:mm a').format(time);
    }
    return RelativeTime.format(time);
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      icon: Icon(icon, size: 18, color: color),
    );
  }
}

class _ChatSourceRef {
  const _ChatSourceRef({
    required this.title,
    required this.subtitle,
    required this.logoAsset,
  });

  final String title;
  final String subtitle;
  final String logoAsset;
}

const _defaultSources = [
  _ChatSourceRef(
    title: 'Vithey Career Guide',
    subtitle: 'Campus jobs, CV tips, and interview prep',
    logoAsset: AppAssets.logoApp,
  ),
  _ChatSourceRef(
    title: 'Vithey Finance',
    subtitle: 'Student verification and payment guidance',
    logoAsset: AppAssets.walletIcon,
  ),
  _ChatSourceRef(
    title: 'Vithey Knowledge Base',
    subtitle: 'In-app help and product documentation',
    logoAsset: AppAssets.logoApp,
  ),
];
