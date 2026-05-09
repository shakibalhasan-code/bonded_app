import 'dart:async';
import 'package:bonded_app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../core/routes/app_routes.dart';
import '../services/shared_prefs_service.dart';

class SplashController extends GetxController {
  // Observables for animation state if needed
  final RxDouble opacity = 0.0.obs;
  final RxDouble scale = 0.8.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
  }

  void _startAnimation() async {
    // Small delay before starting animation for better visual impact
    await Future.delayed(const Duration(milliseconds: 500));
    opacity.value = 1.0;
    scale.value = 1.0;

    // Minimum splash duration
    final splashDuration = Future.delayed(const Duration(seconds: 3));

    // Check for access token
    final token = SharedPrefsService.getString('accessToken');

    if (token != null && token.isNotEmpty) {
      final authController = Get.find<AuthController>();
      try {
        await authController.fetchUserProfile();

        // Wait for splash duration to complete if profile fetch was faster
        await splashDuration;

        if (authController.currentUser.value != null) {
          if (authController.currentUser.value!.profileCompleted) {
            Get.offAllNamed(AppRoutes.MAIN);
          } else {
            Get.offAllNamed(AppRoutes.PROFILE_BUILDING);
          }
        } else {
          // If profile fetch failed or user is null, go to login
          Get.offAllNamed(AppRoutes.LOGIN);
        }
      } catch (e) {
        await splashDuration;
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } else {
      await splashDuration;
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
