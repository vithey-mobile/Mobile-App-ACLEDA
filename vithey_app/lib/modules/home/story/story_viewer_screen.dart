import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/story_item.dart';

/// Full-screen Instagram/Telegram-style Story Viewer.
/// Supports multi-segment progress bars, tap to skip/back, hold to pause,
/// vertical drag to dismiss, quick emoji reactions, and reply composer.
class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
    this.onDeleteStory,
    this.onAddMoreStory,
  });

  final List<UserStoryGroup> storyGroups;
  final int initialGroupIndex;
  final void Function(String storyId)? onDeleteStory;
  final VoidCallback? onAddMoreStory;

  static Future<void> open(
    BuildContext context, {
    required List<UserStoryGroup> storyGroups,
    int initialGroupIndex = 0,
    void Function(String storyId)? onDeleteStory,
    VoidCallback? onAddMoreStory,
  }) {
    if (storyGroups.isEmpty) return Future.value();
    final safeIndex = initialGroupIndex.clamp(0, storyGroups.length - 1);
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        pageBuilder: (_, __, ___) => StoryViewerScreen(
          storyGroups: storyGroups,
          initialGroupIndex: safeIndex,
          onDeleteStory: onDeleteStory,
          onAddMoreStory: onAddMoreStory,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentGroupIndex;
  int _currentStoryIndex = 0;
  late AnimationController _progressController;

  bool _isPaused = false;
  double _dragOffsetY = 0.0;
  final _replyController = TextEditingController();
  final List<_FlyingReaction> _flyingReactions = [];

  static const Duration _storyDuration = Duration(seconds: 5);

  UserStoryGroup get _currentGroup =>
      widget.storyGroups[_currentGroupIndex.clamp(0, widget.storyGroups.length - 1)];

  StoryItem get _currentStory {
    final stories = _currentGroup.stories;
    return stories[_currentStoryIndex.clamp(0, stories.length - 1)];
  }

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex.clamp(0, widget.storyGroups.length - 1);

    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _advanceStory();
      }
    });

    _startCurrentStory();
  }

  void _startCurrentStory() {
    _progressController.stop();
    _progressController.value = 0.0;
    _progressController.forward();
  }

  void _advanceStory() {
    if (!mounted) return;
    final stories = _currentGroup.stories;
    if (_currentStoryIndex < stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _startCurrentStory();
    } else {
      // Advance to next group
      if (_currentGroupIndex < widget.storyGroups.length - 1) {
        setState(() {
          _currentGroupIndex++;
          _currentStoryIndex = 0;
        });
        _startCurrentStory();
      } else {
        // End of all stories
        Navigator.of(context).maybePop();
      }
    }
  }

  void _previousStory() {
    if (!mounted) return;
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _startCurrentStory();
    } else {
      // Go to previous group
      if (_currentGroupIndex > 0) {
        setState(() {
          _currentGroupIndex--;
          final prevStories = widget.storyGroups[_currentGroupIndex].stories;
          _currentStoryIndex = (prevStories.length - 1).clamp(0, 99);
        });
        _startCurrentStory();
      } else {
        // At start of first group, replay current story
        _startCurrentStory();
      }
    }
  }

  void _pause() {
    if (_isPaused) return;
    setState(() => _isPaused = true);
    _progressController.stop();
  }

  void _resume() {
    if (!_isPaused) return;
    setState(() => _isPaused = false);
    _progressController.forward();
  }

  void _handleTap(TapUpDetails details) {
    if (_isPaused) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth * 0.32) {
      _previousStory();
    } else {
      _advanceStory();
    }
  }

  void _addFlyingReaction(String emoji) {
    HapticFeedback.lightImpact();
    final random = math.Random();
    setState(() {
      _flyingReactions.add(
        _FlyingReaction(
          id: DateTime.now().millisecondsSinceEpoch.toString() + random.nextInt(999).toString(),
          emoji: emoji,
          startX: 80.0 + random.nextDouble() * 200,
        ),
      );
    });

    // Send toast
    Get.snackbar(
      _currentGroup.authorName,
      'Sent $emoji to story',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    _replyController.clear();
    FocusScope.of(context).unfocus();

    Get.snackbar(
      _currentGroup.authorName,
      'Reply sent: "$text"',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  void _confirmDelete() {
    _pause();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this story?'),
        content: const Text('This will remove the story from your profile and highlights.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resume();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDeleteStory?.call(_currentStory.id);
              Navigator.of(context).maybePop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = _currentGroup;
    final story = _currentStory;
    final isOwn = group.isOwn;

    // Drag-down dismiss translation
    final dragScale = (1.0 - (_dragOffsetY / 1200)).clamp(0.85, 1.0);
    final dragOpacity = (1.0 - (_dragOffsetY / 400)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: dragOpacity),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0 || _dragOffsetY > 0) {
            setState(() {
              _dragOffsetY = (_dragOffsetY + details.delta.dy).clamp(0.0, 500.0);
            });
            _pause();
          }
        },
        onVerticalDragEnd: (details) {
          if (_dragOffsetY > 120 || (details.primaryVelocity ?? 0) > 400) {
            Navigator.of(context).maybePop();
          } else {
            setState(() {
              _dragOffsetY = 0.0;
            });
            _resume();
          }
        },
        child: Transform.translate(
          offset: Offset(0, _dragOffsetY),
          child: Transform.scale(
            scale: dragScale,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_dragOffsetY > 0 ? 28 : 0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1) Story Canvas Content
                  _buildStoryContent(story),

                  // 2) Top subtle vignette gradient
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.75),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3) Bottom subtle vignette gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 180,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4) Interactive touch zones (Left 32% back, Right 68% forward, Long-press pause)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapUp: _handleTap,
                      onLongPressStart: (_) => _pause(),
                      onLongPressEnd: (_) => _resume(),
                    ),
                  ),

                  // 5) Top Controls (Progress bars & Author Header)
                  AnimatedOpacity(
                    opacity: _isPaused ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Multi-segment progress indicators
                            _buildProgressBars(group.stories.length),
                            const SizedBox(height: 10),

                            // Author Header Row
                            Row(
                              children: [
                                UserAvatar(
                                  name: group.authorName,
                                  imageUrl: group.authorAvatar,
                                  radius: 17,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              group.authorName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                letterSpacing: -0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isOwn) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'You',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        RelativeTime.format(story.createdAt),
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.75),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOwn && widget.onAddMoreStory != null)
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      widget.onAddMoreStory?.call();
                                    },
                                    icon: const VitheyIcon(
                                      LucideIcons.plus,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    tooltip: 'Add to Story',
                                  ),
                                if (isOwn)
                                  IconButton(
                                    onPressed: _confirmDelete,
                                    icon: const VitheyIcon(
                                      LucideIcons.trash2,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    tooltip: 'Delete Story',
                                  ),
                                IconButton(
                                  onPressed: () => Share.share(
                                    'Check out this story from ${group.authorName} on Vithey!',
                                  ),
                                  icon: const VitheyIcon(
                                    LucideIcons.share2,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Share',
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).maybePop(),
                                  icon: const VitheyIcon(
                                    LucideIcons.x,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Close',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 6) Floating Reactions Animation Layer
                  ..._flyingReactions.map((reaction) {
                    return _AnimatedFlyingEmoji(
                      key: ValueKey(reaction.id),
                      reaction: reaction,
                      onComplete: () {
                        setState(() {
                          _flyingReactions.removeWhere((r) => r.id == reaction.id);
                        });
                      },
                    );
                  }),

                  // 7) Bottom Story Actions / Reply Bar
                  AnimatedOpacity(
                    opacity: _isPaused ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Quick emoji reaction strip (for other users' stories)
                              if (!isOwn)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _EmojiReactionButton(
                                        emoji: '❤️',
                                        onTap: () => _addFlyingReaction('❤️'),
                                      ),
                                      _EmojiReactionButton(
                                        emoji: '🔥',
                                        onTap: () => _addFlyingReaction('🔥'),
                                      ),
                                      _EmojiReactionButton(
                                        emoji: '😂',
                                        onTap: () => _addFlyingReaction('😂'),
                                      ),
                                      _EmojiReactionButton(
                                        emoji: '😮',
                                        onTap: () => _addFlyingReaction('😮'),
                                      ),
                                      _EmojiReactionButton(
                                        emoji: '👏',
                                        onTap: () => _addFlyingReaction('👏'),
                                      ),
                                      _EmojiReactionButton(
                                        emoji: '💯',
                                        onTap: () => _addFlyingReaction('💯'),
                                      ),
                                    ],
                                  ),
                                ),

                              // Text Reply or Insights Bar
                              if (!isOwn)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _replyController,
                                                onTap: _pause,
                                                onSubmitted: (_) {
                                                  _sendReply();
                                                  _resume();
                                                },
                                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                                decoration: InputDecoration(
                                                  hintText: 'Reply to ${group.authorName}…',
                                                  hintStyle: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.7),
                                                    fontSize: 14,
                                                  ),
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _sendReply,
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary,
                                                ),
                                                child: const Center(
                                                  child: VitheyIcon(
                                                    LucideIcons.send,
                                                    size: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const VitheyIcon(
                                        LucideIcons.eye,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Seen by 42 students',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBars(int count) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        return Row(
          children: List.generate(count, (index) {
            double fill = 0.0;
            if (index < _currentStoryIndex) {
              fill = 1.0;
            } else if (index == _currentStoryIndex) {
              fill = _progressController.value;
            } else {
              fill = 0.0;
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fill,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStoryContent(StoryItem story) {
    // 1) Photo / Media Story
    if (story.isMediaImage) {
      final url = story.mediaUrl!;
      Widget imageWidget;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        imageWidget = CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          errorWidget: (_, __, ___) => _buildFallbackBackground(),
        );
      } else if (url.startsWith('assets/')) {
        imageWidget = Image.asset(url, fit: BoxFit.cover);
      } else {
        imageWidget = Image.file(File(url), fit: BoxFit.cover);
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          if (story.hasVignette)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.1,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
          if (story.text != null && story.text!.trim().isNotEmpty)
            Center(
              child: Transform.translate(
                offset: Offset(story.textDx, story.textDy),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _buildStoryText(
                    story.text!,
                    story.fontStyle,
                    story.textAlignment,
                  ),
                ),
              ),
            ),
          if (story.sticker != null || story.vibeType != null)
            Center(
              child: Transform.translate(
                offset: Offset(
                  story.stickerDx,
                  story.stickerDy != 0.0 ? story.stickerDy : 150.0,
                ),
                child: _buildStickerBadge(story),
              ),
            ),
        ],
      );
    }

    // 2) Gradient & Text Story
    final gradient = story.gradientColors ??
        const [Color(0xFF6366F1), Color(0xFF9333EA)];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (story.hasVignette)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.1,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
          // Dynamic Positioned Text
          Center(
            child: Transform.translate(
              offset: Offset(story.textDx, story.textDy),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _buildStoryText(
                  story.text ?? '✨',
                  story.fontStyle,
                  story.textAlignment,
                ),
              ),
            ),
          ),

          // Optional vibe or sticker badge
          if (story.sticker != null || story.vibeType != null)
            Center(
              child: Transform.translate(
                offset: Offset(
                  story.stickerDx,
                  story.stickerDy != 0.0 ? story.stickerDy : 150.0,
                ),
                child: _buildStickerBadge(story),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: const Center(
        child: VitheyIcon(LucideIcons.image, size: 48, color: Colors.white38),
      ),
    );
  }

  Widget _buildStoryText(
    String text,
    String? fontStyle, [
    String textAlignment = 'center',
  ]) {
    TextStyle style;
    TextAlign align;
    switch (textAlignment) {
      case 'left':
        align = TextAlign.left;
        break;
      case 'right':
        align = TextAlign.right;
        break;
      case 'center':
      default:
        align = TextAlign.center;
    }

    switch (fontStyle) {
      case 'neon':
        style = const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          shadows: [
            Shadow(color: Color(0xFF06B6D4), blurRadius: 24),
            Shadow(color: Color(0xFF3B82F6), blurRadius: 12),
          ],
        );
        break;
      case 'bold':
        style = const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          shadows: [
            Shadow(color: Colors.black87, blurRadius: 16, offset: Offset(0, 3)),
          ],
        );
        break;
      case 'typewriter':
        style = const TextStyle(
          fontFamily: 'monospace',
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 10),
          ],
        );
        break;
      case 'serif':
        style = const TextStyle(
          fontFamily: 'Georgia',
          color: Colors.white,
          fontSize: 26,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 10),
          ],
        );
        break;
      case 'modern':
      default:
        style = const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.35,
          shadows: [
            Shadow(color: Colors.black87, blurRadius: 16, offset: Offset(0, 2)),
          ],
        );
    }

    return Text(
      text,
      textAlign: align,
      style: style,
    );
  }

  Widget _buildStickerBadge(StoryItem story) {
    if (story.vibeType == 'music') {
      return _buildMusicVibeWidget(
          story.vibeData ?? story.sticker ?? 'Lo-Fi Campus Beats');
    } else if (story.vibeType == 'poll') {
      return _InteractiveStoryPoll(
          pollData: story.vibeData ?? story.sticker ?? 'Study or Sleep? 😴 / 📚');
    } else if (story.vibeType == 'stamp') {
      return _buildStampWidget(story.vibeData ?? story.sticker ?? 'Phnom Penh');
    }
    return _buildStatusBadge(story.sticker ?? story.vibeData ?? '');
  }

  Widget _buildMusicVibeWidget(String track) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.music_note, color: Colors.white, size: 15),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  track,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _AnimatedSoundWaveBars(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStampWidget(String stamp) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF38BDF8), size: 14),
              const SizedBox(width: 5),
              Text(
                stamp,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String sticker) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            sticker,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmojiReactionButton extends StatelessWidget {
  const _EmojiReactionButton({
    required this.emoji,
    required this.onTap,
  });

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

class _FlyingReaction {
  final String id;
  final String emoji;
  final double startX;

  _FlyingReaction({
    required this.id,
    required this.emoji,
    required this.startX,
  });
}

class _AnimatedFlyingEmoji extends StatefulWidget {
  const _AnimatedFlyingEmoji({
    super.key,
    required this.reaction,
    required this.onComplete,
  });

  final _FlyingReaction reaction;
  final VoidCallback onComplete;

  @override
  State<_AnimatedFlyingEmoji> createState() => _AnimatedFlyingEmojiState();
}

class _AnimatedFlyingEmojiState extends State<_AnimatedFlyingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final progress = _anim.value;
        final dy = (1.0 - progress) * 360;
        final opacity = (1.0 - (progress * 1.2)).clamp(0.0, 1.0);
        final scale = 1.0 + progress * 1.2;
        final wobble = math.sin(progress * math.pi * 3) * 16;

        return Positioned(
          bottom: 110 + (360 - dy),
          left: widget.reaction.startX + wobble,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Text(
                widget.reaction.emoji,
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedSoundWaveBars extends StatefulWidget {
  const _AnimatedSoundWaveBars();

  @override
  State<_AnimatedSoundWaveBars> createState() => _AnimatedSoundWaveBarsState();
}

class _AnimatedSoundWaveBarsState extends State<_AnimatedSoundWaveBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(6 + 8 * (math.sin(t * math.pi))),
            const SizedBox(width: 2.5),
            _bar(14 - 6 * (math.cos(t * math.pi))),
            const SizedBox(width: 2.5),
            _bar(5 + 9 * (math.sin(t * math.pi * 1.4).abs())),
            const SizedBox(width: 2.5),
            _bar(11 + 5 * (math.cos(t * math.pi * 0.9).abs())),
          ],
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 3,
      height: height.clamp(4.0, 16.0),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _InteractiveStoryPoll extends StatefulWidget {
  const _InteractiveStoryPoll({required this.pollData});
  final String pollData;

  @override
  State<_InteractiveStoryPoll> createState() => _InteractiveStoryPollState();
}

class _InteractiveStoryPollState extends State<_InteractiveStoryPoll> {
  int? _votedIndex;

  @override
  Widget build(BuildContext context) {
    final parts = widget.pollData.split('?');
    final question = parts.isNotEmpty ? '${parts.first.trim()}?' : widget.pollData;
    final optionsPart = parts.length > 1 ? parts[1].trim() : 'Yes / No';
    final options = optionsPart.split('/').map((s) => s.trim()).toList();
    final opt1 = options.isNotEmpty ? options[0] : 'Yes';
    final opt2 = options.length > 1 ? options[1] : 'No';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _votedIndex = 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _votedIndex == 0
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _votedIndex == 0
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _votedIndex != null ? '$opt1 64%' : opt1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _votedIndex = 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _votedIndex == 1
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _votedIndex == 1
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _votedIndex != null ? '$opt2 36%' : opt2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
