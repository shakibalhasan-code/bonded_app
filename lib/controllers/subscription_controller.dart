import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../widgets/profile/verification_success_dialog.dart';
import '../core/routes/app_routes.dart';

class SubscriptionController extends GetxController {
  final selectedPlan = 'Pro'.obs;
  final selectedPaymentMethod = 'Credit Card'.obs;

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
          Get.offAllNamed(AppRoutes.PROFILE_READY);
        },
      ),
      barrierDismissible: false,
    );
  }
}
