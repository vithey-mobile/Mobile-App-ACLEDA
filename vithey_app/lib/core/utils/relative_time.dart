import 'package:get/get.dart';

class RelativeTime {
  RelativeTime._();

  /// Relative date: `2 hours ago`, `3 days ago`, `1 month ago`, `2 years ago`.
  static String format(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.isNegative || diff.inMinutes < 1) return 'Just now'.tr;
    if (diff.inHours < 1) {
      return _plural(diff.inMinutes, 'minute');
    }
    if (diff.inHours < 24) {
      return _plural(diff.inHours, 'hour');
    }
    if (diff.inDays < 30) {
      return _plural(diff.inDays, 'days');
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor().clamp(1, 11);
      return _plural(months, 'month');
    }
    final years = (diff.inDays / 365).floor().clamp(1, 999);
    return _plural(years, 'year');
  }

  static String _plural(int value, String unitKey) {
    final isKhmer = Get.locale?.languageCode == 'km';
    if (isKhmer) {
      return '$value ${unitKey.tr}${'ago'.tr}';
    }
    final plural = value == 1 ? unitKey : '${unitKey}s';
    return '$value $plural ago';
  }

  /// Chat list trailing time — e.g. `2m ago`, `Yesterday`.
  static String formatChatList(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now'.tr;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (day == today) return '${diff.inHours}h ago';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday'.tr;
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Chat header subtitle when offline — e.g. `last seen 2 hours ago`.
  static String formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (day == today) return 'last seen today at $time';
    if (day == today.subtract(const Duration(days: 1))) {
      return 'last seen yesterday at $time';
    }
    return 'last seen ${format(dateTime)}';
  }

  /// Scheduled post date/time format — e.g. `Today at 2:30 PM`, `Tomorrow at 10:00 AM`, `Sep 25 at 12:00 PM`.
  static String formatScheduled(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDay = DateTime(local.year, local.month, local.day);

    final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    if (targetDay == today) {
      return 'Today at $timeStr';
    } else if (targetDay == tomorrow) {
      return 'Tomorrow at $timeStr';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final monthName = months[local.month - 1];
      return '$monthName ${local.day} at $timeStr';
    }
  }
}
