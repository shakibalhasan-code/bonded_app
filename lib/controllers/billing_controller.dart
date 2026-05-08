import 'dart:convert';
import 'dart:io';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/core/constants/billing_config.dart';
import 'package:bonded_app/services/api_service.dart';
import 'package:bonded_app/services/billing_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'base_controller.dart';

class BillingController extends BaseController {
  final BillingService _billingService = BillingService();
  final ApiService _apiService = ApiService();

  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxBool isStoreAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeStore();
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

  Future<void> loadProducts() async {
    try {
      setLoading(true);

      // 1. Fetch from Backend to get dynamic IDs if available
      final response = await _apiService.get(AppUrls.storeProducts);
      final data = jsonDecode(response.body);

      Set<String> productIds = BillingConfig.allProductIds;

      if (data['success'] == true && data['data'] != null) {
        final List productsList = data['data'];
        final backendIds = productsList
            .map((p) => p['productId'].toString())
            .toSet();
        if (backendIds.isNotEmpty) {
          productIds = backendIds;
        }
      }

      // 2. Fetch from Native Store
      final fetchedProducts = await _billingService.getProducts(productIds);
      products.assignAll(fetchedProducts);
    } catch (e) {
      debugPrint('Error loading products: $e');
      // Fallback to config IDs if backend fails
      final fetchedProducts = await _billingService.getProducts(
        BillingConfig.allProductIds,
      );
      products.assignAll(fetchedProducts);
    } finally {
      setLoading(false);
    }
  }

  Future<void> purchaseKycVerification() async {
    final product = products.firstWhereOrNull(
      (p) => p.id == BillingConfig.kycVerificationId,
    );
    if (product != null) {
      await _billingService.buyProduct(product);
    } else {
      Get.snackbar('Error', 'Verification product not found in store.');
    }
  }

  Future<void> purchaseSubscription() async {
    final product = products.firstWhereOrNull(
      (p) => p.id == BillingConfig.subscriptionId,
    );
    if (product != null) {
      await _billingService.buyProduct(product);
    } else {
      Get.snackbar('Error', 'Subscription product not found in store.');
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      // Call backend to verify
      final success = await _verifyWithBackend(purchaseDetails);

      if (success) {
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
        Get.snackbar('Success', 'Purchase verified and completed!');
      } else {
        Get.snackbar('Error', 'Purchase verification failed with server.');
      }
    }
  }

  Future<bool> _verifyWithBackend(PurchaseDetails purchaseDetails) async {
    try {
      setLoading(true);

      final Map<String, dynamic> body = {
        'platform': Platform.isAndroid ? 'google' : 'apple',
      };

      if (Platform.isAndroid) {
        body['googlePurchaseToken'] =
            purchaseDetails.verificationData.serverVerificationData;
        body['productId'] = purchaseDetails.productID;
      } else {
        body['appleTransactionId'] = purchaseDetails.purchaseID;
        // In some cases for Apple, you might need the receipt data
        body['receiptData'] =
            purchaseDetails.verificationData.serverVerificationData;
      }

      final response = await _apiService.post(AppUrls.verifyPurchase, body);
      final data = jsonDecode(response.body);

      return data['success'] == true;
    } catch (e) {
      debugPrint('Backend verification error: $e');
      return false;
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
