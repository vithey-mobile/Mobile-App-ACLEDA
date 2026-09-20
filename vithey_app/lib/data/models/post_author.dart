import 'package:aub_connect_app/core/utils/media_url_resolver.dart';

class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      avatarUrl: MediaUrlResolver.resolveUrl(json['avatar_url'] as String?),
    );
  }
}
