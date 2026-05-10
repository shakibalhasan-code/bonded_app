import 'dart:convert';
import 'dart:io';
import 'package:bonded_app/controllers/home_controller.dart';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/core/constants/billing_config.dart';
import 'package:bonded_app/services/api_service.dart';
import 'package:bonded_app/services/billing_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/shared_prefs_service.dart';
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

  Map<String, String>? _currentPurchaseContext;

  Future<void> purchaseKycVerification() async {
    try {
      setLoading(true);
      final platform = Platform.isAndroid ? 'google' : 'apple';
      final response = await _apiService.get(
        '${AppUrls.storeProducts}?purpose=creator-verification&platform=$platform',
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data'].isNotEmpty) {
        final productId = data['data'][0]['productId'];
        final fetchedProducts = await _billingService.getProducts({productId});
        if (fetchedProducts.isNotEmpty) {
          _currentPurchaseContext = {'type': 'kyc', 'productId': productId};
          SharedPrefsService.saveString('pending_purchase_type', 'kyc');
          SharedPrefsService.saveString(
            'pending_purchase_product_id',
            productId,
          );
          await _billingService.buyProduct(fetchedProducts.first);
        } else {
          Get.snackbar('Error', 'Verification product not found in store.');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch verification product.');
      }
    } catch (e) {
      debugPrint('Error initiating kyc purchase: $e');
      Get.snackbar('Error', 'An error occurred.');
    } finally {
      setLoading(false);
    }
  }

  Future<void> purchaseSubscription() async {
    try {
      setLoading(true);
      final platform = Platform.isAndroid ? 'google' : 'apple';
      final response = await _apiService.get(
        '${AppUrls.storeProducts}?purpose=host-pro-subscription&platform=$platform',
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data'].isNotEmpty) {
        final productId = data['data'][0]['productId'];
        final fetchedProducts = await _billingService.getProducts({productId});
        if (fetchedProducts.isNotEmpty) {
          _currentPurchaseContext = {
            'type': 'subscription',
            'productId': productId,
          };
          SharedPrefsService.saveString(
            'pending_purchase_type',
            'subscription',
          );
          SharedPrefsService.saveString(
            'pending_purchase_product_id',
            productId,
          );
          await _billingService.buyProduct(fetchedProducts.first);
        } else {
          Get.snackbar('Error', 'Subscription product not found in store.');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch subscription product.');
      }
    } catch (e) {
      debugPrint('Error initiating subscription purchase: $e');
      Get.snackbar('Error', 'An error occurred.');
    } finally {
      setLoading(false);
    }
  }

  Future<void> purchaseCircleJoin(String circleId) async {
    try {
      setLoading(true);
      final response = await _apiService.post(
        AppUrls.circleJoinPaymentIntent(circleId),
        {},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final platform = Platform.isAndroid ? 'google' : 'apple';
        final productId = data['data']['products'][platform]['productId'];

        final fetchedProducts = await _billingService.getProducts({productId});
        if (fetchedProducts.isNotEmpty) {
          _currentPurchaseContext = {
            'type': 'circle_join',
            'circleId': circleId,
            'productId': productId,
          };
          SharedPrefsService.saveString('pending_purchase_type', 'circle_join');
          SharedPrefsService.saveString('pending_purchase_circle_id', circleId);
          SharedPrefsService.saveString(
            'pending_purchase_product_id',
            productId,
          );
          await _billingService.buyProduct(fetchedProducts.first);
        } else {
          Get.snackbar('Error', 'Product not found in store.');
        }
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

  Future<void> purchaseVirtualTicket(String bookingId, String productId) async {
    try {
      setLoading(true);
      final fetchedProducts = await _billingService.getProducts({productId});
      if (fetchedProducts.isNotEmpty) {
        _currentPurchaseContext = {
          'type': 'virtual_event_ticket',
          'bookingId': bookingId,
          'productId': productId,
        };
        SharedPrefsService.saveString(
          'pending_purchase_type',
          'virtual_event_ticket',
        );
        SharedPrefsService.saveString('pending_purchase_booking_id', bookingId);
        SharedPrefsService.saveString('pending_purchase_product_id', productId);
        await _billingService.buyProduct(fetchedProducts.first);
      } else {
        Get.snackbar('Error', 'Ticket product not found in store.');
      }
    } catch (e) {
      debugPrint('Error purchasing virtual ticket: $e');
      Get.snackbar('Error', 'An unexpected error occurred.');
    } finally {
      setLoading(false);
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

        // Refresh Home Screen data
        try {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchHomeData();
          }
        } catch (e) {
          debugPrint("Error refreshing home data after purchase: $e");
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
      } else {
        body['appleTransactionId'] = purchaseDetails.purchaseID;
        // In some cases for Apple, you might need the receipt data
        body['receiptData'] =
            purchaseDetails.verificationData.serverVerificationData;
      }

      String url = AppUrls.kycVerifyPurchase; // Default

      String? type = SharedPrefsService.getString('pending_purchase_type');
      String? savedProductId = SharedPrefsService.getString(
        'pending_purchase_product_id',
      );

      if (type == null || savedProductId != purchaseDetails.productID) {
        if (purchaseDetails.productID.contains('subscription') ||
            purchaseDetails.productID == BillingConfig.subscriptionId) {
          type = 'subscription';
        } else if (purchaseDetails.productID.contains('circle.join')) {
          type = 'circle_join';
        } else {
          type = 'kyc';
        }
      }

      if (type == 'circle_join') {
        String? circleId = SharedPrefsService.getString(
          'pending_purchase_circle_id',
        );
        if (circleId != null && circleId.isNotEmpty) {
          url = AppUrls.circleJoinConfirm(circleId);
        } else {
          Get.snackbar('Error', 'Circle ID missing for verification.');
          return false;
        }
      } else if (type == 'virtual_event_ticket') {
        String? bookingId = SharedPrefsService.getString(
          'pending_purchase_booking_id',
        );
        if (bookingId != null && bookingId.isNotEmpty) {
          url = AppUrls.iapVerify;
          body['purpose'] = 'virtual-event-ticket';
          body['referenceId'] = bookingId;
        } else {
          Get.snackbar('Error', 'Booking ID missing for verification.');
          return false;
        }
      } else if (type == 'subscription') {
        url = AppUrls.iapVerify;
        body['purpose'] = 'host-pro-subscription';
      } else {
        url = AppUrls.kycVerifyPurchase;
      }

      final response = await _apiService.post(url, body);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        SharedPrefsService.delete('pending_purchase_type');
        SharedPrefsService.delete('pending_purchase_circle_id');
        SharedPrefsService.delete('pending_purchase_booking_id');
        SharedPrefsService.delete('pending_purchase_product_id');
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

  @override
  void onClose() {
    _billingService.dispose();
    super.onClose();
  }
}
