import 'dart:async';
import 'dart:convert';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/core/constants/billing_config.dart';
import 'package:bonded_app/services/api_service.dart';
import 'package:bonded_app/services/shared_prefs_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'base_controller.dart';
import 'billing_controller.dart';
import '../services/ios_iap_service.dart';
import '../widgets/profile/verification_success_dialog.dart';
import '../core/routes/app_routes.dart';

class KycController extends BaseController with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final billingController = Get.isRegistered<BillingController>()
      ? Get.find<BillingController>()
      : Get.put(BillingController());

  final RxMap<String, dynamic> kycData = <String, dynamic>{}.obs;

  // Separate loading states
  final RxBool isFeeLoading = false.obs;
  final RxBool isStripeLoading = false.obs;

  final RxBool isPollingStripe = false.obs;
  Timer? _pollingTimer;
  int _pollingRetryCount = 0;
  static const int maxPollingRetries = 60; // Stop after 5 mins (5s * 60)

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchKycStatus();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Pause polling when app is in background
      _pollingTimer?.cancel();
    } else if (state == AppLifecycleState.resumed && isPollingStripe.value) {
      // Resume polling when user returns
      _startPolling();
    }
  }

  Future<void> fetchKycStatus() async {
    try {
      setLoading(true);
      final response = await _apiService.get(AppUrls.kycMe);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        kycData.value = data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching KYC status: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> startStripeConnect() async {
    try {
      isStripeLoading.value = true;
      final response = await _apiService.post(AppUrls.stripeOnboard, {});
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final String onboardingUrl = data['data']['onboardingUrl'];
        if (await canLaunchUrl(Uri.parse(onboardingUrl))) {
          await launchUrl(
            Uri.parse(onboardingUrl),
            mode: LaunchMode.externalApplication,
          );
          _pollingRetryCount = 0; // Reset counter
          _startPolling();
        } else {
          Get.snackbar('Error', 'Could not launch Stripe onboarding link');
        }
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to start Stripe onboarding',
        );
      }
    } catch (e) {
      debugPrint('Error starting Stripe Connect: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isStripeLoading.value = false;
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    isPollingStripe.value = true;
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_pollingRetryCount >= maxPollingRetries) {
        _stopPolling();
        debugPrint('[KycController] Max polling retries reached.');
        return;
      }
      _pollingRetryCount++;
      await pollStripeStatus();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    isPollingStripe.value = false;
  }

  Future<void> pollStripeStatus() async {
    try {
      final response = await _apiService.get(AppUrls.stripeStatus);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final status = data['data'];
        // Update local kycData with new stripe status
        kycData['stripeConnect'] = status;
        kycData['creatorVerificationStatus'] =
            status['creatorVerificationStatus'];
        kycData['payoutEligible'] = status['payoutEligible'];
        kycData.refresh();

        if (status['creatorVerificationStatus'] == 'verified' &&
            status['payoutEligible'] == true) {
          _stopPolling();
          Get.snackbar(
            'Success',
            'Creator verification completed successfully!',
            backgroundColor: Get.theme.primaryColor,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        }
      }
    } catch (e) {
      debugPrint('Error polling Stripe status: $e');
    }
  }

  String get verificationStatus =>
      kycData['creatorVerificationStatus'] ?? 'unpaid';
  bool get isFeePaid =>
      ['fee_paid', 'connect_pending', 'verified'].contains(verificationStatus);
  bool get isStripeComplete => verificationStatus == 'verified';
  bool get isPayoutEligible => kycData['payoutEligible'] ?? false;

  double get feeAmount =>
      kycData['verificationFee']?['amount']?.toDouble() ?? 0.0;
  String get feeCurrency => kycData['verificationFee']?['currency'] ?? 'USD';

  // ──────────────────────────────────────────────────────────────────────────
  // Purchase Verification Fee
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> purchaseVerificationFee() async {
    if (isFeePaid) return;

    try {
      isFeeLoading.value = true;

      // Use IosIapService directly to support the mock debug sheet
      final result = await IosIapService.instance.purchase(
        BillingConfig.kycVerificationId,
      );

      if (!result.success) {
        if (result.error != null &&
            result.error != 'Purchase cancelled by user.') {
          Get.snackbar('Purchase Failed', result.error!);
        }
        return;
      }

      await _verifyPurchaseWithBackend(result);
    } catch (e) {
      debugPrint('[KycController] Purchase error: $e');
      Get.snackbar('Error', 'Failed to initiate purchase');
    } finally {
      isFeeLoading.value = false;
    }
  }

  Future<void> _verifyPurchaseWithBackend(IapResult result) async {
    try {
      final body = <String, dynamic>{
        'platform': 'apple',
        'purpose': 'creator-verification',
        'productId': BillingConfig.kycVerificationId,
        'transactionId':
            result.transactionId ?? BillingConfig.mockTransactionId(),
      };

      final response = await _apiService.post(AppUrls.iapConfirm, body);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        await fetchKycStatus(); // Refresh status
        _showSuccessDialog();
      } else {
        Get.snackbar(
          'Verification Failed',
          data['message'] ?? 'Could not verify purchase with server.',
        );
      }
    } catch (e) {
      debugPrint('[KycController] Backend verify error: $e');
      Get.snackbar('Error', 'Failed to verify purchase.');
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      VerificationSuccessDialog(
        title: "Verification Fee Paid!",
        description:
            "Your payment was successful. You can now proceed to set up your Stripe Connect account.",
        onPressed: () => Get.back(),
      ),
      barrierDismissible: false,
    );
  }
}
