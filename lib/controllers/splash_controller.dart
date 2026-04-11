import 'dart:async';
import 'package:get/get.dart';
import '../screens/onboarding/onboarding_screen.dart';

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

    // Navigate to next screen after delay
    Timer(const Duration(seconds: 3), () {
      Get.off(() => const OnboardingScreen());
    });
  }
}
