import 'user_model.dart';

class ConversationModel {
  final UserModel user;
  final String lastMessage;
  final String time;
  final int unreadCount;

  ConversationModel({
    required this.user,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}
