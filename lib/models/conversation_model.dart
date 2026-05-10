import 'user_model.dart';
import 'package:intl/intl.dart';

class ConversationModel {
  final String id;
  final UserModel user;
  final String lastMessage;
  final String lastMessageType;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String kind;

  ConversationModel({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageAt,
    required this.kind,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'] ?? '',
      user: UserModel.fromJson(json['counterpart'] ?? {}),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageType: json['lastMessageType'] ?? 'text',
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt']).toLocal() 
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']).toLocal() : DateTime.now()),
      kind: json['kind'] ?? 'direct',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  String get timeFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);
    
    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(lastMessageAt);
    } else if (difference.inDays < 7) {
      return DateFormat('E').format(lastMessageAt);
    } else {
      return DateFormat('dd/MM/yy').format(lastMessageAt);
    }
  }
}
