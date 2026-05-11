import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final NotificationSender? sender;
  final String? receiver;
  final Map<String, dynamic>? data;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.sender,
    this.receiver,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      sender: json['sender'] != null ? NotificationSender.fromJson(json['sender']) : null,
      receiver: json['receiver'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  String get timestamp {
    return DateFormat('hh:mm a').format(createdAt);
  }

  IconData get icon {
    switch (type) {
      case 'bond-request':
        return Icons.person_add_outlined;
      case 'bond-accepted':
        return Icons.person_outline;
      case 'new-message':
        return Icons.chat_bubble_outline;
      case 'security':
        return Icons.security_outlined;
      case 'update':
        return Icons.error_outline;
      default:
        return Icons.notifications_none;
    }
  }

  Color get color {
    return const Color(0xFF7128D0);
  }
}

class NotificationSender {
  final String id;
  final String? email;
  final String? avatar;
  final String? fullName;
  final String? username;

  NotificationSender({
    required this.id,
    this.email,
    this.avatar,
    this.fullName,
    this.username,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['_id'] ?? '',
      email: json['email'],
      avatar: json['avatar'],
      fullName: json['fullName'],
      username: json['username'],
    );
  }
}
