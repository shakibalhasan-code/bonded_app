class SocialAuthConfig {
  // Google Configs
  static const String googleClientIdAndroid =
      "73661093102-gt0pbuclrdh62nin2rl5f6ffg29q3r12.apps.googleusercontent.com"; // Web Client ID from google-services.json
  static const String googleClientIdIos =
      "73661093102-lv4kcna9bh0g6usgas83usb1kqbult3e.apps.googleusercontent.com"; // iOS Client ID from google-services.json

  // Facebook Configs
  static const String facebookAppId = "";

  // Apple Configs
  static const String appleServiceId = "com.sirikay.bonded.auth";
  static const String appleRedirectUri =
      "https://bondedapp-cb184.firebaseapp.com/__/auth/handler";

  // Essential Flags
  static const bool enableGoogle = true;
  static const bool enableFacebook = true;
  static const bool enableApple = true;
}
