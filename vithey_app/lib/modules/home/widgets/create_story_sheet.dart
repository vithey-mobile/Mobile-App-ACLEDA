import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';

/// Next-Generation Creative Story Studio tailored for campus Gen-Z.
/// Features full-screen edge-to-edge canvas with ambient aura halo,
/// 5 curated typography personalities, animated soundwave music vibes,
/// interactive campus poll cards, minimalist time stamps, and a sleek
/// floating frosted tool dock.
class CreateStorySheet extends StatefulWidget {
  const CreateStorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, _, __) => const Scaffold(
          backgroundColor: Color(0xFF070709),
          body: CreateStorySheet(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends State<CreateStorySheet>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _imagePicker = ImagePicker();

  String? _selectedImagePath;
  int _selectedGradientIndex = 0;
  int _selectedStyleIndex = 0;
  String _textAlignment = 'center'; // 'left', 'center', 'right'
  bool _hasHighlight = false;
  bool _hasVignette = false;

  // Gen-Z Vibe Widget State
  String? _selectedVibeType; // 'music', 'poll', 'stamp', 'status'
  String? _selectedVibeData;
  String? _selectedSticker;

  // Active Tool Dock Drawer (0: None, 1: Text, 2: Aura, 3: Vibes)
  int _activeDrawer = 0;
  bool _isSharing = false;

  // Draggable element offsets
  Offset _textOffset = Offset.zero;
  Offset _vibeOffset = const Offset(0, 140);
  bool _isDraggingText = false;
  bool _isDraggingVibe = false;

  static const List<String> _fontStyles = [
    'modern',
    'neon',
    'bold',
    'typewriter',
    'serif',
  ];

  static const List<String> _fontLabels = [
    'Clean Grotesque',
    'Kinetic Neon',
    'Poster Pill',
    'Cyber Mono',
    'Editorial Serif',
  ];

  // 8 Multi-Stop Curated Aura Gradients
  static const List<List<Color>> _auraGradients = [
    [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFC026D3)], // Neon Velvet
    [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)], // Matcha Mist
    [Color(0xFFE11D48), Color(0xFFF97316), Color(0xFFFBBF24)], // Peach Sorbet
    [Color(0xFF18181B), Color(0xFF1E293B), Color(0xFF84CC16)], // Cyber Acid Lime
    [Color(0xFF09090B), Color(0xFF18181B), Color(0xFF27272A)], // Deep Obsidian
    [Color(0xFFBE185D), Color(0xFFDB2777), Color(0xFF8B5CF6)], // Cherry Soda
    [Color(0xFF0E7490), Color(0xFF0284C7), Color(0xFF38BDF8)], // Nordic Ice
    [Color(0xFF451A03), Color(0xFF78350F), Color(0xFFB45309)], // Amber Espresso
  ];

  static const List<String> _auraNames = [
    'Neon Velvet',
    'Matcha Mist',
    'Peach Sorbet',
    'Cyber Lime',
    'Obsidian',
    'Cherry Soda',
    'Nordic Ice',
    'Amber Espresso',
  ];

  // Gen-Z Vibe Datasets
  static const List<String> _musicVibes = [
    'Lo-Fi Campus Beats · Chill',
    'Brown Coffee Run · Acoustic',
    'Midnight Code & Grind · 128 BPM',
    'Sunset Walk at AUB · Golden Hour',
  ];

  static const List<String> _campusPolls = [
    'Study or Sleep? 😴 / 📚',
    'Matcha or Iced Latte? 🍵 / ☕',
    'Library or Cafe? 📖 / 🎧',
    'Morning or Night Owl? ☀️ / 🌙',
  ];

  static const List<String> _statusTags = [
    '📚 Locked in at Library',
    '☕ Brown Coffee Run',
    '🔋 2% Battery & A Dream',
    '✨ Main Character Energy',
    '🎓 ACLEDA Life',
    '🔥 Midterm Grind',
    '💻 Building on Vithey',
    '📍 Phnom Penh Vibes',
    '🇰🇭 Proudly Khmer',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
      );
      if (picked != null) {
        setState(() {
          _selectedImagePath = picked.path;
          _activeDrawer = 0;
        });
      }
    } catch (_) {}
  }

  void _cycleFontStyle() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedStyleIndex = (_selectedStyleIndex + 1) % _fontStyles.length;
    });
  }

  void _cycleTextAlignment() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_textAlignment == 'center') {
        _textAlignment = 'left';
      } else if (_textAlignment == 'left') {
        _textAlignment = 'right';
      } else {
        _textAlignment = 'center';
      }
    });
  }

  void _toggleHighlight() {
    HapticFeedback.selectionClick();
    setState(() {
      _hasHighlight = !_hasHighlight;
    });
  }

  void _toggleVignette() {
    HapticFeedback.selectionClick();
    setState(() {
      _hasVignette = !_hasVignette;
    });
  }

  void _selectMusicVibe(String track) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedVibeType == 'music' && _selectedVibeData == track) {
        _selectedVibeType = null;
        _selectedVibeData = null;
        _selectedSticker = null;
      } else {
        _selectedVibeType = 'music';
        _selectedVibeData = track;
        _selectedSticker = track;
      }
    });
  }

  void _selectPollVibe(String poll) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedVibeType == 'poll' && _selectedVibeData == poll) {
        _selectedVibeType = null;
        _selectedVibeData = null;
        _selectedSticker = null;
      } else {
        _selectedVibeType = 'poll';
        _selectedVibeData = poll;
        _selectedSticker = poll;
      }
    });
  }

  void _selectStatusTag(String tag) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedVibeType == 'status' && _selectedVibeData == tag) {
        _selectedVibeType = null;
        _selectedVibeData = null;
        _selectedSticker = null;
      } else {
        _selectedVibeType = 'status';
        _selectedVibeData = tag;
        _selectedSticker = tag;
      }
    });
  }

  void _selectStampVibe() {
    HapticFeedback.selectionClick();
    const stamp = '📍 Phnom Penh · ACLEDA Campus';
    setState(() {
      if (_selectedVibeType == 'stamp') {
        _selectedVibeType = null;
        _selectedVibeData = null;
        _selectedSticker = null;
      } else {
        _selectedVibeType = 'stamp';
        _selectedVibeData = stamp;
        _selectedSticker = stamp;
      }
    });
  }

  void _clearVibeWidget() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedVibeType = null;
      _selectedVibeData = null;
      _selectedSticker = null;
    });
  }

  Future<void> _shareStory() async {
    if (_isSharing) return;
    final text = _textController.text.trim();
    if (text.isEmpty &&
        _selectedImagePath == null &&
        _selectedVibeData == null &&
        _selectedSticker == null) {
      Get.snackbar(
        'Empty Story',
        'Add some thoughts, an aura, or a vibe tag to share your story.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
      return;
    }

    setState(() => _isSharing = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final homeCtrl =
        Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    homeCtrl?.addUserStory(
      mediaUrl: _selectedImagePath,
      gradientColors: _selectedImagePath == null
          ? _auraGradients[_selectedGradientIndex]
          : null,
      text: text.isNotEmpty ? text : null,
      fontStyle: _fontStyles[_selectedStyleIndex],
      sticker: _selectedSticker ?? _selectedVibeData,
      vibeType: _selectedVibeType,
      vibeData: _selectedVibeData,
      textAlignment: _textAlignment,
      hasVignette: _hasVignette,
      textDx: _textOffset.dx,
      textDy: _textOffset.dy,
      stickerDx: _vibeOffset.dx,
      stickerDy: _vibeOffset.dy,
    );

    if (mounted) {
      Navigator.of(context).pop();
      Get.snackbar(
        'Story Live! ✨',
        'Your story is now glowing on the campus feed.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        icon: const Icon(LucideIcons.sparkles, color: Colors.white),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGradient = _auraGradients[_selectedGradientIndex];
    final activeStyle = _fontStyles[_selectedStyleIndex];
    final currentUser = Get.isRegistered<CurrentUserService>()
        ? Get.find<CurrentUserService>()
        : null;

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 80;

    return Container(
      color: const Color(0xFF070709),
      child: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 0) Ambient Aura Backlight Halo
            if (_selectedImagePath == null)
              _buildAmbientAuraHalo(currentGradient),

            // 1) Main Interactive Story Canvas
            Column(
              children: [
                // Top Studio Nav
                _buildTopStudioBar(),

                // Canvas Zone
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: _buildStudioCanvas(currentGradient, activeStyle),
                  ),
                ),

                // Floating Tool Dock & Bottom Bar
                if (!isKeyboardOpen) ...[
                  if (_activeDrawer > 0) _buildActiveDrawer(activeStyle),
                  _buildFloatingToolDock(currentUser),
                ] else
                  // Keyboard quick typography bar
                  _buildKeyboardQuickBar(activeStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Top Studio Bar
  // -------------------------------------------------------------
  Widget _buildTopStudioBar() {
    final hasEdits = _selectedImagePath != null ||
        _textController.text.isNotEmpty ||
        _selectedVibeData != null ||
        _hasVignette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          // Close button
          _FrostedGlassButton(
            icon: LucideIcons.x,
            onTap: () => Navigator.of(context).pop(),
            tooltip: 'Cancel',
          ),
          const Spacer(),

          // Studio Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _auraNames[_selectedGradientIndex].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Reset button
          if (hasEdits)
            _FrostedGlassButton(
              icon: LucideIcons.rotateCcw,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedImagePath = null;
                  _textController.clear();
                  _selectedVibeType = null;
                  _selectedVibeData = null;
                  _selectedSticker = null;
                  _hasVignette = false;
                  _textOffset = Offset.zero;
                  _vibeOffset = const Offset(0, 140);
                });
              },
              tooltip: 'Reset Canvas',
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Main Studio Canvas
  // -------------------------------------------------------------
  Widget _buildStudioCanvas(List<Color> gradient, String activeStyle) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: _selectedImagePath == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                )
              : null,
          color: Colors.black,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1) Photo background
            if (_selectedImagePath != null)
              Image.file(
                File(_selectedImagePath!),
                fit: BoxFit.cover,
              ),

            // 2) Optional Cinematic Vignette
            if (_hasVignette)
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.1,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),

            // 3) Canvas Tap Backdrop
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_activeDrawer > 0) {
                    setState(() => _activeDrawer = 0);
                  }
                  if (_focusNode.hasFocus) {
                    FocusScope.of(context).unfocus();
                  } else {
                    _focusNode.requestFocus();
                  }
                },
              ),
            ),

            // 4) Floating Draggable Text Element
            Center(
              child: Transform.translate(
                offset: _textOffset,
                child: GestureDetector(
                  onPanStart: (_) {
                    setState(() => _isDraggingText = true);
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _textOffset = Offset(
                        (_textOffset.dx + details.delta.dx)
                            .clamp(-140.0, 140.0),
                        (_textOffset.dy + details.delta.dy)
                            .clamp(-240.0, 240.0),
                      );
                    });
                  },
                  onPanEnd: (_) {
                    setState(() => _isDraggingText = false);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: _hasHighlight
                        ? const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: _hasHighlight
                          ? (_selectedStyleIndex == 1
                              ? const Color(0xFF0F172A).withValues(alpha: 0.88)
                              : Colors.black.withValues(alpha: 0.65))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: _isDraggingText
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.2,
                            )
                          : null,
                    ),
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: null,
                      textAlign: _resolveTextAlign(),
                      style: _resolveCanvasTextStyle(activeStyle),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Type your story...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5) Floating Draggable Vibe Badge
            if (_selectedVibeType != null && _selectedVibeData != null)
              Center(
                child: Transform.translate(
                  offset: _vibeOffset,
                  child: GestureDetector(
                    onPanStart: (_) {
                      setState(() => _isDraggingVibe = true);
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _vibeOffset = Offset(
                          (_vibeOffset.dx + details.delta.dx)
                              .clamp(-130.0, 130.0),
                          (_vibeOffset.dy + details.delta.dy)
                              .clamp(-240.0, 240.0),
                        );
                      });
                    },
                    onPanEnd: (_) {
                      setState(() => _isDraggingVibe = false);
                    },
                    child: _buildDraggableVibeWidget(),
                  ),
                ),
              ),

            // 6) Photo Remove Badge
            if (_selectedImagePath != null)
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedImagePath = null),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const VitheyIcon(
                      LucideIcons.trash2,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // 7) Aesthetic Hint if Canvas is Empty
            if (_textController.text.isEmpty &&
                _selectedImagePath == null &&
                _selectedVibeData == null &&
                !_focusNode.hasFocus)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.sparkles,
                            color: Color(0xFF38BDF8), size: 13),
                        const SizedBox(width: 6),
                        Text(
                          'Tap to write · Drag anywhere',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
  }

  // -------------------------------------------------------------
  // Draggable Vibe Badge Renderers
  // -------------------------------------------------------------
  Widget _buildDraggableVibeWidget() {
    if (_selectedVibeType == 'music') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isDraggingVibe
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
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
                    child:
                        Icon(Icons.music_note, color: Colors.white, size: 15),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    _selectedVibeData!,
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
                const _StudioSoundWaveBars(),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _clearVibeWidget,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_selectedVibeType == 'poll') {
      final parts = _selectedVibeData!.split('?');
      final question =
          parts.isNotEmpty ? '${parts.first.trim()}?' : _selectedVibeData!;
      final optionsPart = parts.length > 1 ? parts[1].trim() : 'Yes / No';
      final options = optionsPart.split('/').map((s) => s.trim()).toList();
      final opt1 = options.isNotEmpty ? options[0] : 'Yes';
      final opt2 = options.length > 1 ? options[1] : 'No';

      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDraggingVibe
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearVibeWidget,
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            opt1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            opt2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
    } else if (_selectedVibeType == 'stamp') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDraggingVibe
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on,
                    color: Color(0xFF38BDF8), size: 14),
                const SizedBox(width: 5),
                Text(
                  _selectedVibeData!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _clearVibeWidget,
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default Status Tag
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDraggingVibe
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedVibeData!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _clearVibeWidget,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Floating Tool Dock & Drawers
  // -------------------------------------------------------------
  Widget _buildActiveDrawer(String activeStyle) {
    Widget content;
    switch (_activeDrawer) {
      case 1:
        // Typography Drawer
        content = _buildTypographyDrawer(activeStyle);
        break;
      case 2:
        // Aura Mood Drawer
        content = _buildAuraMoodDrawer();
        break;
      case 3:
        // Gen-Z Vibe Badges Drawer
        content = _buildVibesDrawer();
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13131A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildTypographyDrawer(String activeStyle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'TYPOGRAPHY',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            // Align Toggle
            GestureDetector(
              onTap: _cycleTextAlignment,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _textAlignment == 'left'
                          ? LucideIcons.alignLeft
                          : (_textAlignment == 'right'
                              ? LucideIcons.alignRight
                              : LucideIcons.alignCenter),
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _textAlignment.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Highlight Toggle
            GestureDetector(
              onTap: _toggleHighlight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _hasHighlight
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.highlighter,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      _hasHighlight ? 'BADGE ON' : 'BADGE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _fontStyles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedStyleIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedStyleIndex = index);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _fontLabels[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuraMoodDrawer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AURA MOOD',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _auraGradients.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final isSelected = _selectedGradientIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedGradientIndex = index;
                    _selectedImagePath = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: _auraGradients[index]),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _auraGradients[index]
                                  .first
                                  .withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child:
                              Icon(Icons.check, size: 16, color: Colors.white),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVibesDrawer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAMPUS VIBES & STICKERS',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),

        // 1) Music Vibes Row
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _musicVibes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final track = _musicVibes[index];
              final isSelected =
                  _selectedVibeType == 'music' && _selectedVibeData == track;
              return GestureDetector(
                onTap: () => _selectMusicVibe(track),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0284C7)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? Colors.cyanAccent
                          : Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        track,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // 2) Campus Polls & Status Row
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Timestamp stamp button
              GestureDetector(
                onTap: _selectStampVibe,
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _selectedVibeType == 'stamp'
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedVibeType == 'stamp'
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '📍 Campus Stamp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Polls
              ..._campusPolls.map((poll) {
                final isSelected =
                    _selectedVibeType == 'poll' && _selectedVibeData == poll;
                return GestureDetector(
                  onTap: () => _selectPollVibe(poll),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bar_chart_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          poll,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Campus Status Tags
              ..._statusTags.map((tag) {
                final isSelected =
                    _selectedVibeType == 'status' && _selectedVibeData == tag;
                return GestureDetector(
                  onTap: () => _selectStatusTag(tag),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // Floating Tool Dock & Bottom Bar
  // -------------------------------------------------------------
  Widget _buildFloatingToolDock(CurrentUserService? currentUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: Row(
        children: [
          // Glass Tool Island
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) Typography Tool
                _DockIconButton(
                  icon: LucideIcons.type,
                  isActive: _activeDrawer == 1,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _activeDrawer = _activeDrawer == 1 ? 0 : 1;
                    });
                  },
                  tooltip: 'Text Style',
                ),
                // 2) Aura Mood Tool
                _DockIconButton(
                  icon: LucideIcons.palette,
                  isActive: _activeDrawer == 2,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _activeDrawer = _activeDrawer == 2 ? 0 : 2;
                    });
                  },
                  tooltip: 'Aura Palette',
                ),
                // 3) Vibes & Stickers Tool
                _DockIconButton(
                  icon: LucideIcons.sparkles,
                  isActive: _activeDrawer == 3,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _activeDrawer = _activeDrawer == 3 ? 0 : 3;
                    });
                  },
                  tooltip: 'Vibes & Polls',
                ),
                // 4) Vignette Lens Toggle
                _DockIconButton(
                  icon: LucideIcons.aperture,
                  isActive: _hasVignette,
                  onTap: _toggleVignette,
                  tooltip: 'Lens Vignette',
                ),
                // 5) Photo Picker (Gallery)
                _DockIconButton(
                  icon: LucideIcons.image,
                  isActive: _selectedImagePath != null,
                  onTap: () => _pickImage(ImageSource.gallery),
                  tooltip: 'Gallery',
                ),
                // 6) Camera Snapshot
                _DockIconButton(
                  icon: LucideIcons.camera,
                  isActive: false,
                  onTap: () => _pickImage(ImageSource.camera),
                  tooltip: 'Camera',
                ),
              ],
            ),
          ),
          const Spacer(),

          // Share Story Floating CTA
          GestureDetector(
            onTap: _isSharing ? null : _shareStory,
            child: Container(
              height: 46,
              padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentUser?.avatarUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: UserAvatar(
                        imageUrl: currentUser?.avatarUrl,
                        name: currentUser?.displayName ?? 'You',
                        radius: 13,
                      ),
                    ),
                  _isSharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.arrowRight,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Keyboard Quick Bar
  // -------------------------------------------------------------
  Widget _buildKeyboardQuickBar(String activeStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: const Color(0xFF13131A),
      child: Row(
        children: [
          // Cycle font
          GestureDetector(
            onTap: _cycleFontStyle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _fontLabels[_selectedStyleIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Align
          GestureDetector(
            onTap: _cycleTextAlignment,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _textAlignment == 'left'
                    ? LucideIcons.alignLeft
                    : (_textAlignment == 'right'
                        ? LucideIcons.alignRight
                        : LucideIcons.alignCenter),
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Highlight
          GestureDetector(
            onTap: _toggleHighlight,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _hasHighlight
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.highlighter,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          // Done
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Helpers & Text Styles
  // -------------------------------------------------------------
  Widget _buildAmbientAuraHalo(List<Color> gradient) {
    return Positioned.fill(
      child: Center(
        child: Container(
          width: 280,
          height: 480,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(120),
            gradient: RadialGradient(
              colors: [
                gradient.first.withValues(alpha: 0.35),
                gradient.last.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextAlign _resolveTextAlign() {
    switch (_textAlignment) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
      default:
        return TextAlign.center;
    }
  }

  TextStyle _resolveCanvasTextStyle(String style) {
    switch (style) {
      case 'neon':
        return const TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          shadows: [
            Shadow(color: Color(0xFF06B6D4), blurRadius: 28),
            Shadow(color: Color(0xFF3B82F6), blurRadius: 14),
          ],
        );
      case 'bold':
        return const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          shadows: [
            Shadow(
                color: Colors.black87, blurRadius: 16, offset: Offset(0, 3)),
          ],
        );
      case 'typewriter':
        return const TextStyle(
          fontFamily: 'monospace',
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 10),
          ],
        );
      case 'serif':
        return const TextStyle(
          fontFamily: 'Georgia',
          color: Colors.white,
          fontSize: 26,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 10),
          ],
        );
      case 'modern':
      default:
        return const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w800,
          height: 1.35,
          shadows: [
            Shadow(
                color: Colors.black87, blurRadius: 16, offset: Offset(0, 2)),
          ],
        );
    }
  }
}

// -----------------------------------------------------------------
// Subwidgets & Buttons
// -----------------------------------------------------------------
class _FrostedGlassButton extends StatelessWidget {
  const _FrostedGlassButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Center(
          child: VitheyIcon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

class _DockIconButton extends StatelessWidget {
  const _DockIconButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: VitheyIcon(
            icon,
            size: 17,
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

class _StudioSoundWaveBars extends StatefulWidget {
  const _StudioSoundWaveBars();

  @override
  State<_StudioSoundWaveBars> createState() => _StudioSoundWaveBarsState();
}

class _StudioSoundWaveBarsState extends State<_StudioSoundWaveBars>
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
            _bar(5 + 7 * (math.sin(t * math.pi))),
            const SizedBox(width: 2),
            _bar(12 - 5 * (math.cos(t * math.pi))),
            const SizedBox(width: 2),
            _bar(4 + 8 * (math.sin(t * math.pi * 1.4).abs())),
            const SizedBox(width: 2),
            _bar(10 + 4 * (math.cos(t * math.pi * 0.9).abs())),
          ],
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 2.5,
      height: height.clamp(3.0, 14.0),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
