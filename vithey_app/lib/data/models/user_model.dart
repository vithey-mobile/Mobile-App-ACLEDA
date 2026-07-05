class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
    );
  }
}
