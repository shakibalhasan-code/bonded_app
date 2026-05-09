import 'dart:async';
import 'dart:convert';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/services/api_service.dart';
import 'package:bonded_app/services/shared_prefs_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'base_controller.dart';
import 'billing_controller.dart';

class KycController extends BaseController {
  final ApiService _apiService = ApiService();
  final billingController = Get.isRegistered<BillingController>() 
      ? Get.find<BillingController>() 
      : Get.put(BillingController());

  final RxMap<String, dynamic> kycData = <String, dynamic>{}.obs;
  final RxBool isPollingStripe = false.obs;
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchKycStatus();
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
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
      setLoading(true);
      final response = await _apiService.post(AppUrls.stripeOnboard, {});
      final data = jsonDecode(response.body);
      
      if (data['success'] == true && data['data'] != null) {
        final String onboardingUrl = data['data']['onboardingUrl'];
        if (await canLaunchUrl(Uri.parse(onboardingUrl))) {
          await launchUrl(Uri.parse(onboardingUrl), mode: LaunchMode.externalApplication);
          _startPolling();
        } else {
          Get.snackbar('Error', 'Could not launch Stripe onboarding link');
        }
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to start Stripe onboarding');
      }
    } catch (e) {
      debugPrint('Error starting Stripe Connect: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  }

  void _startPolling() {
    _stopPolling();
    isPollingStripe.value = true;
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
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
        kycData['creatorVerificationStatus'] = status['creatorVerificationStatus'];
        kycData['payoutEligible'] = status['payoutEligible'];
        kycData.refresh();

        if (status['creatorVerificationStatus'] == 'verified' && status['payoutEligible'] == true) {
          _stopPolling();
          Get.snackbar('Success', 'Creator verification completed successfully!', 
            backgroundColor: Get.theme.primaryColor, colorText: Get.theme.colorScheme.onPrimary);
        }
      }
    } catch (e) {
      debugPrint('Error polling Stripe status: $e');
    }
  }

  String get verificationStatus => kycData['creatorVerificationStatus'] ?? 'unpaid';
  bool get isFeePaid => ['fee_paid', 'connect_pending', 'verified'].contains(verificationStatus);
  bool get isStripeComplete => verificationStatus == 'verified';
  bool get isPayoutEligible => kycData['payoutEligible'] ?? false;
  
  double get feeAmount => kycData['verificationFee']?['amount']?.toDouble() ?? 0.0;
  String get feeCurrency => kycData['verificationFee']?['currency'] ?? 'USD';
}
