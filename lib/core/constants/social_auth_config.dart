class SocialAuthConfig {
  // Google Configs
  static const String googleClientIdAndroid =
      "507580696837-qi7qdh8o9vkqifjolelru679q8b4b98h.apps.googleusercontent.com"; // Web Client ID from google-services.json
  static const String googleClientIdIos =
      "507580696837-dl810gsdcoqm6p6qq7j37d1rmdo0gbd4.apps.googleusercontent.com"; // iOS Client ID from google-services.json

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
