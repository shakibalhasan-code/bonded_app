import 'dart:convert';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bond_user_model.dart';
import '../services/api_service.dart';

class BondController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var nearbyPeople = <BondConnectionModel>[].obs;
  var bondRequests = <BondConnectionModel>[].obs;
  var outgoingRequests = <BondConnectionModel>[].obs;
  var myBonds = <BondConnectionModel>[].obs;
  
  var isLoadingNearby = false.obs;
  var isLoadingRequests = false.obs;
  var isLoadingOutgoing = false.obs;
  var isLoadingMyBonds = false.obs;

  var showOutgoingRequests = false.obs;
  
  // Search State
  final searchQuery = "".obs;
  late final TextEditingController searchController;

  List<BondConnectionModel> get filteredNearbyPeople => _filterUsers(nearbyPeople);
  List<BondConnectionModel> get filteredBondRequests => _filterUsers(showOutgoingRequests.value ? outgoingRequests : bondRequests);
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
      fetchOutgoingRequests(),
      fetchMyBonds(),
    ]);
  }
  Future<void> fetchOutgoingRequests() async {
    try {
      isLoadingOutgoing.value = true;
      final response = await _apiService.get(AppUrls.outgoingRequests);
      final data = jsonDecode(response.body);
      if (data['success']) {
        outgoingRequests.assignAll(
          (data['data'] as List).map((json) => BondConnectionModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching outgoing requests: $e');
    } finally {
      isLoadingOutgoing.value = false;
    }
  }

  Future<void> cancelBondRequest(String bondId) async {
    try {
      final response = await _apiService.delete('${AppUrls.bondRequests}/$bondId');
      final data = jsonDecode(response.body);
      if (data['success']) {
        Get.snackbar('Success', 'Bond request cancelled');
        fetchOutgoingRequests();
        fetchNearbyPeople();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel bond request: $e');
    }
  }

  Future<void> fetchNearbyPeople() async {
    try {
      isLoadingNearby.value = true;
      final response = await _apiService.get(AppUrls.nearbyBonds);
      final data = jsonDecode(response.body);
      if (data['success']) {
        nearbyPeople.assignAll(
          (data['data'] as List).map((json) => BondConnectionModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching nearby people: $e');
    } finally {
      isLoadingNearby.value = false;
    }
  }

  Future<void> fetchIncomingRequests() async {
    try {
      isLoadingRequests.value = true;
      final response = await _apiService.get(AppUrls.incomingRequests);
      final data = jsonDecode(response.body);
      if (data['success']) {
        bondRequests.assignAll(
          (data['data'] as List).map((json) => BondConnectionModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching bond requests: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> fetchMyBonds() async {
    try {
      isLoadingMyBonds.value = true;
      final response = await _apiService.get(AppUrls.myBonds);
      final data = jsonDecode(response.body);
      if (data['success']) {
        myBonds.assignAll(
          (data['data'] as List).map((json) => BondConnectionModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching my bonds: $e');
    } finally {
      isLoadingMyBonds.value = false;
    }
  }

  Future<void> sendBondRequest(String userId) async {
    try {
      final response = await _apiService.post('${AppUrls.bondRequests}/$userId');
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
      final response = await _apiService.patch('${AppUrls.bondRequests}/$bondId/accept');
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
      final response = await _apiService.patch('${AppUrls.bondRequests}/$bondId/reject');
      final data = jsonDecode(response.body);
      if (data['success']) {
        Get.snackbar('Success', 'Bond request rejected');
        fetchIncomingRequests();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject bond request: $e');
    }
  }

  Future<void> removeBond(String bondId) async {
    try {
      final response = await _apiService.delete('${AppUrls.bonds}/$bondId');
      final data = jsonDecode(response.body);
      if (data['success']) {
        Get.snackbar('Success', 'Bond removed successfully');
        fetchMyBonds();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove bond: $e');
    }
  }
}
