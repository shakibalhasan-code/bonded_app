import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/conversation_model.dart';
import '../models/bond_user_model.dart';

class MessagesController extends GetxController {
  final conversations = <ConversationModel>[].obs;
  
  // Search State
  final searchQuery = "".obs;
  late final TextEditingController searchController;

  List<ConversationModel> get filteredConversations {
    if (searchQuery.value.isEmpty) return conversations;
    return conversations
        .where((c) =>
            c.user.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
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
    final interests = {
      'Social': ['Coffee', 'Dining'],
    };

    final mockUsers = [
      BondUserModel(
        id: '101',
        name: 'Francesco Lamos',
        email: 'francesco@gmail.com',
        image: 'https://i.pravatar.cc/150?u=101',
        username: 'francesco_l',
        gender: 'Female', // As per image
        birthDate: '10/10/1995',
        connectionType: 'One-on-One',
        city: 'Rome',
        country: 'Italy',
        bio: 'Explorer and designer.',
        location: 'Colosseum, Rome, Italy',
        interests: interests,
      ),
      BondUserModel(
        id: '102',
        name: 'Helin Gakstadter',
        email: 'helin@gmail.com',
        image: 'https://i.pravatar.cc/150?u=102',
        username: 'helin_g',
        gender: 'Female',
        birthDate: '05/05/1996',
        connectionType: 'One-on-One',
        city: 'Berlin',
        country: 'Germany',
        bio: 'Active lifestyle enthusiast.',
        location: 'Brandenburg Gate, Berlin, Germany',
        interests: interests,
      ),
      BondUserModel(
        id: '103',
        name: 'Mick Behr Sr.',
        email: 'mick@gmail.com',
        image: 'https://i.pravatar.cc/150?u=103',
        username: 'mick_b',
        gender: 'Male',
        birthDate: '01/01/1990',
        connectionType: 'Group',
        city: 'London',
        country: 'UK',
        bio: 'Bonded with the best.',
        location: 'Big Ben, London, UK',
        interests: interests,
      ),
      BondUserModel(
        id: '104',
        name: 'Victoria Laux',
        email: 'victoria@gmail.com',
        image: 'https://i.pravatar.cc/150?u=104',
        username: 'victoria_l',
        gender: 'Female',
        birthDate: '12/12/1994',
        connectionType: 'One-on-One',
        city: 'Vienna',
        country: 'Austria',
        bio: 'Music is life.',
        location: 'Vienna State Opera, Vienna, Austria',
        interests: interests,
      ),
      BondUserModel(
        id: '105',
        name: 'Markus Riermeier III',
        email: 'markus@gmail.com',
        image: 'https://i.pravatar.cc/150?u=105',
        username: 'markus_r',
        gender: 'Female', // As per image
        birthDate: '02/02/1992',
        connectionType: 'One-on-One',
        city: 'Munich',
        country: 'Germany',
        bio: 'Tech and travel.',
        location: 'Marienplatz, Munich, Germany',
        interests: interests,
      ),
    ];

    conversations.assignAll([
      ConversationModel(user: mockUsers[0], lastMessage: 'Just ideas for next time', time: '20:00 PM', unreadCount: 3),
      ConversationModel(user: mockUsers[1], lastMessage: 'Just ideas for next time', time: '20:00 PM', unreadCount: 3),
      ConversationModel(user: mockUsers[2], lastMessage: 'Just ideas for next time', time: '20:00 PM'),
      ConversationModel(user: mockUsers[3], lastMessage: 'Just ideas for next time', time: '20:00 PM'),
      ConversationModel(user: mockUsers[4], lastMessage: 'Just ideas for next time', time: '20:00 PM'),
    ]);
  }
}
