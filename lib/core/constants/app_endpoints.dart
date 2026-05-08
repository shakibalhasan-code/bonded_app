class AppUrls {
  static const String baseUrl =
      'https://nwqs97k3-5002.asse.devtunnels.ms/api/v1';
  static const String socket = 'https://nwqs97k3-5002.asse.devtunnels.ms';

  static const String assetsBase = 'https://nwqs97k3-5002.asse.devtunnels.ms';

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
  static const String socialLogin = '/auth/social-login';

  // User Endpoints
  static const String userProfile = '/user/profile';
  static const String getProfile = '/user/me';
  static const String updateProfile = '/user/me';
  static const String updateAvatar = '/user/me/avatar';
  static const String getInterests = '/interests';
  static const String circles = '/circles';
  static const String events = '/events';
  static const String myEvents = '/events/me';
  static const String stripeStatus = '/stripe-connect/me/status';
  static const String stripeOnboard = '/stripe-connect/me';
  static const String myWallet = '/wallet/me';
  static String bookEvent(String id) => '/bookings/events/$id';
  static String eventHighlights(String eventId) =>
      '/events/$eventId/highlights';
  static const String publicHighlights = '/events/public/highlights';
  static String circleHighlights(String circleId) =>
      '/circles/$circleId/highlights';
  static String highlightDetails(String highlightId) =>
      '/events/highlights/$highlightId';

  // Billing & Store Endpoints
  static const String storeProducts = '/store-products';
  static const String verifyPurchase = '/kyc/me/verification/verify-purchase';

  // Bond Endpoints
  static const String nearbyBonds = '/bonds/nearby';
  static const String incomingRequests = '/bonds/requests/incoming';
  static const String outgoingRequests = '/bonds/requests/outgoing';
  static const String myBonds = '/bonds/connections';
  static const String bondRequests = '/bonds/requests';
  static const String bonds = '/bonds';

  // Chat Endpoints
  static const String directChat = '/chat/direct'; // POST /chat/direct/:userId
  static const String conversations = '/chat/conversations';
  static String conversationMessages(String id) =>
      '/chat/conversations/$id/messages';
  // Circle Feed Endpoints
  static String circleFeed(String circleId) => '/circles/$circleId/feed';
  static String reactPost(String postId) => '/circles/posts/$postId/react';
  static String commentPost(String circleId, String postId) =>
      '/circles/$circleId/posts/$postId/comments';
  static String sharePost(String postId) => '/circles/posts/$postId/share';
  static String circleMembers(String circleId) => '/circles/$circleId/members';
  static String circleEvents(String circleId) => '/circles/$circleId/events';
  static String joinCircle(String circleId) => '/circles/$circleId/join';

  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://i.pravatar.cc/150';
    if (path.startsWith('http')) return path;
    
    // Normalize path by removing leading slash if present
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return '$assetsBase/$normalizedPath';
  }
}
