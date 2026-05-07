class SocialAuthConfig {
  // Google Configs
  static const String googleClientId = ""; // Add your web client ID if needed for certain flows
  
  // Facebook Configs
  static const String facebookAppId = "";
  
  // Apple Configs
  static const String appleServiceId = "";
  static const String appleRedirectUri = "https://your-firebase-project.firebaseapp.com/__/auth/handler";

  // Essential Flags
  static const bool enableGoogle = true;
  static const bool enableFacebook = true;
  static const bool enableApple = true;
}
