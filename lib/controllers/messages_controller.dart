import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/conversation_model.dart';
import '../services/api_service.dart';
import '../core/constants/app_endpoints.dart';

class MessagesController extends GetxController {
  final ApiService _apiService = ApiService();
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
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get(AppUrls.conversations);
      final data = jsonDecode(response.body);
      
      log('MessagesController: Conversations fetched: ${response.body}');
      
      if (data['success'] == true) {
        final List list = data['data'] ?? [];
        conversations.assignAll(list.map((c) => ConversationModel.fromJson(c)).toList());
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to fetch conversations');
      }
    } catch (e) {
      log('MessagesController Error: $e');
      // Get.snackbar('Error', 'Failed to load conversations');
    } finally {
      isLoading.value = false;
    }
  }
}
