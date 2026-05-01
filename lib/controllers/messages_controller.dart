import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/conversation_model.dart';
import '../models/user_model.dart';

class MessagesController extends GetxController {
  final conversations = <ConversationModel>[].obs;
  
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
    _loadMockConversations();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadMockConversations() {
    final mockUsers = [
      UserModel(
        id: '101',
        authId: 'auth_101',
        email: 'francesco@gmail.com',
        fullName: 'Francesco Lamos',
        avatar: 'https://i.pravatar.cc/150?u=101',
        username: 'francesco_l',
        gender: 'Female',
        dateOfBirth: '1995-10-10',
        city: 'Rome',
        country: 'Italy',
        bio: 'Explorer and designer.',
        subscriptionTier: 'free',
        selfieVerification: 'verified',
        documentVerification: 'unverified',
        profileCompleted: true,
        isBlocked: false,
        isDeleted: false,
        averageRating: 4.5,
        reviewCount: 10,
        connectionType: ['one_on_one_friendship'],
      ),
      UserModel(
        id: '102',
        authId: 'auth_102',
        email: 'helin@gmail.com',
        fullName: 'Helin Gakstadter',
        avatar: 'https://i.pravatar.cc/150?u=102',
        username: 'helin_g',
        gender: 'Female',
        dateOfBirth: '1996-05-05',
        city: 'Berlin',
        country: 'Germany',
        bio: 'Active lifestyle enthusiast.',
        subscriptionTier: 'free',
        selfieVerification: 'verified',
        documentVerification: 'unverified',
        profileCompleted: true,
        isBlocked: false,
        isDeleted: false,
        averageRating: 4.8,
        reviewCount: 15,
        connectionType: ['one_on_one_friendship'],
      ),
      UserModel(
        id: '103',
        authId: 'auth_103',
        email: 'mick@gmail.com',
        fullName: 'Mick Behr Sr.',
        avatar: 'https://i.pravatar.cc/150?u=103',
        username: 'mick_b',
        gender: 'Male',
        dateOfBirth: '1990-01-01',
        city: 'London',
        country: 'UK',
        bio: 'Bonded with the best.',
        subscriptionTier: 'free',
        selfieVerification: 'verified',
        documentVerification: 'unverified',
        profileCompleted: true,
        isBlocked: false,
        isDeleted: false,
        averageRating: 4.2,
        reviewCount: 8,
        connectionType: ['small_group_hangouts'],
      ),
    ];

    conversations.assignAll([
      ConversationModel(user: mockUsers[0], lastMessage: 'Just ideas for next time', time: '20:00 PM', unreadCount: 3),
      ConversationModel(user: mockUsers[1], lastMessage: 'Just ideas for next time', time: '20:00 PM', unreadCount: 3),
      if (mockUsers.length > 2)
        ConversationModel(user: mockUsers[2], lastMessage: 'Just ideas for next time', time: '20:00 PM'),
    ]);
  }
}
