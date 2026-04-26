import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bond_user_model.dart';

class BondController extends GetxController {
  var nearbyPeople = <BondUserModel>[].obs;
  var bondRequests = <BondUserModel>[].obs;
  var myBonds = <BondUserModel>[].obs;
  
  // Search State
  final searchQuery = "".obs;
  late final TextEditingController searchController;

  List<BondUserModel> get filteredNearbyPeople => _filterUsers(nearbyPeople);
  List<BondUserModel> get filteredBondRequests => _filterUsers(bondRequests);
  List<BondUserModel> get filteredMyBonds => _filterUsers(myBonds);

  List<BondUserModel> _filterUsers(List<BondUserModel> users) {
    if (searchQuery.value.isEmpty) return users;
    return users
        .where((u) =>
            u.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            u.username.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    _loadMockData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadMockData() {
    final interests = {
      'Social & Lifestyle': ['Brunch Lovers', 'Wine Nights', 'Game Nights'],
      'Sports & Fitness': ['Gym & Fitness', 'Running', 'Yoga & Meditation'],
      'Music & Entertainment': ['Pop', 'R&B', 'Hip-Hop'],
      'Travel & Adventure': ['Group Travel', 'Road Trips', 'Weekend Gateways'],
    };

    final mockUsers = [
      BondUserModel(
        id: '1',
        name: 'Matthias Huckestein',
        email: 'mattias_huck@gmail.com',
        image: 'https://i.pravatar.cc/150?u=1',
        username: 'Ainsley_006',
        gender: 'Male',
        birthDate: '16/09/1994',
        connectionType: 'One-on-One',
        city: 'New York',
        country: 'United States of America',
        bio: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        location: 'Time Square NYC, California, United States',
        interests: interests,
        isVerified: true,
        status: BondStatus.nearby,
      ),
      BondUserModel(
        id: '2',
        name: 'Maike Rother',
        email: 'maike@gmail.com',
        image: 'https://i.pravatar.cc/150?u=2',
        username: 'maike_r',
        gender: 'Female',
        birthDate: '22/05/1996',
        connectionType: 'Group',
        city: 'Berlin',
        country: 'Germany',
        bio: 'Enthusiastic traveler and food lover.',
        location: 'Alexanderplatz, Berlin, Germany',
        interests: interests,
        status: BondStatus.nearby,
      ),
       BondUserModel(
        id: '3',
        name: 'Lilli Tepper',
        email: 'lilli@gmail.com',
        image: 'https://i.pravatar.cc/150?u=3',
        username: 'lilli_t',
        gender: 'Female',
        birthDate: '10/12/1995',
        connectionType: 'One-on-One',
        city: 'Paris',
        country: 'France',
        bio: 'Art and culture enthusiast.',
        location: 'Le Marais, Paris, France',
        interests: interests,
        status: BondStatus.requested,
      ),
      BondUserModel(
        id: '4',
        name: 'Fabienne Wakan',
        email: 'fabienne@gmail.com',
        image: 'https://i.pravatar.cc/150?u=4',
        username: 'fabienne_w',
        gender: 'Female',
        birthDate: '05/03/1993',
        connectionType: 'One-on-One',
        city: 'Zurich',
        country: 'Switzerland',
        bio: 'Nature lover and hiker.',
        location: 'Lake Zurich, Zurich, Switzerland',
        interests: interests,
        status: BondStatus.bonded,
      ),
    ];

    nearbyPeople.assignAll(mockUsers.where((u) => u.bondStatus.value == BondStatus.nearby));
    bondRequests.assignAll(mockUsers.where((u) => u.bondStatus.value == BondStatus.requested));
    myBonds.assignAll(mockUsers.where((u) => u.bondStatus.value == BondStatus.bonded));
  }

  void sendBondRequest(BondUserModel user) {
    user.bondStatus.value = BondStatus.requested;
    nearbyPeople.remove(user);
    bondRequests.add(user);
    Get.snackbar('Success', 'Bond request sent to ${user.name}');
  }

  void acceptBondRequest(BondUserModel user) {
    user.bondStatus.value = BondStatus.bonded;
    bondRequests.remove(user);
    myBonds.add(user);
    Get.snackbar('Accepted', 'You are now bonded with ${user.name}');
  }

  void rejectBondRequest(BondUserModel user) {
    user.bondStatus.value = BondStatus.nearby;
    bondRequests.remove(user);
    nearbyPeople.add(user);
    Get.snackbar('Rejected', 'Bond request from ${user.name} rejected');
  }
}
