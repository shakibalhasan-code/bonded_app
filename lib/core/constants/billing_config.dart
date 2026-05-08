import 'dart:io';

class BillingConfig {
  // Flag to enable/disable billing system
  static const bool isBillingEnabled = true;

  // Product IDs for Google Play (Android)
  static const String androidKycVerificationId = 'kyc_verification_fee';
  static const String androidSubscriptionId = 'monthly_subscription_plan';

  // Product IDs for Apple App Store (iOS)
  static const String iosKycVerificationId = 'com.bonded.app.kyc_verification';
  static const String iosSubscriptionId = 'com.bonded.app.monthly_subscription';

  // Helper method to get Product ID based on platform
  static String get kycVerificationId {
    return Platform.isAndroid ? androidKycVerificationId : iosKycVerificationId;
  }

  static String get subscriptionId {
    return Platform.isAndroid ? androidSubscriptionId : iosSubscriptionId;
  }

  // List of all product IDs to load
  static Set<String> get allProductIds => {
    kycVerificationId,
    subscriptionId,
  };
}
