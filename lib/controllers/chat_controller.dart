import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../services/shared_prefs_service.dart';
import '../core/constants/app_endpoints.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:io';

import '../controllers/auth_controller.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderName;
  final String senderImage;
  final DateTime timestamp;
  final bool isMe;
  final String? type;
  final String? mediaUrl;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    required this.senderImage,
    required this.timestamp,
    required this.isMe,
    this.type,
    this.mediaUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderData = json['sender'];
    
    // Extract sender ID from all possible locations in the JSON
    String? senderId;
    if (json['senderId'] != null) {
      senderId = json['senderId'].toString();
    } else if (json['sender_id'] != null) {
      senderId = json['sender_id'].toString();
    } else if (senderData != null) {
      if (senderData is Map) {
        senderId = (senderData['_id'] ?? senderData['id'])?.toString();
      } else {
        senderId = senderData.toString();
      }
    }
    
    // STRICT ID MATCHING:
    // We prioritize our local comparison for reliability across broadcast events.
    bool isOwn = false;
    if (senderId != null && currentUserId.isNotEmpty) {
      isOwn = senderId.trim() == currentUserId.trim();
    } else {
      // Fallback to backend flag if ID comparison isn't possible
      isOwn = json['isOwnMessage'] ?? false;
    }
    
    debugPrint('SOCKET_DEBUG: PARSING MESSAGE -> Sender: $senderId, Me: $currentUserId, Result: ${isOwn ? "MINE" : "THEIRS"}');

    String senderName = 'Unknown';
    String senderImage = 'https://i.pravatar.cc/150';

    if (senderData is Map) {
      senderName = senderData['fullName'] ?? senderData['username'] ?? 'Unknown';
      senderImage = AppUrls.imageUrl(senderData['avatar']);
    } else {
      senderName = isOwn ? 'You' : 'User';
    }
    
    return ChatMessage(
      id: json['_id'] ?? '',
      text: json['content'] ?? '',
      senderName: senderName,
      senderImage: senderImage,
      timestamp: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isMe: isOwn,
      type: json['type'],
      mediaUrl: json['mediaUrl'],
    );
  }
}

class ChatController extends GetxController {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = Get.find<SocketService>();
  final ImagePicker _picker = ImagePicker();
  
  final messages = <ChatMessage>[].obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool isOtherUserTyping = false.obs;
  
  String? conversationId;
  String? currentUserId;

  @override
  void onInit() {
    super.onInit();
    // Synchronously load user ID from storage
    currentUserId = SharedPrefsService.getString('userId');
    debugPrint('SOCKET_DEBUG: ChatController initialized with MyId: $currentUserId');
    
    // Fallback: Ensure we have the user profile
    final authController = Get.find<AuthController>();
    if (authController.currentUser.value == null) {
      authController.fetchUserProfile();
    }
  }

