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
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

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
  final String? fileName;
  final String? localFilePath;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    required this.senderImage,
    required this.timestamp,
    required this.isMe,
    this.type,
    this.mediaUrl,
    this.fileName,
    this.localFilePath,
  });

  ChatMessage copyWith({String? localFilePath, String? fileName}) {
    return ChatMessage(
      id: id,
      text: text,
      senderName: senderName,
      senderImage: senderImage,
      timestamp: timestamp,
      isMe: isMe,
      type: type,
      mediaUrl: mediaUrl,
      fileName: fileName ?? this.fileName,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderData = json['sender'];

    // Extract sender ID — supports both REST format (flat senderId string)
    // and socket receive-message format (nested sender object with _id).
    String? senderId;
    if (json['senderId'] != null) {
      // REST API: messages list uses flat senderId string
      senderId = json['senderId'].toString();
    } else if (senderData != null) {
      if (senderData is Map) {
        // Socket receive-message: sender is an object { _id, fullName, ... }
        senderId = (senderData['_id'] ?? senderData['id'])?.toString();
      } else {
        senderId = senderData.toString();
      }
    }

    // Determine ownership: prefer ID comparison, fall back to backend flag
    bool isOwn = false;
    if (senderId != null && currentUserId.isNotEmpty) {
      isOwn = senderId.trim() == currentUserId.trim();
    } else {
      isOwn = json['isOwnMessage'] == true;
    }

    debugPrint('CHAT_DEBUG: isMe=$isOwn | senderId=$senderId | myId=$currentUserId');

    // Resolve sender display info
    String senderName = 'Unknown';
    String senderImage = '';

    if (senderData is Map) {
      senderName = senderData['fullName'] ?? senderData['username'] ?? 'Unknown';
      final avatar = senderData['avatar'];
      senderImage = (avatar != null && avatar.toString().isNotEmpty)
          ? AppUrls.imageUrl(avatar)
          : '';
    } else {
      senderName = isOwn ? 'You' : 'User';
    }

    // Resolve media: backend may return flat `mediaUrl` (legacy) OR a `media`
    // array of `{url, type, fileName}` objects (newer/multi-attachment shape).
    String? mediaUrl = json['mediaUrl']?.toString();
    String? fileName = json['fileName']?.toString();
    String? resolvedType = json['type']?.toString();
    if (mediaUrl == null) {
      final mediaList = json['media'];
      if (mediaList is List && mediaList.isNotEmpty) {
        final first = mediaList.first;
        if (first is Map) {
          mediaUrl = first['url']?.toString();
          fileName ??= first['fileName']?.toString() ??
              first['name']?.toString();
          resolvedType ??= first['type']?.toString();
        }
      }
    }
    if (mediaUrl != null && fileName == null && resolvedType == 'file') {
      final segs = Uri.tryParse(mediaUrl)?.pathSegments ?? const [];
      fileName = segs.isNotEmpty ? segs.last : null;
    }

    return ChatMessage(
      id: json['_id']?.toString() ?? '',
      text: json['content']?.toString() ?? '',
      senderName: senderName,
      senderImage: senderImage,
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      isMe: isOwn,
      type: resolvedType,
      mediaUrl: mediaUrl,
      fileName: fileName,
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
    // Always get the freshest user ID
    currentUserId = _getCurrentUserId();

    isLoading.value = true;
    messages.clear();
    conversationId = null;
    _isSocketListenersSetup = false;

    try {
      // Step 1: Get or create the direct conversation
      final response = await _apiService.post('${AppUrls.directChat}/${user.id}', {});
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        conversationId = data['data']['_id'];
        log('ChatController: Conversation ID: $conversationId');

        // Step 2: Load message history from REST endpoint for reliability
        await _loadMessageHistory();

        // Step 3: Join socket room & set up real-time listeners
        _joinConversationSocket();
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

  /// Load message history via the REST API endpoint.
  Future<void> _loadMessageHistory() async {
    if (conversationId == null) return;
    try {
      final response = await _apiService.get(
        AppUrls.conversationMessages(conversationId!),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List history = data['data']['messages'] ?? [];
        final uid = _getCurrentUserId();
        messages.assignAll(
          history.map((m) => ChatMessage.fromJson(m, uid)).toList(),
        );
        _scrollToBottom();
      }
    } catch (e) {
      log('ChatController: Failed to load message history: $e');
    }
  }

  /// Notify the server we've joined this conversation room.
  void _joinConversationSocket() {
    if (conversationId == null) return;
    _socketService.emit('conversation:join', {
      'conversationId': conversationId,
      'limit': 50
    }, ack: (response) {
      debugPrint('SOCKET_DEBUG: conversation:join ACK response:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(response));
    });
    debugPrint('SOCKET_DEBUG: Joined conversation room: $conversationId');
  }

  Function(dynamic)? _receiveMessageHandler;
  Function(dynamic)? _typingHandler;

  bool _isSocketListenersSetup = false;
  void _setupSocketListeners() {
    if (_isSocketListenersSetup) return;
    _isSocketListenersSetup = true;

    _receiveMessageHandler = (data) {
      debugPrint('SOCKET_DEBUG: conversation:message:new event received');
      debugPrint(const JsonEncoder.withIndent('  ').convert(data));

      // Payload: { conversation: {...}, message: { _id, chat, content, type, createdAt, sender: {...} } }
      final messageJson = data is Map ? (data['message'] as Map<String, dynamic>?) : null;
      if (messageJson == null) return;

      // Only process if this message belongs to our current conversation
      final chatId = messageJson['chat']?.toString();
      if (chatId != null && chatId != conversationId) return;

      final uid = _getCurrentUserId();
      final newMessage = ChatMessage.fromJson(messageJson, uid);

      // Deduplicate: check if already added (by real id or matching temp)
      final existingIndex = messages.indexWhere(
        (m) =>
            m.id == newMessage.id ||
            (m.id.startsWith('temp_') &&
                m.text == newMessage.text &&
                m.isMe),
      );

      if (existingIndex == -1) {
        messages.add(newMessage);
        _scrollToBottom();
      } else if (messages[existingIndex].id.startsWith('temp_')) {
        // Promote temporary optimistic message to confirmed server message
        messages[existingIndex] = newMessage;
        messages.refresh();
      }
    };

    // Server broadcasts new messages via 'conversation:message:new'
    _socketService.on('conversation:message:new', _receiveMessageHandler!);

    // Typing indicators
    _typingHandler = (data) {
      final senderUserId = data['userId']?.toString() ?? data['senderId']?.toString();
      if (data['conversationId'] == conversationId &&
          senderUserId != _getCurrentUserId()) {
        isOtherUserTyping.value = data['isTyping'] ?? false;
      }
    };
    _socketService.on('conversation:typing', _typingHandler!);
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
    debugPrint('CHAT_DEBUG: Stored userId from Prefs: $storedId');
    if (storedId != null && storedId.isNotEmpty) {
      currentUserId = storedId;
      return storedId;
    }

    return '';
  }

  void sendMessage(String text, UserModel user) {
    if (text.trim().isEmpty || conversationId == null) return;

    final String messageText = text.trim();
    final currentUserId = _getCurrentUserId();
    
    // Optimistic Update: Add message to list immediately
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = ChatMessage(
      id: tempId,
      text: messageText,
      senderName: 'You',
      senderImage: '', // Will be handled by ChatMessage logic or ignored for Me
      timestamp: DateTime.now(),
      isMe: true,
      type: 'text',
    );
    
    messages.add(optimisticMessage);
    _scrollToBottom();
    messageController.clear();
    sendTypingStatus(false);

    final payload = {
      'conversationId': conversationId,
      'content': messageText,
      'type': 'text'
    };

    _socketService.emit('message:send', payload, ack: (response) {
      debugPrint('SOCKET_DEBUG: message:send ACK response:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(response));

      if (response != null && response['success'] == true) {
        final msgData = response['data']?['message'] ?? response['data'];
        if (msgData != null) {
          final sentMessage = ChatMessage.fromJson(
            Map<String, dynamic>.from(msgData),
            currentUserId,
          );
          final index = messages.indexWhere((m) => m.id == tempId);
          if (index != -1) {
            messages[index] = sentMessage;
            messages.refresh();
          } else if (!messages.any((m) => m.id == sentMessage.id)) {
            messages.add(sentMessage);
            _scrollToBottom();
          }
        }
        // If the server will also broadcast a receive-message event,
        // the deduplication in _setupSocketListeners handles it.
      } else {
        // ACK failure — remove the optimistic message
        messages.removeWhere((m) => m.id == tempId);
        Get.snackbar('Error', response?['message'] ?? 'Failed to send message');
      }
    });
  }

  void sendTypingStatus(bool isTyping) {
    if (conversationId == null) return;
    final event = isTyping ? 'conversation:typing:start' : 'conversation:typing:stop';
    _socketService.emit(event, {'conversationId': conversationId});
  }

  Future<void> pickAndSendMedia(ImageSource source, {bool isVideo = false}) async {
    if (conversationId == null) return;

    final XFile? picked = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);
    if (picked == null) return;

    await _uploadAttachment(
      filePath: picked.path,
      type: isVideo ? 'video' : 'image',
    );
  }

  Future<void> pickAndSendFile() async {
    if (conversationId == null) return;

    final FilePickerResult? result = await FilePicker.pickFiles();
    if (result == null || result.files.single.path == null) return;

    await _uploadAttachment(
      filePath: result.files.single.path!,
      type: 'file',
      fileName: result.files.single.name,
    );
  }

  /// Uploads an attachment via multipart POST.
  /// `type` decides the field name (`image` / `video` / `file`) and the
  /// `type` value sent in the JSON `data` blob.
  Future<void> _uploadAttachment({
    required String filePath,
    required String type,
    String? fileName,
  }) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final currentUserId = _getCurrentUserId();

    String placeholder;
    switch (type) {
      case 'video':
        placeholder = '[Video]';
        break;
      case 'file':
        placeholder = '[File]';
        break;
      default:
        placeholder = '[Image]';
    }

    final tempMessage = ChatMessage(
      id: tempId,
      text: placeholder,
      senderName: '',
      senderImage: '',
      timestamp: DateTime.now(),
      isMe: true,
      type: type,
      localFilePath: filePath,
      fileName: fileName,
    );
    messages.add(tempMessage);
    _scrollToBottom();

    try {
      final fallbackMime = type == 'video'
          ? 'video/mp4'
          : type == 'file'
              ? 'application/octet-stream'
              : 'image/jpeg';
      final mimeType = lookupMimeType(filePath) ?? fallbackMime;
      final mimeParts = mimeType.split('/');

      final multipartFile = await http.MultipartFile.fromPath(
        type, // 'image' | 'video' | 'file' — matches backend multer field
        filePath,
        contentType: MediaType(mimeParts.first, mimeParts.last),
        filename: fileName,
      );

      final response = await _apiService.multipartRequest(
        'POST',
        AppUrls.conversationMessages(conversationId!),
        files: [multipartFile],
        fields: {
          'data': jsonEncode({
            'content': placeholder,
            'type': type,
          }),
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final msgJson = data['data']?['message'] ?? data['data'];
        if (msgJson is Map) {
          final newMessage = ChatMessage.fromJson(
            Map<String, dynamic>.from(msgJson),
            currentUserId,
          )
              // Keep the local preview so the bubble stays rendered even if
              // the backend hasn't populated mediaUrl on this response yet.
              .copyWith(localFilePath: filePath, fileName: fileName);

          final index = messages.indexWhere((m) => m.id == tempId);
          if (index != -1) {
            messages[index] = newMessage;
            messages.refresh();
          } else if (!messages.any((m) => m.id == newMessage.id)) {
            messages.add(newMessage);
            _scrollToBottom();
          }
        }
      } else {
        messages.removeWhere((m) => m.id == tempId);
        Get.snackbar('Error', data['message'] ?? 'Failed to upload $type');
      }
    } catch (e) {
      log('ChatController upload error ($type): $e');
      messages.removeWhere((m) => m.id == tempId);
      Get.snackbar('Error', 'Failed to upload $type');
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
    }
    if (_receiveMessageHandler != null) {
      _socketService.off('conversation:message:new', _receiveMessageHandler!);
    }
    if (_typingHandler != null) {
      _socketService.off('conversation:typing', _typingHandler!);
    }
    // Intentionally NOT disposing controllers to prevent Flutter framework crashes during GetX route pops
    super.onClose();
  }
}
