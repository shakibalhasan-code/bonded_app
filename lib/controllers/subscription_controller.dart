import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../widgets/profile/verification_success_dialog.dart';
import '../screens/home/home_screen.dart';

class SubscriptionController extends GetxController {
  final RxString selectedPlan = 'Free Tier'.obs;
  final RxString selectedPaymentMethod = ''.obs;

  // Plan Prices
  final Map<String, String> planPrices = {
    'Free Tier': '0.00',
    'Pro Tier': '14.99',
    'Premium Tier': '29.99',
    'Host Pro': '29.99',
  };

  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void completeSubscription(BuildContext context) {
    Get.dialog(
      VerificationSuccessDialog(
        title: "Subscription Purchased Successfully!",
        description: "Your subscription is active! Enjoy all the premium features and make the most of your experience.",
        onPressed: () {
          Get.offAll(() => const HomeScreen());
        },
      ),
      barrierDismissible: false,
    );
  }
}