  Future<void> initChat(UserModel user) async {
    isLoading.value = true;
    messages.clear(); // Clear old messages
    
    try {
      final response = await _apiService.post('${AppUrls.directChat}/${user.id}', {});
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        conversationId = data['data']['_id'];
        log('ChatController: Conversation ID: $conversationId');
        
        _joinConversation();
        _setupSocketListeners();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to start chat');
      }
    } catch (e) {
      log('ChatController Error: $e');
      Get.snackbar('Error', 'Connection failed');
    } finally {
      isLoading.value = false;
    }
  }

  void _joinConversation() {
    if (conversationId == null) return;
    
    _socketService.emit('conversation:join', {
      'conversationId': conversationId,
      'limit': 50
    }, ack: (response) {
      debugPrint('SOCKET_DEBUG: conversation:join ACK response:');
      if (response['success'] == true) {
        final List history = response['data']['messages'] ?? [];
        final currentUserId = _getCurrentUserId();
        
        messages.assignAll(history.map((m) => ChatMessage.fromJson(m, currentUserId)).toList());
        _scrollToBottom();
      }
    });
  }

  bool _isSocketListenersSetup = false;
  void _setupSocketListeners() {
    if (_isSocketListenersSetup) return;
    _isSocketListenersSetup = true;

    _socketService.on('conversation:message:new', (data) {
      debugPrint('SOCKET_DEBUG: conversation:message:new received');
      final currentUserId = _getCurrentUserId();
      final newMessage = ChatMessage.fromJson(data['message'], currentUserId);
      
      if (!messages.any((m) => m.id == newMessage.id)) {
        messages.add(newMessage);
        _scrollToBottom();
      }
    });

    _socketService.on('conversation:typing', (data) {
      if (data['conversationId'] == conversationId && data['userId'] != _getCurrentUserId()) {
        isOtherUserTyping.value = data['isTyping'] ?? false;
      }
    });
  }

  String _getCurrentUserId() {
    // 1. Try memory cache
    if (currentUserId != null && currentUserId!.isNotEmpty) {
      return currentUserId!;
    }
    
    // 2. Try AuthController (Source of Truth)
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        final id = authController.currentUser.value?.id ?? 
                   authController.userData['_id']?.toString() ?? '';
        if (id.isNotEmpty) {
          currentUserId = id;
          return id;
        }
      }
    } catch (e) {
      debugPrint('SOCKET_DEBUG: Error getting ID from AuthController: $e');
    }

    // 3. Try Persistent Storage
    final storedId = SharedPrefsService.getString('userId');
    if (storedId != null && storedId.isNotEmpty) {
      currentUserId = storedId;
      return storedId;
    }

    return '';
  }

  void sendMessage(String text, UserModel user) {
    if (text.trim().isEmpty || conversationId == null) return;

    final payload = {
      'conversationId': conversationId,
      'content': text.trim(),
      'type': 'text'
    };

    _socketService.emit('message:send', payload, ack: (response) {
      debugPrint('SOCKET_DEBUG: message:send ACK response:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(response));
      
      if (response['success'] == true) {
        final currentUserId = _getCurrentUserId();
        final sentMessage = ChatMessage.fromJson(response['data']['message'], currentUserId);
        
        if (!messages.any((m) => m.id == sentMessage.id)) {
          messages.add(sentMessage);
          _scrollToBottom();
        }
      }
    });

    messageController.clear();
    _scrollToBottom();
    sendTypingStatus(false);
  }

  void sendTypingStatus(bool isTyping) {
    if (conversationId == null) return;
    final event = isTyping ? 'conversation:typing:start' : 'conversation:typing:stop';
    _socketService.emit(event, {'conversationId': conversationId});
  }

  Future<void> pickAndSendMedia(ImageSource source, {bool isVideo = false}) async {
    if (conversationId == null) return;

    try {
      final XFile? file = isVideo 
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);
      
      if (file == null) return;

      isLoading.value = true;
      
      final filePath = file.path;
      final mimeType = lookupMimeType(filePath) ?? (isVideo ? 'video/mp4' : 'image/jpeg');
      final mimeParts = mimeType.split('/');
      
      final fileField = mimeParts.first == 'image' ? 'image' : 'media';
      
      final multipartFile = await http.MultipartFile.fromPath(
        fileField,
        filePath,
        contentType: MediaType(mimeParts.first, mimeParts.last),
      );

      final endpoint = AppUrls.conversationMessages(conversationId!);
      
      final response = await _apiService.multipartRequest(
        'POST',
        endpoint,
        files: [multipartFile],
        fields: {
          'data': jsonEncode({'content': isVideo ? '[Video]' : '[Image]'})
        }
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final currentUserId = _getCurrentUserId();
        final newMessage = ChatMessage.fromJson(data['data']['message'], currentUserId);
        
        if (!messages.any((m) => m.id == newMessage.id)) {
          messages.add(newMessage);
          _scrollToBottom();
        }
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to upload media');
      }
    } catch (e) {
      log('ChatController Media Upload Error: $e');
      Get.snackbar('Error', 'Failed to upload media');
    } finally {
      isLoading.value = false;
    }
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
    if (conversationId != null) {
      _socketService.emit('conversation:leave', {'conversationId': conversationId});
      _socketService.off('conversation:message:new');
      _socketService.off('conversation:typing');
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
