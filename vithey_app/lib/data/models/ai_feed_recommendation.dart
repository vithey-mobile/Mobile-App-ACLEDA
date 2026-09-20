/// Ranked feed recommendation (Block 2 — AI-FEED-02, AI-FEED-06).
///
/// Home feed mixes these ranked posts with fresh/explore posts to avoid
/// a filter bubble (AI-FEED-03).
class AiFeedRecommendation {
  const AiFeedRecommendation({
    required this.postId,
    required this.relevance,
    this.reason,
  });

  final String postId;

  /// Relevance 0–100 for this user.
  final int relevance;

  /// Light explanation, e.g. "Matches your Flutter & Dart skills".
  final String? reason;

  factory AiFeedRecommendation.fromJson(Map<String, dynamic> json) {
    return AiFeedRecommendation(
      postId: json['post_id']?.toString() ?? '',
      relevance: (json['relevance'] as num?)?.toInt() ?? 0,
      reason: json['reason']?.toString(),
    );
  }
}
