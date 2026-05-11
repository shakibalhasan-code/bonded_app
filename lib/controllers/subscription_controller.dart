import 'dart:convert';
import 'dart:io';

import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants/billing_config.dart';
import '../services/ios_iap_service.dart';
import '../widgets/profile/verification_success_dialog.dart';
import '../core/routes/app_routes.dart';

class SubscriptionController extends GetxController {
  final _api = ApiService();

  final selectedPlan = 'Host Pro'.obs;
  final isLoading = false.obs;

  /// Live product fetched from App Store — null until loaded.
  final Rx<ProductDetails?> product = Rx(null);

  /// Formatted price string — real App Store price, debug mock, or empty
  /// while loading.
  String get displayPrice {
    if (BillingConfig.isIosDebug) {
      return BillingConfig.debugPrice(BillingConfig.subscriptionId);
    }
    return product.value?.price ?? '';
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _fetchProduct();
  }

  /// Fetches the subscription product directly from the App Store.
  Future<void> _fetchProduct() async {
    if (kIsWeb || !Platform.isIOS || BillingConfig.isIosDebug) return;

    try {
      final p = await IosIapService.instance
          .fetchProduct(BillingConfig.subscriptionId);
      product.value = p;
    } catch (e) {
      debugPrint('[SubscriptionController] Fetch error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────

  void selectPlan(String plan) => selectedPlan.value = plan;

  Future<void> completeSubscription(BuildContext context) async {
    if (selectedPlan.value == 'Free') {
      _showSuccessDialog();
      return;
    }

    isLoading.value = true;
    try {
      final result = await IosIapService.instance.purchase(
        BillingConfig.subscriptionId,
      );

      if (!result.success) {
        // Cancelled by user — silent. Any other error shows a message.
        if (result.error != null &&
            result.error != 'Purchase cancelled by user.') {
          Get.snackbar('Purchase Failed', result.error!);
        }
        return;
      }

      await _verifyWithBackend(result);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _verifyWithBackend(IapResult result) async {
    try {
      final body = <String, dynamic>{
        'platform': 'apple',
        'purpose': 'host-pro-subscription',
        'productId': BillingConfig.subscriptionId,
        'transactionId': result.transactionId ?? BillingConfig.mockTransactionId(),
        'expiresAt': DateTime.now()
            .add(const Duration(days: 30))
            .toUtc()
            .toIso8601String(),
      };

      final response = await _api.post(AppUrls.iapConfirm, body);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        _showSuccessDialog();
      } else {
        Get.snackbar(
          'Verification Failed',
          data['message'] ?? 'Could not verify purchase with server.',
        );
      }
    } catch (e) {
      debugPrint('[SubscriptionController] Backend verify error: $e');
      Get.snackbar('Error', 'Failed to verify purchase.');
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      VerificationSuccessDialog(
        title: "Subscription Purchased Successfully!",
        description:
            "Your subscription is active! Enjoy all the premium features "
            "and make the most of your experience.",
        onPressed: () => Get.offAllNamed(AppRoutes.PROFILE_READY),
      ),
      barrierDismissible: false,
    );
  }
}
