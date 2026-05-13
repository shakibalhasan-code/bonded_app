import 'dart:io';

import 'package:flutter/foundation.dart';

/// Central store for all In-App Purchase product identifiers.
///
/// Two layers:
///   1. **Static fallbacks** — compile-time defaults used when the backend
///      has not provided overrides yet (or when offline).
///   2. **Runtime overrides** — populated by calling [BillingConfig.configure]
///      with data from your backend.  Getters always prefer the runtime value
///      over the static fallback.
///
/// ---
/// Set IDs from backend (e.g. in BillingController.loadProducts):
/// ```dart
/// BillingConfig.configure(
///   kycVerificationId: data['kyc_product_id'],
///   subscriptionId:    data['subscription_product_id'],
/// );
/// ```
///
/// Read anywhere:
/// ```dart
/// final id = BillingConfig.kycVerificationId;   // platform-aware, runtime-first
/// final all = BillingConfig.allProductIds;       // full set for store query
/// ```
///
/// Reset to fallbacks (e.g. on logout):
/// ```dart
/// BillingConfig.reset();
/// ```
class BillingConfig {
  BillingConfig._(); // static-only class

  // ──────────────────────────────────────────────────────────────────────────
  // Feature flag
  // ──────────────────────────────────────────────────────────────────────────

  static const bool isBillingEnabled = true;

  /// When `true`, all IAP calls are intercepted and a mock payment
  /// sheet is shown instead of hitting the real App Store / Google Play.
  ///
  /// Set to `false` before submitting to App Review / production release.
  static const bool useTestingMode = true;

  // ──────────────────────────────────────────────────────────────────────────
  // Debug helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Human-readable product name for the mock payment sheet.
  static String debugDisplayName(String productId) {
    switch (productId) {
      case _iosSubscriptionDefault:
      case _androidSubscriptionDefault:
        return 'Host Pro Monthly';
      case _iosKycDefault:
      case _androidKycDefault:
        return 'Creator Verification';
      default:
        // e.g. "vp10" → "Vp10",  "circle.join.premium" → "Circle Join Premium"
        return productId
            .replaceAll(RegExp(r'[._]'), ' ')
            .split(' ')
            .map(
              (w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}',
            )
            .join(' ');
    }
  }

  /// Mock price shown in the debug payment sheet.
  static String debugPrice(String productId) {
    if (productId == subscriptionId) {
      return r'$19.99';
    }
    if (productId == kycVerificationId) {
      return r'$9.99';
    }
    // Default fallback for dynamic IDs (tickets, etc)
    return r'$19.99';
  }

  /// Generates a unique mock transaction ID.
  static String mockTransactionId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = (1000 + (DateTime.now().microsecond % 9000));
    return 'txn_${now}_$random';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Static fallbacks  (compile-time defaults)
  // ──────────────────────────────────────────────────────────────────────────

  // Android — Google Play
  static const String _androidKycDefault = 'kyc_verification_fee';
  static const String _androidSubscriptionDefault = 'monthly_subscription_plan';

  // iOS — App Store Connect
  static const String _iosKycDefault = 'kyconetime';
  static const String _iosSubscriptionDefault = 'hostpromonthly';

  // ──────────────────────────────────────────────────────────────────────────
  // Runtime overrides  (set via configure())
  // ──────────────────────────────────────────────────────────────────────────

  static String? _iosKycOverride;
  static String? _androidKycOverride;
  static String? _iosSubscriptionOverride;
  static String? _androidSubscriptionOverride;

  // ──────────────────────────────────────────────────────────────────────────
  // configure() — call once after loading products from your backend
  // ──────────────────────────────────────────────────────────────────────────

  /// Updates runtime overrides from backend-supplied values.
  ///
  /// Pass only the fields you received; `null` parameters leave the
  /// existing override (or fallback) unchanged.
  ///
  /// Typically called inside `BillingController.loadProducts()` after a
  /// successful API response.
  static void configure({
    String? iosKycVerificationId,
    String? androidKycVerificationId,
    String? iosSubscriptionId,
    String? androidSubscriptionId,
  }) {
    if (iosKycVerificationId != null) _iosKycOverride = iosKycVerificationId;
    if (androidKycVerificationId != null)
      _androidKycOverride = androidKycVerificationId;
    if (iosSubscriptionId != null) _iosSubscriptionOverride = iosSubscriptionId;
    if (androidSubscriptionId != null)
      _androidSubscriptionOverride = androidSubscriptionId;

    debugPrint(
      '[BillingConfig] Updated — kycId: ${kycVerificationId} | subId: $subscriptionId',
    );
  }

  /// Clears all runtime overrides, reverting to compile-time fallbacks.
  static void reset() {
    _iosKycOverride = null;
    _androidKycOverride = null;
    _iosSubscriptionOverride = null;
    _androidSubscriptionOverride = null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Platform-aware getters  (runtime override → static fallback)
  // ──────────────────────────────────────────────────────────────────────────

  static bool get _isIos => !kIsWeb && Platform.isIOS;

  /// Product ID for KYC verification on the current platform.
  static String get kycVerificationId {
    if (_isIos) return _iosKycOverride ?? _iosKycDefault;
    return _androidKycOverride ?? _androidKycDefault;
  }

  /// Product ID for the pro subscription on the current platform.
  static String get subscriptionId {
    if (_isIos) return _iosSubscriptionOverride ?? _iosSubscriptionDefault;
    return _androidSubscriptionOverride ?? _androidSubscriptionDefault;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Bulk helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// All known fixed product IDs for the current platform.
  ///
  /// Use this to pre-fetch product details from the store.  Dynamic IDs
  /// (circle join, event tickets) are resolved per-request from the backend
  /// and do not belong here.
  static Set<String> get allProductIds => {kycVerificationId, subscriptionId};

  /// Exposes all current IDs for debugging / logging.
  static Map<String, String> get debugMap => {
    'kycVerificationId': kycVerificationId,
    'subscriptionId': subscriptionId,
  };
}
