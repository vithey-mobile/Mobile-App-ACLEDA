import 'package:aub_connect_app/data/models/feed_post.dart';

class ApplyCvArgs {
  const ApplyCvArgs({
    required this.jobPostId,
    this.jobPreview,
  });

  final String jobPostId;
  final FeedPost? jobPreview;

  static ApplyCvArgs from(dynamic arguments) {
    if (arguments is ApplyCvArgs) return arguments;
    if (arguments is String && arguments.isNotEmpty) {
      return ApplyCvArgs(jobPostId: arguments);
    }
    throw ArgumentError('ApplyCvArgs requires a jobPostId');
  }
}
