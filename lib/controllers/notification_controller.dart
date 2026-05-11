import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../core/constants/app_endpoints.dart';
import '../services/shared_prefs_service.dart';
import 'package:flutter/foundation.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = ApiService();
  
  final notificationsByDay = <String, List<NotificationModel>>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final token = SharedPrefsService.getString('accessToken');
      if (token == null) return;

      final response = await _apiService.get(
        AppUrls.notifications,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> notificationsData = data['data'];
        final notifications = notificationsData
            .map((n) => NotificationModel.fromJson(n))
            .toList();
        
        _groupNotificationsByDay(notifications);
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _groupNotificationsByDay(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String dayKey;
      if (date == today) {
        dayKey = 'Today';
      } else if (date == yesterday) {
        dayKey = 'Yesterday';
      } else {
        dayKey = DateFormat('MMMM dd, yyyy').format(date);
      }

      if (!grouped.containsKey(dayKey)) {
        grouped[dayKey] = [];
      }
      grouped[dayKey]!.add(notification);
    }

    notificationsByDay.value = grouped;
  }

  Future<void> markAsRead(String id) async {
    // Optimistic UI update
    for (var day in notificationsByDay.keys) {
      final list = notificationsByDay[day]!;
      final index = list.indexWhere((n) => n.id == id);
      if (index != -1) {
        list[index].isRead = true;
        notificationsByDay.refresh();
        break;
      }
    }

    // Backend call could be implemented here if there's an endpoint
    // await _apiService.patch('${AppUrls.notifications}/$id/read', {});
  }
}
