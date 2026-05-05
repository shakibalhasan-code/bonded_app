import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/conversation_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../core/constants/app_endpoints.dart';

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

  void _setupSocketListeners() {
    _socketService.on('conversation:message:new', (data) {
      debugPrint('MESSAGES_DEBUG: New message received in list');
      // Re-fetch or update local state
      // For simplicity and to ensure correct sorting/unread counts, we re-fetch
      // but we could also manually update the specific conversation in the list.
      fetchConversations(showLoading: false);
    });
  }

  @override
  void onClose() {
    _socketService.off('conversation:message:new');
    searchController.dispose();
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
}
