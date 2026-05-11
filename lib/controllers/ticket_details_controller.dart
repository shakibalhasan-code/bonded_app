import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../core/constants/app_endpoints.dart';

class TicketDetailsController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxBool isLoading = false.obs;
  final Rxn<TicketModel> ticket = Rxn<TicketModel>();

  Future<void> fetchTicketDetails(String ticketId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.get(AppUrls.singleTicket(ticketId));
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        ticket.value = TicketModel.fromJson(data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching ticket details: $e");
      Get.snackbar("Error", "Failed to fetch ticket details");
    } finally {
      isLoading.value = false;
    }
  }

  void setTicket(TicketModel initialTicket) {
    ticket.value = initialTicket;
    fetchTicketDetails(initialTicket.id);
  }
}
