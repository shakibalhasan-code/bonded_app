import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants/billing_config.dart';
import '../widgets/billing/ios_payment_sheet.dart';

/// Result returned by every [IosIapService] purchase / restore operation.
class IapResult {
  final bool success;
  final String? productId;
  final String? transactionId;

  /// JWS / base64-encoded receipt — send this to your backend for verification.
  final String? serverVerificationData;

  /// Human-readable error when [success] is false.
  final String? error;

  const IapResult({
    required this.success,
    this.productId,
    this.transactionId,
    this.serverVerificationData,
    this.error,
  });

  @override
  String toString() =>
      'IapResult(success: $success, productId: $productId, '
      'txId: $transactionId, error: $error)';
}

/// iOS In-App Purchase service — singleton, OS-aware.
///
/// All public methods are **no-ops on Android / web** and return immediately
/// with `success: false` (or empty lists / null). You never need to guard
/// call-sites with `Platform.isIOS`.
///
/// The product ID is passed **per call**, so a single instance handles any
/// number of dynamically resolved product identifiers.
///
/// ---
/// Quick-start
/// ```dart
/// // One-time init (app start or controller onInit):
/// await IosIapService.instance.initialize();
///
/// // Hook up callbacks (optional):
/// IosIapService.instance.onPurchaseSuccess = (r) => verifyWithBackend(r);
/// IosIapService.instance.onError           = (msg) => showSnackbar(msg);
///
/// // Purchase any product:
/// final result = await IosIapService.instance.purchase('com.example.monthly');
///
/// // Restore previous purchases:
/// await IosIapService.instance.restorePurchases();
///
/// // Cleanup (controller onClose):
/// IosIapService.instance.dispose();
/// ```
class IosIapService {
  // ──────────────────────────────────────────────────────────────────────────
  // Singleton
  // ──────────────────────────────────────────────────────────────────────────

  static final IosIapService instance = IosIapService._();
  IosIapService._();

  // ──────────────────────────────────────────────────────────────────────────
  // Internal state
  // ──────────────────────────────────────────────────────────────────────────

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _initialized = false;

  /// Pending completers keyed by productId.
  /// Allows multiple concurrent purchases (e.g. one-time + restore).
  final Map<String, Completer<IapResult>> _pending = {};

  // ──────────────────────────────────────────────────────────────────────────
  // Public callbacks  (set before purchasing)
  // ──────────────────────────────────────────────────────────────────────────

  /// Fires on every successful purchase or restore.
  void Function(IapResult result)? onPurchaseSuccess;

  /// Fires on any purchase-stream error.
  void Function(String message)? onError;

  /// Fires while a purchase is pending (bank / parental approval etc.).
  VoidCallback? onPurchasePending;

  // ──────────────────────────────────────────────────────────────────────────
  // Platform guard
  // ──────────────────────────────────────────────────────────────────────────

  bool get _isIos => !kIsWeb && Platform.isIOS;

  // ──────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────────────────

