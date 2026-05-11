import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'ios_iap_service.dart';

/// Cross-platform billing service.
///
/// * **iOS** — delegates entirely to [IosIapService.instance] (StoreKit /
///   App Store).  Only one stream listener is active; no double-processing.
/// * **Android** — manages the [InAppPurchase] stream directly (Google Play
///   Billing).
///
/// Callbacks:
///   [onPurchaseUpdate] — called with a [PurchaseDetails] on Android
///                        success / restore.
///   [onError]          — called with a human-readable error message.
class BillingService {
  final InAppPurchase _iap = InAppPurchase.instance;

  // Android-only stream subscription.  null on iOS.
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Android purchase-stream callback (used by BillingController).
  Function(PurchaseDetails)? onPurchaseUpdate;

  /// Error callback for both platforms.
  Function(String)? onError;

  // ──────────────────────────────────────────────────────────────────────────
  // Constructor
  // ──────────────────────────────────────────────────────────────────────────

  BillingService() {
    if (!kIsWeb && Platform.isIOS) {
      // iOS: IosIapService.instance owns the stream subscription.
      // Initialise it eagerly so the App Store connection is ready before
      // the first purchase call.
      IosIapService.instance.initialize();
    } else {
      // Android: manage the purchase stream here.
      _subscription = _iap.purchaseStream.listen(
        _onAndroidPurchaseUpdate,
        onError: (err) => onError?.call(err.toString()),
        onDone: () => _subscription?.cancel(),
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Store availability
  // ──────────────────────────────────────────────────────────────────────────

  Future<bool> isAvailable() async => _iap.isAvailable();

  // ──────────────────────────────────────────────────────────────────────────
  // Product queries
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<ProductDetails>> getProducts(Set<String> ids) async {
    final response = await _iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[BillingService] Products not found: ${response.notFoundIDs}');
    }
    return response.productDetails;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // iOS purchase  (delegates to IosIapService singleton)
  // ──────────────────────────────────────────────────────────────────────────

  /// Purchases [productId] via [IosIapService] on iOS.
  ///
  /// [productId]    — App Store Connect product ID (dynamic, resolved at
  ///                  runtime from the backend or any other source).
  /// [isConsumable] — `true` for coin/credit products; `false` for
  ///                  subscriptions / non-consumables (default).
  ///
  /// Returns an [IapResult] you can verify on your backend.
  /// On Android / web returns immediately with `success: false`.
  Future<IapResult> buyWithIosService({
    required String productId,
    bool isConsumable = false,
    void Function(IapResult)? onSuccess,
    void Function(String)? onIosError,
    VoidCallback? onPending,
  }) async {
    if (kIsWeb || !Platform.isIOS) {
      debugPrint('[BillingService] buyWithIosService called on non-iOS – noop.');
      return const IapResult(
        success: false,
        error: 'iOS-only method called on non-iOS platform.',
      );
    }

    final svc = IosIapService.instance;
    // Overwrite callbacks for this purchase; callers set them per invocation.
    svc.onPurchaseSuccess = onSuccess;
    svc.onError = onIosError ?? (msg) => onError?.call(msg);
    svc.onPurchasePending = onPending;

    return svc.purchase(productId, isConsumable: isConsumable);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Android purchase  (generic path used by BillingController)
  // ──────────────────────────────────────────────────────────────────────────

  /// Initiates a non-consumable / subscription purchase on Android.
  ///
  /// The result is delivered via [onPurchaseUpdate].
  Future<void> buyProduct(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Restore
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    if (!kIsWeb && Platform.isIOS) {
      await IosIapService.instance.restorePurchases();
    } else {
      await _iap.restorePurchases();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Android stream handler
  // ──────────────────────────────────────────────────────────────────────────

  void _onAndroidPurchaseUpdate(List<PurchaseDetails> list) {
    for (final pd in list) {
      if (pd.status == PurchaseStatus.pending) {
        // UI handles loading state via controller.
      } else {
        if (pd.status == PurchaseStatus.error) {
          onError?.call(pd.error?.message ?? 'Purchase error');
        } else if (pd.status == PurchaseStatus.purchased ||
            pd.status == PurchaseStatus.restored) {
          onPurchaseUpdate?.call(pd);
        }

        if (pd.pendingCompletePurchase) {
          _iap.completePurchase(pd);
        }
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dispose
  // ──────────────────────────────────────────────────────────────────────────

  void dispose() {
    _subscription?.cancel();
    if (!kIsWeb && Platform.isIOS) {
      IosIapService.instance.dispose();
    }
  }
}
