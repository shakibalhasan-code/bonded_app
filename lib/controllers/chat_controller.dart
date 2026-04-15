import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bond_user_model.dart';

class ChatMessage {
  final String text;
  final String senderName;
  final String senderImage;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.senderName,
    required this.senderImage,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  void initChat(BondUserModel user) {
    // Mock initial messages based on Screenshot 2
    messages.assignAll([
      ChatMessage(
        text: "How’s the shot for later marina?",
        senderName: user.name,
        senderImage: user.image,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
      ChatMessage(
        text: "This new exploration for shot, What do you think?",
        senderName: "You",
        senderImage: "https://i.pravatar.cc/150?u=me",
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isMe: true,
      ),
      ChatMessage(
        text: "How’s the shot for later marina?",
        senderName: user.name,
        senderImage: user.image,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
      ),
      ChatMessage(
        text: "This new exploration for shot, What do you think?",
        senderName: "You",
        senderImage: "https://i.pravatar.cc/150?u=me",
        timestamp: DateTime.now(),
        isMe: true,
      ),
    ]);
  }

  void sendMessage(String text, BondUserModel user) {
    if (text.trim().isEmpty) return;

    messages.add(ChatMessage(
      text: text,
      senderName: "You",
      senderImage: "https://i.pravatar.cc/150?u=me",
      timestamp: DateTime.now(),
      isMe: true,
    ));

    messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
