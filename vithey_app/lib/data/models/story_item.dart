import 'package:flutter/material.dart';

/// Single story slide item for an author.
class StoryItem {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? mediaUrl; // Can be asset, network url, or local file path
  final List<Color>? gradientColors; // For text/gradient stories
  final String? text;
  final String? fontStyle; // 'modern', 'neon', 'bold', 'typewriter', 'serif'
  final String? sticker; // E.g. '✨ Good Vibes', '☕ Coffee Run'
  final String? vibeType; // 'music', 'status', 'poll', 'stamp'
  final String? vibeData; // Detailed payload (song title, poll choices, etc.)
  final String textAlignment; // 'left', 'center', 'right'
  final bool hasVignette;
  final double textDx;
  final double textDy;
  final double stickerDx;
  final double stickerDy;
  final DateTime createdAt;
  final bool isSeen;

  const StoryItem({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.mediaUrl,
    this.gradientColors,
    this.text,
    this.fontStyle,
    this.sticker,
    this.vibeType,
    this.vibeData,
    this.textAlignment = 'center',
    this.hasVignette = false,
    this.textDx = 0.0,
    this.textDy = 0.0,
    this.stickerDx = 0.0,
    this.stickerDy = 0.0,
    required this.createdAt,
    this.isSeen = false,
  });

  bool get isMediaImage => mediaUrl != null && mediaUrl!.isNotEmpty;
  bool get isGradient => gradientColors != null && gradientColors!.isNotEmpty;

  StoryItem copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? mediaUrl,
    List<Color>? gradientColors,
    String? text,
    String? fontStyle,
    String? sticker,
    String? vibeType,
    String? vibeData,
    String? textAlignment,
    bool? hasVignette,
    double? textDx,
    double? textDy,
    double? stickerDx,
    double? stickerDy,
    DateTime? createdAt,
    bool? isSeen,
  }) {
    return StoryItem(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      gradientColors: gradientColors ?? this.gradientColors,
      text: text ?? this.text,
      fontStyle: fontStyle ?? this.fontStyle,
      sticker: sticker ?? this.sticker,
      vibeType: vibeType ?? this.vibeType,
      vibeData: vibeData ?? this.vibeData,
      textAlignment: textAlignment ?? this.textAlignment,
      hasVignette: hasVignette ?? this.hasVignette,
      textDx: textDx ?? this.textDx,
      textDy: textDy ?? this.textDy,
      stickerDx: stickerDx ?? this.stickerDx,
      stickerDy: stickerDy ?? this.stickerDy,
      createdAt: createdAt ?? this.createdAt,
      isSeen: isSeen ?? this.isSeen,
    );
  }
}

/// A cluster of stories belonging to a single author.
class UserStoryGroup {
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final List<StoryItem> stories;
  final bool isOwn;

  const UserStoryGroup({
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.stories,
    this.isOwn = false,
  });

  bool get hasUnseen => stories.any((s) => !s.isSeen);
}
