import 'package:intl/intl.dart';

class AppDateUtils {
  /// Parses a UTC ISO string and converts it to local time.
  static DateTime? parseToLocal(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString).toLocal();
    } catch (e) {
      return null;
    }
  }

  /// Formats a UTC ISO string to a human-readable local time string.
  /// Example: "2026-05-10T15:42:04.718Z" -> "May 10, 2026 9:42 PM"
  static String formatLocal(String? isoString, {String format = 'MMM d, yyyy h:mm a'}) {
    final localDateTime = parseToLocal(isoString);
    if (localDateTime == null) return '';
    return DateFormat(format).format(localDateTime);
  }

  /// Returns a relative time string (e.g., "2 minutes ago") in local time.
  static String timeAgo(String? isoString) {
    final localDateTime = parseToLocal(isoString);
    if (localDateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
