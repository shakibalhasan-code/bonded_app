import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bond_user_model.dart';
import '../services/api_service.dart';

class BondController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var nearbyPeople = <BondConnectionModel>[].obs;
  var bondRequests = <BondConnectionModel>[].obs;
  var myBonds = <BondConnectionModel>[].obs;
  
  var isLoadingNearby = false.obs;
  var isLoadingRequests = false.obs;
  var isLoadingMyBonds = false.obs;
  
  // Search State
  final searchQuery = "".obs;
  late final TextEditingController searchController;

  List<BondConnectionModel> get filteredNearbyPeople => _filterUsers(nearbyPeople);
  List<BondConnectionModel> get filteredBondRequests => _filterUsers(bondRequests);
  List<BondConnectionModel> get filteredMyBonds => _filterUsers(myBonds);

  List<BondConnectionModel> _filterUsers(List<BondConnectionModel> connections) {
    if (searchQuery.value.isEmpty) return connections;
    final query = searchQuery.value.toLowerCase();
    return connections
        .where((c) =>
            (c.user.fullName?.toLowerCase().contains(query) ?? false) ||
            (c.user.username?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    fetchAllData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchNearbyPeople(),
      fetchIncomingRequests(),
      fetchMyBonds(),
    ]);
  }

  Future<void> fetchNearbyPeople() async {
    try {
      isLoadingNearby.value = true;
      final response = await _apiService.get('/bonds/nearby');
      final data = jsonDecode(response.body);
      if (data['success']) {
        nearbyPeople.assignAll(
          (data['data'] as List).map((json) => BondConnectionModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch nearby people: $e');
    } finally {
      isLoadingNearby.value = false;
    }
  }

  Future<void> fetchIncomingRequests() async {
    try {
      isLoadingRequests.value = true;
      final response = await _apiService.get('/bonds/requests/incoming');
      final data = jsonDecode(response.body);
      if (data['success']) {
        bondRequests.assignAll(
          (data['data'] as List).map((json) => BondConnectionModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch bond requests: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> fetchMyBonds() async {
    try {
      isLoadingMyBonds.value = true;
      final response = await _apiService.get('/bonds/connections');
      final data = jsonDecode(response.body);
      if (data['success']) {
        myBonds.assignAll(
          (data['data'] as List).map((json) => BondConnectionModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch my bonds: $e');
    } finally {
      isLoadingMyBonds.value = false;
    }
  }

  Future<void> sendBondRequest(String userId) async {
    try {
      final response = await _apiService.post('/bonds/request/$userId');
      final data = jsonDecode(response.body);
      if (data['success']) {
        Get.snackbar('Success', 'Bond request sent');
        fetchNearbyPeople();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send bond request: $e');
    }
  }

  Future<void> acceptBondRequest(String bondId) async {
    try {
      final response = await _apiService.patch('/bonds/request/accept/$bondId');
      final data = jsonDecode(response.body);
      if (data['success']) {
        Get.snackbar('Success', 'Bond request accepted');
        fetchIncomingRequests();
        fetchMyBonds();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept bond request: $e');
    }
  }

  Future<void> rejectBondRequest(String bondId) async {
    try {
      final response = await _apiService.patch('/bonds/request/reject/$bondId');
      final data = jsonDecode(response.body);
      if (data['success']) {
        Get.snackbar('Success', 'Bond request rejected');
        fetchIncomingRequests();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject bond request: $e');
    }
  }
}
