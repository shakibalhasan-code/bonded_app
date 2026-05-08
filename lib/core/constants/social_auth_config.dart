class SocialAuthConfig {
  // Google Configs
  static const String googleClientIdAndroid =
      "73661093102-gt0pbuclrdh62nin2rl5f6ffg29q3r12.apps.googleusercontent.com"; // Add your web client ID if needed for certain flows
  static const String googleClientIdIos =
      "73661093102-lv4kcna9bh0g6usgas83usb1kqbult3e.apps.googleusercontent.com"; // Add your web client ID if needed for certain flows

  // Facebook Configs
  static const String facebookAppId = "";

  // Apple Configs
  static const String appleServiceId = "com.sirikay.bonded.auth";
  static const String appleRedirectUri =
      "https://bondedapp-cb184.firebaseapp.com/__/auth/handler";

  // Essential Flags
  static const bool enableGoogle = true;
  static const bool enableFacebook = false;
  static const bool enableApple = true;
}
