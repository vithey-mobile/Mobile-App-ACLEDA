class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.location,
    this.phone,
    this.isOnline = false,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? phone;
  final bool isOnline;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
    );
  }
}
