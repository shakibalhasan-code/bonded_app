import 'package:flutter/material.dart';

enum NotificationType {
  security,
  update,
  success,
  feature,
}

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final NotificationType type;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.security:
        return Icons.security_outlined;
      case NotificationType.update:
        return Icons.error_outline;
      case NotificationType.success:
        return Icons.lock_outline;
      case NotificationType.feature:
        return Icons.star_outline;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.security:
        return const Color(0xFF7128D0);
      case NotificationType.update:
        return const Color(0xFF7128D0);
      case NotificationType.success:
        return const Color(0xFF7128D0);
      case NotificationType.feature:
        return const Color(0xFF7128D0);
    }
  }
}
