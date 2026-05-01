class AppUrls {
  static const String baseUrl = 'https://nwqs97k3-5002.asse.devtunnels.ms/api/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String resendOtp = '/auth/resend-otp';
  static const String verifyAccount = '/auth/verify-account';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String refreshAccessToken = '/auth/refresh-access-token';

  // User Endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/me';
  static const String updateAvatar = '/user/me/avatar';
  static const String getInterests = '/interests';
  static const String circles = '/circles';
}
