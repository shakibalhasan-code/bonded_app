import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/conversation_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../core/constants/app_endpoints.dart';
import '../controllers/auth_controller.dart';
import '../services/shared_prefs_service.dart';

class MessagesController extends GetxController {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = Get.find<SocketService>();
  final conversations = <ConversationModel>[].obs;
  final RxBool isLoading = false.obs;
  
  // Search State
  final searchQuery = "".obs;
  late final TextEditingController searchController;

  List<ConversationModel> get filteredConversations {
    if (searchQuery.value.isEmpty) return conversations;
    return conversations
        .where((c) =>
            (c.user.fullName?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
            c.lastMessage.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    fetchConversations();
    _setupSocketListeners();
  }

  Function(dynamic)? _receiveMessageHandler;

  void _setupSocketListeners() {
    _receiveMessageHandler = (data) {
      debugPrint('MESSAGES_DEBUG: conversation:message:new received, updating conversation list');
      try {
        // Payload: { conversation: { _id, lastMessage, lastMessageAt, unreadCount, counterpart, ... }, message: {...} }
        final convJson = data is Map ? data['conversation'] as Map<String, dynamic>? : null;
        if (convJson == null) {
          fetchConversations(showLoading: false);
          return;
        }

        final currentUserId = _getCurrentUserId();
        
        // Fix: Socket payload sometimes lists the receiver (current user) as the counterpart.
        // We must ensure the counterpart is the *other* person.
        if (convJson['counterpart'] != null && 
            (convJson['counterpart']['_id'] == currentUserId || convJson['counterpart']['id'] == currentUserId)) {
          final msgJson = data['message'];
          if (msgJson != null && msgJson['sender'] != null) {
            convJson['counterpart'] = msgJson['sender'];
          }
        }

        ConversationModel updatedConv = ConversationModel.fromJson(convJson);

        // Find existing conversation and update it
        final idx = conversations.indexWhere((c) => c.id == updatedConv.id);
        if (idx != -1) {
          // Keep the existing counterpart to be 100% safe if it was already correct
          final existingConv = conversations[idx];
          if (updatedConv.user.id == currentUserId || updatedConv.user.id.isEmpty) {
             updatedConv = ConversationModel(
               id: updatedConv.id,
               user: existingConv.user,
               lastMessage: updatedConv.lastMessage,
               lastMessageType: updatedConv.lastMessageType,
               lastMessageAt: updatedConv.lastMessageAt,
               kind: updatedConv.kind,
               unreadCount: updatedConv.unreadCount,
             );
          }
          conversations.removeAt(idx);
        }
        // Insert at top (most recent)
        conversations.insert(0, updatedConv);
      } catch (e) {
        log('MessagesController: Error updating conversation from socket: $e');
        fetchConversations(showLoading: false);
      }
    };

    // Listen to the correct real-time event from the server
    _socketService.on('conversation:message:new', _receiveMessageHandler!);
  }

  @override
  void onClose() {
    if (_receiveMessageHandler != null) {
      _socketService.off('conversation:message:new', _receiveMessageHandler!);
    }
    // Intentionally NOT disposing searchController here to prevent 
    // "TextEditingController was used after being disposed" crashes during GetX route pops.
    super.onClose();
  }

  Future<void> fetchConversations({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    try {
      final response = await _apiService.get(AppUrls.conversations);
      final data = jsonDecode(response.body);
      
      log('MessagesController: Conversations fetched: ${response.body}');
      
      if (data['success'] == true) {
        final List list = data['data'] ?? [];
        conversations.assignAll(list.map((c) => ConversationModel.fromJson(c)).toList());
      } else {
        if (showLoading) Get.snackbar('Error', data['message'] ?? 'Failed to fetch conversations');
      }
    } catch (e) {
      log('MessagesController Error: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  String _getCurrentUserId() {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        final id = authController.currentUser.value?.id ?? 
                   authController.userData['_id']?.toString() ?? '';
        if (id.isNotEmpty) return id;
      }
    } catch (_) {}
    return SharedPrefsService.getString('userId') ?? '';
  }
}
