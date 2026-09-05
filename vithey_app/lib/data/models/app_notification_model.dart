enum NotificationType {
  postLike,
  postComment,
  postMention,
  postShare,
  newFollower,
  jobApplicationReceived,
  jobApplicationStatus,
  chatRequest,
  chatMessage,
  paymentDue,
  paymentOverdue,
  studentVerification,
  system,
}

enum NotificationFilter { all, unread }

class NotificationActor {
  const NotificationActor({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
}

class NotificationDestination {
  const NotificationDestination({
    this.postId,
    this.userId,
    this.conversationId,
    this.jobPostId,
    this.applicationId,
    this.paymentId,
    this.routeName,
  });

  final String? postId;
  final String? userId;
  final String? conversationId;
  final String? jobPostId;
  final String? applicationId;
  final String? paymentId;
  final String? routeName;
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actor,
    required this.destination,
    this.isRead = false,
    required this.createdAt,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationActor? actor;
  final NotificationDestination destination;
  final bool isRead;
  final DateTime createdAt;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      actor: actor,
      destination: destination,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  String get displayText => body.isNotEmpty ? body : title;
}
