import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class HostDetailsController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> hostProfile = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final String? hostId = Get.arguments;
    if (hostId != null) {
      fetchHostProfile(hostId);
    } else {
      isLoading.value = false;
      Get.snackbar("Error", "Host ID not found.");
    }
  }

  Future<void> fetchHostProfile(String id) async {
    try {
      isLoading.value = true;
      final response = await _apiService.get("/user/$id");
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        hostProfile.value = data['data'];
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to load host profile");
      }
    } catch (e) {
      debugPrint("Error fetching host profile: $e");
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }
}
