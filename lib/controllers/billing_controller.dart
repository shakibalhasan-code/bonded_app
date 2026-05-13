import 'dart:convert';
import 'dart:io';

import 'package:bonded_app/controllers/auth_controller.dart';
import 'package:bonded_app/controllers/home_controller.dart';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/core/constants/billing_config.dart';
import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:bonded_app/services/api_service.dart';
import 'package:bonded_app/services/billing_service.dart';
import 'package:bonded_app/services/ios_iap_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bonded_app/core/theme/app_colors.dart';
import 'package:bonded_app/controllers/circle_controller.dart';

import '../services/shared_prefs_service.dart';
import 'base_controller.dart';

class BillingController extends BaseController {
  final BillingService _billingService = BillingService();
  final ApiService _apiService = ApiService();

  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxBool isStoreAvailable = false.obs;

  // ──────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initializeStore();
    // Android purchase stream callback
    _billingService.onPurchaseUpdate = _handlePurchaseUpdate;
    _billingService.onError = (msg) => Get.snackbar('Billing Error', msg);
  }

  Future<void> _initializeStore() async {
    try {
      isStoreAvailable.value = await _billingService.isAvailable();
      if (isStoreAvailable.value) {
        await loadProducts();
      }
    } catch (e) {
      debugPrint('Billing Controller Init Error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Product loading
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    try {
      setLoading(true);

      // 1. Fetch product IDs from backend (dynamic)
      final response = await _apiService.get(AppUrls.storeProducts);
      final data = jsonDecode(response.body);

      Set<String> productIds = BillingConfig.allProductIds;

      if (data['success'] == true && data['data'] != null) {
        final List productsList = data['data'];
        final platform = !kIsWeb && Platform.isIOS ? 'apple' : 'google';
        final backendIds = productsList
            .where((p) => p['platform'] == null || p['platform'] == platform)
            .map((p) => p['productId'].toString())
            .toSet();
        if (backendIds.isNotEmpty) {
          productIds = backendIds;
        }

        // Push backend-resolved IDs into BillingConfig so every call-site
        // picks up the latest values without re-fetching.
        _applyBackendProductIds(productsList, platform);
      }

      // 2. Query the native store
      final fetched = await _billingService.getProducts(productIds);
      products.assignAll(fetched);
    } catch (e) {
      debugPrint('Error loading products: $e');
      final fetched = await _billingService.getProducts(
        BillingConfig.allProductIds,
      );
      products.assignAll(fetched);
    } finally {
      setLoading(false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Purchase entry points — each accepts a dynamic [productId]
  // ──────────────────────────────────────────────────────────────────────────

  /// Initiates a KYC verification purchase.
  ///
  /// [productId] — optional override; falls back to backend-resolved ID.
  Future<void> purchaseKycVerification({String? productId}) async {
    await _startPurchase(
      purpose: 'creator-verification',
      type: 'kyc',
      overrideProductId: productId,
    );
  }

  /// Initiates a subscription purchase.
  ///
  /// [productId] — optional override; falls back to backend-resolved ID.
  Future<void> purchaseSubscription({String? productId}) async {
    await _startPurchase(
      purpose: 'host-pro-subscription',
      type: 'subscription',
      overrideProductId: productId,
    );
  }

  /// Initiates a paid circle join.
  Future<void> purchaseCircleJoin(String circleId) async {
    try {
      setLoading(true);
      final response = await _apiService.post(
        AppUrls.circleJoinPaymentIntent(circleId),
        {},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _showCircleJoinPurchaseSheet(data['data']);
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to initiate purchase.',
        );
      }
    } catch (e) {
      debugPrint('Error purchasing circle join: $e');
      Get.snackbar('Error', 'An unexpected error occurred.');
    } finally {
      setLoading(false);
    }
  }

  /// Initiates a virtual event ticket purchase.
  ///
  /// [productId] — the store product ID for this ticket (dynamic per event).
  Future<void> purchaseVirtualTicket({
    required String bookingId,
    required String productId,
  }) async {
    await _executePurchase(
      productId: productId,
      context: {
        'type': 'virtual_event_ticket',
        'bookingId': bookingId,
        'productId': productId,
      },
      extraPrefs: {'pending_purchase_booking_id': bookingId},
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Core purchase logic
  // ──────────────────────────────────────────────────────────────────────────

  /// Resolves [productId] from backend (via [purpose]) or uses [overrideProductId],
  /// then calls [_executePurchase].
  Future<void> _startPurchase({
    required String purpose,
    required String type,
    String? overrideProductId,
  }) async {
    try {
      setLoading(true);
      String productId;

      if (overrideProductId != null && overrideProductId.isNotEmpty) {
        productId = overrideProductId;
      } else {
        final platform = !kIsWeb && Platform.isIOS ? 'apple' : 'google';
        final response = await _apiService.get(
          '${AppUrls.storeProducts}?purpose=$purpose&platform=$platform',
        );
        final data = jsonDecode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            (data['data'] as List).isNotEmpty) {
          productId = data['data'][0]['productId'];
        } else {
          Get.snackbar('Error', 'Failed to fetch product from server.');
          return;
        }
      }

      await _executePurchase(
        productId: productId,
        context: {'type': type, 'productId': productId},
      );
    } catch (e) {
      debugPrint('Error initiating $type purchase: $e');
      Get.snackbar('Error', 'An error occurred.');
    } finally {
      setLoading(false);
    }
  }

  /// Saves pending context to SharedPrefs and triggers the appropriate
  /// native purchase flow based on [Platform].
  Future<void> _executePurchase({
    required String productId,
    required Map<String, String> context,
    Map<String, String> extraPrefs = const {},
  }) async {
    // Persist context so _handlePurchaseUpdate / _verifyWithBackend can read it.
    for (final e in context.entries) {
      SharedPrefsService.saveString('pending_purchase_${e.key}', e.value);
    }
    SharedPrefsService.saveString('pending_purchase_product_id', productId);
    for (final e in extraPrefs.entries) {
      SharedPrefsService.saveString(e.key, e.value);
    }

    // ── Testing mode (Intercept all platforms) ───────────────────────────────
    if (BillingConfig.useTestingMode) {
      debugPrint('[BillingController] Testing mode active – using mock flow.');
      await _billingService.buyWithIosService(
        productId: productId,
        onSuccess: (IapResult r) {
          debugPrint('[BillingController] Mock purchase success: $r');
          _verifyIosWithBackend(r);
        },
      );
      return;
    }

    // ── iOS path ──────────────────────────────────────────────────────────
    if (!kIsWeb && Platform.isIOS) {
      final result = await _billingService.buyWithIosService(
        productId: productId,
        isConsumable: false,
        onSuccess: (IapResult r) {
          debugPrint('[BillingController] iOS purchase success: $r');
          _verifyIosWithBackend(r);
        },
        onIosError: (msg) => Get.snackbar('Purchase Error', msg),
        onPending: () =>
            debugPrint('[BillingController] iOS purchase pending...'),
      );

      if (!result.success && result.error != null) {
        Get.snackbar('Purchase Failed', result.error!);
      }
      return;
    }

    // ── Android path ──────────────────────────────────────────────────────
    final fetched = await _billingService.getProducts({productId});
    if (fetched.isNotEmpty) {
      await _billingService.buyProduct(fetched.first);
    } else {
      Get.snackbar('Error', 'Product "$productId" not found in Play Store.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Purchase callbacks
  // ──────────────────────────────────────────────────────────────────────────

  /// Called by [BillingService] for Android purchases (stream-based).
  Future<void> _handlePurchaseUpdate(PurchaseDetails pd) async {
    if (pd.status == PurchaseStatus.purchased ||
        pd.status == PurchaseStatus.restored) {
      final success = await _verifyWithBackend(pd);
      if (success) {
        if (pd.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(pd);
        }
        _refreshHome();

        final type = SharedPrefsService.getString('pending_purchase_type');
        if (type == 'subscription') {
          Get.offAllNamed(
            AppRoutes.PROFILE_READY,
            arguments: {
              'title': 'Subscribed Successfully!',
              'message':
                  'Your Host Pro subscription is now active. Enjoy your premium features!',
            },
          );
        } else {
          Get.snackbar('Success', 'Purchase verified and completed!');
        }
      } else {
        Get.snackbar('Error', 'Purchase verification failed with server.');
      }
    }
  }

  /// iOS confirmation — called immediately after [IosIapService] reports success.
  Future<void> _verifyIosWithBackend(IapResult result) async {
    try {
      setLoading(true);

      final String? type = SharedPrefsService.getString(
        'pending_purchase_type',
      );
      final String productId =
          SharedPrefsService.getString('pending_purchase_product_id') ??
          result.productId ??
          '';

      final body = _buildConfirmBody(
        platform: 'apple',
        type: type,
        productId: productId,
        transactionId:
            result.transactionId ?? BillingConfig.mockTransactionId(),
      );

      if (body == null) return;

      final response = await _apiService.post(AppUrls.iapConfirm, body);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        _clearPendingPrefs();
        _refreshHome();
        if (type == 'subscription') {
          Get.offAllNamed(
            AppRoutes.PROFILE_READY,
            arguments: {
              'title': 'Subscribed Successfully!',
              'message':
                  'Your Host Pro subscription is now active. Enjoy your premium features!',
            },
          );
        } else {
          Get.snackbar('Success', 'Purchase verified!');
        }
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Purchase verification failed with server.',
        );
      }
    } catch (e) {
      debugPrint('iOS backend verification error: $e');
      Get.snackbar('Error', 'Backend verification failed.');
    } finally {
      setLoading(false);
    }
  }

  /// Android backend confirmation.
  Future<bool> _verifyWithBackend(PurchaseDetails pd) async {
    try {
      setLoading(true);

      String? type = SharedPrefsService.getString('pending_purchase_type');
      final String? savedProductId = SharedPrefsService.getString(
        'pending_purchase_product_id',
      );

      // Auto-detect type from productId if not persisted.
      if (type == null || savedProductId != pd.productID) {
        if (pd.productID.contains('subscription') ||
            pd.productID == BillingConfig.subscriptionId) {
          type = 'subscription';
        } else if (pd.productID.contains('circle')) {
          type = 'circle_join';
        } else {
          type = 'kyc';
        }
      }

      final body = _buildConfirmBody(
        platform: 'google',
        type: type,
        productId: pd.productID,
        purchaseToken: pd.verificationData.serverVerificationData,
      );
      if (body == null) return false;

      final response = await _apiService.post(AppUrls.iapConfirm, body);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        _clearPendingPrefs();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Backend verification error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Builds the unified `/iap/confirm` request body.
  ///
  /// Returns `null` (and shows a snackbar) when required context is missing.
  Map<String, dynamic>? _buildConfirmBody({
    required String platform,
    required String? type,
    required String productId,
    String? transactionId,
    String? purchaseToken,
  }) {
    final String purpose;
    switch (type) {
      case 'subscription':
        purpose = 'host-pro-subscription';
      case 'kyc':
        purpose = 'creator-verification';
      case 'circle_join':
        purpose = 'circle-join';
      case 'virtual_event_ticket':
        purpose = 'virtual-event-ticket';
      default:
        purpose = type ?? 'creator-verification';
    }

    final body = <String, dynamic>{
      'platform': platform,
      'purpose': purpose,
      'productId': productId,
    };

    // Platform-specific token field.
    if (platform == 'apple' && transactionId != null) {
      body['transactionId'] = transactionId;
    } else if (platform == 'google' && purchaseToken != null) {
      body['purchaseToken'] = purchaseToken;
    }

    // Subscription expiry (1 month from now; backend can also compute this).
    if (purpose == 'host-pro-subscription') {
      body['expiresAt'] = DateTime.now()
          .add(const Duration(days: 30))
          .toUtc()
          .toIso8601String();
    }

    // Reference IDs for circle join and virtual event.
    if (purpose == 'circle-join') {
      final circleId = SharedPrefsService.getString(
        'pending_purchase_circle_id',
      );
      if (circleId == null || circleId.isEmpty) {
        Get.snackbar('Error', 'Circle ID missing for verification.');
        return null;
      }
      body['referenceId'] = circleId;
    } else if (purpose == 'virtual-event-ticket') {
      final bookingId = SharedPrefsService.getString(
        'pending_purchase_booking_id',
      );
      if (bookingId == null || bookingId.isEmpty) {
        Get.snackbar('Error', 'Booking ID missing for verification.');
        return null;
      }
      body['referenceId'] = bookingId;
    }

    return body;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Reads the backend product list and pushes matching IDs into [BillingConfig]
  /// so every call-site gets the latest values without re-fetching.
  void _applyBackendProductIds(List productsList, String platform) {
    String? findId(String purpose) {
      try {
        return productsList.firstWhere(
              (p) =>
                  p['purpose'] == purpose &&
                  (p['platform'] == null || p['platform'] == platform),
            )['productId']
            as String?;
      } catch (_) {
        return null;
      }
    }

    final isIos = platform == 'apple';
    BillingConfig.configure(
      iosKycVerificationId: isIos ? findId('creator-verification') : null,
      androidKycVerificationId: !isIos ? findId('creator-verification') : null,
      iosSubscriptionId: isIos ? findId('host-pro-subscription') : null,
      androidSubscriptionId: !isIos ? findId('host-pro-subscription') : null,
    );
  }

  void _clearPendingPrefs() {
    SharedPrefsService.delete('pending_purchase_type');
    SharedPrefsService.delete('pending_purchase_circle_id');
    SharedPrefsService.delete('pending_purchase_booking_id');
    SharedPrefsService.delete('pending_purchase_product_id');
  }

  void _refreshHome() {
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomeData();
      }
      // Auto-fetch user profile to sync subscription/kyc status
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().fetchUserProfile();
      }
    } catch (e) {
      debugPrint('Error refreshing home/profile after purchase: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Restore
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    await _billingService.restorePurchases();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────────────────

  void _showCircleJoinPurchaseSheet(Map<String, dynamic> data) {
    final platform = !kIsWeb && Platform.isIOS ? 'apple' : 'google';
    final products = data['products'];

    if (products == null || products[platform] == null) {
      Get.snackbar(
        'Error',
        'Product configuration not found for your platform ($platform).',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () {
            if (Get.isSnackbarOpen) Get.back();
            purchaseCircleJoin(data['referenceId'] ?? '');
          },
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    final product = products[platform];

    final String productId = product['productId'];
    final String circleId = data['referenceId'] ?? '';
    final double amount = (data['amount'] as num).toDouble();
    final String currency = data['currency'] ?? 'USD';

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                platform == 'apple' ? Icons.apple : Icons.shop_two_rounded,
                size: 40.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Premium Circle Access",
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Join this exclusive circle to unlock premium content, events, and community features.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amount to Pay",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeading,
                    ),
                  ),
                  Text(
                    "$amount $currency",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: Colors.amber[800],
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "This purchase option is currently under review by ${platform == 'apple' ? 'Apple' : 'Google Play Store'} to meet their privacy policy. Use testing mode for immediate access.",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.amber[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _executePurchase(
                  productId: productId,
                  context: {
                    'type': 'circle_join',
                    'circleId': circleId,
                    'productId': productId,
                  },
                  extraPrefs: {'pending_purchase_circle_id': circleId},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 60.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Continue with Store",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => TextButton(
                  onPressed: isLoading.value
                      ? null
                      : () {
                          if (circleId.isEmpty || productId.isEmpty) {
                            Get.snackbar('Error', 'Missing circle or product information');
                            return;
                          }
                          confirmPurchaseWithTesting(
                            circleId: circleId,
                            productId: productId,
                            purpose: 'circle-join',
                          );
                        },
                  child: isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : Text(
                          "Process with Testing",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                )),
            SizedBox(height: 12.h),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> confirmPurchaseWithTesting({
    required String circleId,
    required String productId,
    required String purpose,
  }) async {
    try {
      setLoading(true);
      final platform = !kIsWeb && Platform.isIOS ? 'apple' : 'google';
      final body = {
        'platform': platform,
        'purpose': purpose,
        'productId': productId,
        'transactionId': BillingConfig.mockTransactionId(),
        'referenceId': circleId,
      };

      final response = await _apiService.post(AppUrls.iapConfirm, body);
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        if (Get.isOverlaysOpen) Get.back(); // Close bottom sheet
        _refreshHome();

        // Refresh Circle Data
        if (Get.isRegistered<CircleController>()) {
          final circleController = Get.find<CircleController>();
          circleController.fetchCircles(scope: 'joined');
          circleController.fetchCircles(visibility: 'public');
          circleController.fetchCircles(visibility: 'private');
        }

        Get.snackbar(
          "Success",
          "Joined circle successfully (Testing Mode)",
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to confirm purchase",
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error confirming purchase with testing: $e");
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    _billingService.dispose();
    super.onClose();
  }
}
