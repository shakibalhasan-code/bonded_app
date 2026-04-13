import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final notificationsByDay = <String, List<NotificationModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    final today = [
      NotificationModel(
        id: '1',
        title: "Account Security Alert",
        description: "We've noticed some unusual activity on your account. Please review your recent logins and update your password if necessary.",
        timestamp: "09:41 AM",
        type: NotificationType.security,
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: "System Update Available",
        description: "A new system update is ready for installation. It includes performance improvements and bug fixes.",
        timestamp: "09:41 AM",
        type: NotificationType.update,
        isRead: false,
      ),
    ];

    final yesterday = [
      NotificationModel(
        id: '3',
        title: "Password Reset Successful",
        description: "Your password has been successfully reset. If you didn't request this change. Please contact support immediately.",
        timestamp: "09:41 AM",
        type: NotificationType.success,
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: "Password Reset Successful",
        description: "Your password has been successfully reset. If you didn't request this change. Please contact support immediately.",
        timestamp: "09:41 AM",
        type: NotificationType.success,
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: "Exciting New Feature",
        description: "We've just launched a new feature that will enhance your user experience, check it out",
        timestamp: "09:41 AM",
        type: NotificationType.success, // Design uses lock icon for this too in mockup
        isRead: true,
      ),
    ];

    notificationsByDay['Today'] = today;
    notificationsByDay['Yesterday'] = yesterday;
  }

  void markAsRead(String id) {
    for (var day in notificationsByDay.keys) {
      final list = notificationsByDay[day]!;
      final index = list.indexWhere((n) => n.id == id);
      if (index != -1) {
        list[index].isRead = true;
        notificationsByDay.refresh();
        break;
      }
    }
  }
}