  /// Connects to the App Store and starts the purchase-stream listener.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops once
  /// successfully initialised.
  ///
  /// Returns `false` on non-iOS or when the App Store is unreachable.
  Future<bool> initialize() async {
    if (!_isIos) {
      debugPrint('[IosIapService] Skipped – not iOS.');
      return false;
    }
    if (_initialized) return true;

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('[IosIapService] App Store not available.');
      return false;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object err) {
        final msg = err.toString();
        debugPrint('[IosIapService] Stream error: $msg');
        onError?.call(msg);
        // Fail all pending purchases so callers are not left waiting.
        for (final c in _pending.values) {
          if (!c.isCompleted) {
            c.complete(IapResult(success: false, error: msg));
          }
        }
        _pending.clear();
      },
      onDone: () => _subscription?.cancel(),
    );

    _initialized = true;
    debugPrint('[IosIapService] Initialized.');
    return true;
  }

  /// Cancels the purchase-stream listener.  Call in your controller's
  /// `onClose`.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
    _pending.clear();
    debugPrint('[IosIapService] Disposed.');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Store availability
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns `true` when the App Store is reachable on the current device.
  Future<bool> isAvailable() async {
    if (!_isIos) return false;
    return _iap.isAvailable();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Product queries
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetches a single product from App Store Connect.
  ///
  /// Returns `null` when the product is not found, the platform is not iOS,
  /// or debug mode is active (price is supplied by [BillingConfig.debugPrice]).
  Future<ProductDetails?> fetchProduct(String productId) async {
    if (BillingConfig.isIosDebug) return null;
    if (!_isIos) return null;

    final res = await _iap.queryProductDetails({productId});
    if (res.notFoundIDs.contains(productId)) {
      debugPrint('[IosIapService] Product not found in App Store: $productId');
    }
    return res.productDetails.isEmpty ? null : res.productDetails.first;
  }

  /// Fetches multiple products in a single App Store query.
  ///
  /// Missing products are logged; the returned list contains only those found.
  Future<List<ProductDetails>> fetchProducts(Set<String> productIds) async {
    if (!_isIos) return [];

    final res = await _iap.queryProductDetails(productIds);
    if (res.notFoundIDs.isNotEmpty) {
      debugPrint(
        '[IosIapService] Products not found in App Store: ${res.notFoundIDs}',
      );
    }
    return res.productDetails;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Purchase
  // ──────────────────────────────────────────────────────────────────────────

  /// Initiates a purchase for [productId] on the App Store.
  ///
  /// [productId]    — App Store Connect product identifier
  ///                  (e.g. `com.yourapp.premium_monthly`). Resolved
  ///                  dynamically — pass any valid ID at runtime.
  /// [isConsumable] — `true` for coin / credit products;
  ///                  `false` for subscriptions and non-consumables (default).
  ///
  /// Returns an [IapResult] when the flow completes.  On success,
  /// [IapResult.serverVerificationData] holds the receipt to send to your
  /// backend.
  ///
  /// On non-iOS platforms returns immediately with `success: false`.
  Future<IapResult> purchase(
    String productId, {
    bool isConsumable = false,
  }) async {
    // Debug mode: show mock iOS sheet on any platform, no real store needed.
    if (BillingConfig.isIosDebug) {
      return _mockPurchase(productId, isConsumable: isConsumable);
    }

    if (!_isIos) {
      return const IapResult(
        success: false,
        error: 'iOS-only purchase attempted on non-iOS platform.',
      );
    }

    // Auto-init so callers don't have to call initialize() explicitly.
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) {
        return const IapResult(
          success: false,
          error: 'App Store not available or initialisation failed.',
        );
      }
    }

    final product = await fetchProduct(productId);
    if (product == null) {
      final err = 'Product "$productId" not found in App Store.';
      onError?.call(err);
      return IapResult(success: false, error: err);
    }

    // Replace any stale completer for this product.
    final existing = _pending[productId];
    if (existing != null && !existing.isCompleted) {
      existing.complete(const IapResult(
        success: false,
        error: 'Replaced by a new purchase request for the same product.',
      ));
    }
    _pending[productId] = Completer<IapResult>();

    final param = PurchaseParam(productDetails: product);
    try {
      if (isConsumable) {
        await _iap.buyConsumable(purchaseParam: param);
      } else {
        await _iap.buyNonConsumable(purchaseParam: param);
      }
    } catch (e) {
      final err = 'Failed to initiate purchase for "$productId": $e';
      debugPrint('[IosIapService] $err');
      onError?.call(err);
      _pending.remove(productId);
      return IapResult(success: false, error: err);
    }

    // Wait for the stream to deliver the result.
    return _pending[productId]!.future;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Restore
  // ──────────────────────────────────────────────────────────────────────────

  /// Restores previous purchases (required by App Store guidelines).
  ///
  /// Restored transactions are delivered via [onPurchaseSuccess].
  Future<void> restorePurchases() async {
    if (BillingConfig.isIosDebug) return; // nothing to restore in debug mode
    if (!_isIos) return;
    if (!_initialized) await initialize();
    await _iap.restorePurchases();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Debug mock purchase
  // ──────────────────────────────────────────────────────────────────────────

  /// Shows an iOS-style mock payment sheet and resolves with a fake
  /// [IapResult].  Used when [BillingConfig.isIosDebug] is `true`.
  Future<IapResult> _mockPurchase(
    String productId, {
    bool isConsumable = false,
  }) async {
    final completer = Completer<IapResult>();

    final isSubscription = productId == BillingConfig.subscriptionId ||
        productId.contains('subscription') ||
        productId.contains('monthly') ||
        productId.contains('yearly');

    Get.bottomSheet(
      IosPaymentSheet(
        productId: productId,
        displayName: BillingConfig.debugDisplayName(productId),
        price: BillingConfig.debugPrice(productId),
        isSubscription: isSubscription,
        onConfirm: () {
          if (Get.isBottomSheetOpen ?? false) Get.back();
          final result = IapResult(
            success: true,
            productId: productId,
            transactionId: BillingConfig.mockTransactionId(),
            serverVerificationData:
                'mock_receipt_${DateTime.now().millisecondsSinceEpoch}',
          );
          onPurchaseSuccess?.call(result);
          if (!completer.isCompleted) completer.complete(result);
        },
        onCancel: () {
          if (Get.isBottomSheetOpen ?? false) Get.back();
          if (!completer.isCompleted) {
            completer.complete(IapResult(
              success: false,
              productId: productId,
              error: 'Purchase cancelled by user.',
            ));
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    ).then((_) {
      // If the sheet is closed (e.g. dragged down) without confirm/cancel calling complete
      if (!completer.isCompleted) {
        completer.complete(IapResult(
          success: false,
          productId: productId,
          error: 'Purchase cancelled by user.',
        ));
      }
    });

    return completer.future;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stream processing
  // ──────────────────────────────────────────────────────────────────────────

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      _process(p);
    }
  }

  Future<void> _process(PurchaseDetails p) async {
    debugPrint(
      '[IosIapService] productId: ${p.productID} | status: ${p.status}',
    );

    switch (p.status) {
      case PurchaseStatus.pending:
        onPurchasePending?.call();

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Complete the transaction on the App Store side.
        if (p.pendingCompletePurchase) await _iap.completePurchase(p);

        final result = IapResult(
          success: true,
          productId: p.productID,
          transactionId: p.purchaseID,
          serverVerificationData: p.verificationData.serverVerificationData,
        );
        onPurchaseSuccess?.call(result);
        _complete(p.productID, result);

      case PurchaseStatus.error:
        if (p.pendingCompletePurchase) await _iap.completePurchase(p);

        final msg = p.error?.message ?? 'Unknown purchase error';
        debugPrint('[IosIapService] Error: $msg');
        onError?.call(msg);
        _complete(
          p.productID,
          IapResult(success: false, productId: p.productID, error: msg),
        );

      case PurchaseStatus.canceled:
        _complete(
          p.productID,
          IapResult(
            success: false,
            productId: p.productID,
            error: 'Purchase cancelled by user.',
          ),
        );
    }
  }

  void _complete(String productId, IapResult result) {
    final c = _pending.remove(productId);
    if (c != null && !c.isCompleted) c.complete(result);
  }
}
