class ApiEndpoints {
  ApiEndpoints._();

  static const authRegister = '/auth/register';
  static const authLogin = '/auth/login';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
  static const authChangePassword = '/auth/me/password';
  static const usersMeSettings = '/users/me/settings';
  static const usersMe = '/users/me';
  static String userById(String id) => '/users/$id';
  static String userPosts(String id) => '/users/$id/posts';
  static const posts = '/posts';
  static String postById(String id) => '/posts/$id';
  static String postComments(String id) => '/posts/$id/comments';
  static String postReactions(String id) => '/posts/$id/reactions';
  static String userFollow(String id) => '/users/$id/follow';
  static const filesUpload = '/files/upload';
  static const fees = '/fees';
  static const payments = '/payments';
  static const studentsVerify = '/students/verify';
  static const conversations = '/conversations';
  static const messageRequests = '/message-requests';
  static String conversationMessages(String id) => '/conversations/$id/messages';
  static String conversationAccept(String id) => '/conversations/$id/accept';
  static String conversationDecline(String id) => '/conversations/$id/decline';
  static String conversationBlock(String id) => '/conversations/$id/block';
  static String messageRead(String id) => '/messages/$id/read';
  static String userReport(String userId) => '/users/$userId/report';
  static const aiChat = '/ai/chat';
  static const aiSessions = '/ai/sessions';
  static String aiSessionById(String id) => '/ai/sessions/$id';
  static String aiSessionMessages(String id) => '/ai/sessions/$id/messages';
  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static String notificationById(String id) => '/notifications/$id';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const usersMeCv = '/users/me/cv';
  static String jobApplications({String? jobPostId}) =>
      jobPostId == null ? '/job-applications' : '/job-applications?job_post_id=$jobPostId';
  static String jobApplicationStatus(String id) => '/job-applications/$id/status';
}
