import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/routes/app_routes.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    await requestPermissions();
    listenToMessages();
  }

  Future<void> requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<String?> getFcmToken() async {
    try {
      String? token = await _fcm.getToken();
      debugPrint("FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return null;
    }
  }

  void listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        Get.snackbar(
          message.notification!.title ?? 'New Notification',
          message.notification!.body ?? '',
          snackPosition: SnackPosition.TOP,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _handleNotificationRouting(message);
    });
  }

  void _handleNotificationRouting(RemoteMessage message) {
    final data = message.data;
    final String? type = data['type'];
    final String? id = data['id'];

    if (type == null) return;

    switch (type) {
      case 'chat':
        if (id != null) {
          Get.toNamed(AppRoutes.CHAT, arguments: {'conversationId': id});
        }
        break;
      case 'event':
        if (id != null) {
          Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: id);
        }
        break;
      case 'circle':
        if (id != null) {
          Get.toNamed(AppRoutes.JOINED_CIRCLE_DETAILS, arguments: id);
        }
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }
}
