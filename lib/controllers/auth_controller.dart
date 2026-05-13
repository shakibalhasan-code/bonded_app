import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/shared_prefs_service.dart';
import '../core/constants/app_endpoints.dart';
import '../core/routes/app_routes.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../services/social_auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/social_auth_error_dialog.dart';
import 'base_controller.dart';

class AuthController extends BaseController {
  final ApiService _apiService = ApiService();
  final SocialAuthService _socialAuthService = SocialAuthService();
  final NotificationService _notificationService = Get.find<NotificationService>();

  // Observable variables
  final RxBool isPasswordVisible = false.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final Rxn<String> loadingProvider = Rxn<String>(); // 'google' | 'apple' | 'facebook'

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    // Auto-fetch profile if token exists
    fetchUserProfile();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Register
  Future<void> register(String email, String password) async {
    try {
      setLoading(true);
      final fcmToken = await _notificationService.getFcmToken();
      final response = await _apiService.post(
        AppUrls.register,
        {
          "email": email,
          "password": password,
          "loginProvider": "email",
          if (fcmToken != null) "fcmToken": fcmToken,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Get.snackbar('Success', data['message'] ?? 'Account created successfully');
        Get.toNamed(AppRoutes.VERIFICATION, arguments: {'email': email});
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to register');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      setLoading(true);
      final fcmToken = await _notificationService.getFcmToken();
      final response = await _apiService.post(
        AppUrls.login,
        {
          "email": email,
          "password": password,
          if (fcmToken != null) "fcmToken": fcmToken,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final authData = data['data'];
        final accessToken = authData['accessToken'];
        final refreshToken = authData['refreshToken'];

        // Save tokens and user ID
        await SharedPrefsService.saveString('accessToken', accessToken);
        await SharedPrefsService.saveString('refreshToken', refreshToken);
        if (authData['user'] != null && authData['user']['_id'] != null) {
          await SharedPrefsService.saveString('userId', authData['user']['_id']);
        }
        
        userData.value = authData['user'];
        currentUser.value = UserModel.fromJson(authData['user']);
        
        // Initialize Socket
        Get.find<SocketService>().initSocket(token: accessToken);
        
        Get.snackbar('Success', data['message'] ?? 'Login successful');
        Get.offAllNamed(AppRoutes.MAIN);
      } else {
        Get.snackbar('Error', data['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Resend OTP
  Future<void> resendOtp(String email, String type) async {
    try {
      setLoading(true);
      final response = await _apiService.post(
        AppUrls.resendOtp,
        {
          "email": email,
          "type": type,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Get.snackbar('Success', data['message'] ?? 'OTP sent successfully');
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Verify Account
  Future<void> verifyAccount(String email, String otp) async {
    try {
      setLoading(true);
      final response = await _apiService.post(
        AppUrls.verifyAccount,
        {
          "email": email,
          "otp": otp,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final authData = data['data'];
        final accessToken = authData['accessToken'];
        final refreshToken = authData['refreshToken'];
        
        // Save tokens and user ID
        await SharedPrefsService.saveString('accessToken', accessToken);
        if (refreshToken != null) {
          await SharedPrefsService.saveString('refreshToken', refreshToken);
        }
        if (authData['user'] != null && authData['user']['_id'] != null) {
          await SharedPrefsService.saveString('userId', authData['user']['_id']);
        }
        
        // Update user state
        currentUser.value = UserModel.fromJson(authData['user']);
        
        Get.snackbar('Success', data['message'] ?? 'Account verified successfully');
        
        // Initialize Socket
        Get.find<SocketService>().initSocket(token: accessToken);

        // Navigate based on profile completion
        if (authData['isCompleteProfile'] == true) {
          Get.offAllNamed(AppRoutes.MAIN);
        } else {
          Get.offAllNamed(AppRoutes.PROFILE_BUILDING);
        }
      } else {
        Get.snackbar('Error', data['message'] ?? 'Verification failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      setLoading(true);
      final response = await _apiService.post(
        AppUrls.forgotPassword,
        {
          "email": email,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Get.snackbar('Success', data['message'] ?? 'OTP sent to your email');
        Get.toNamed(AppRoutes.VERIFICATION, arguments: {'email': email, 'reason': 'forgot_password'});
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Verify Reset OTP
  Future<String?> verifyResetOtp(String email, String otp) async {
    try {
      setLoading(true);
      final response = await _apiService.post(
        AppUrls.verifyResetOtp,
        {
          "email": email,
          "otp": otp,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Get.snackbar('Success', data['message'] ?? 'OTP verified');
        return data['data']['resetToken'];
      } else {
        Get.snackbar('Error', data['message'] ?? 'Verification failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setLoading(false);
    }
    return null;
  }

  // Reset Password
  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      setLoading(true);
      final response = await _apiService.post(
        AppUrls.resetPassword,
        {
          "password": newPassword,
        },
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resetToken',
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Get.snackbar('Success', data['message'] ?? 'Password reset successful');
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Change Password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      setLoading(true);
      final token = SharedPrefsService.getString('accessToken');
      final response = await _apiService.post(
        AppUrls.changePassword,
        {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Get.snackbar('Success', data['message'] ?? 'Password changed successfully',
            backgroundColor: Colors.green.withOpacity(0.9),
            colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to change password',
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white);
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Refresh Access Token
  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = SharedPrefsService.getString('refreshToken');
      if (refreshToken == null) return;

      final response = await _apiService.post(
        AppUrls.refreshAccessToken,
        {
          "refreshToken": refreshToken,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final newAccessToken = data['data']['accessToken'];
        await SharedPrefsService.saveString('accessToken', newAccessToken);
      }
    } catch (e) {
      // Handle error silently or with a non-print logger
    }
  }

  // Fetch User Profile
  Future<void> fetchUserProfile() async {
    try {
      final token = SharedPrefsService.getString('accessToken');
      if (token == null) {
        debugPrint("No access token found, skipping profile fetch.");
        return;
      }
      
      setLoading(true);
      final response = await _apiService.get(
        AppUrls.getProfile,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        currentUser.value = UserModel.fromJson(data['data']);
        userData.value = data['data'];
        debugPrint("User profile fetched successfully.");
      } else {
        debugPrint("Failed to fetch user profile: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    } finally {
      setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await SharedPrefsService.clear();
    currentUser.value = null;
    userData.clear();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  // ──────────────────────────────────────────────
  // Social Login Methods
  // ──────────────────────────────────────────────

  Future<void> loginWithGoogle() async {
    try {
      loadingProvider.value = 'google';
      final result = await _socialAuthService.signInWithGoogle();
      if (result == null) {
        // null = cancelled by user OR idToken was null (see debug logs)
        debugPrint('AUTH_CONTROLLER: Google sign-in returned null result');
        return;
      }
      debugPrint('AUTH_CONTROLLER: Google sign-in success, calling backend...');
      await _sendSocialLoginToBackend(result);
    } catch (e) {
      SocialAuthErrorDialog.show('google');
    } finally {
      loadingProvider.value = null;
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      loadingProvider.value = 'facebook';
      final result = await _socialAuthService.signInWithFacebook();
      if (result != null) await _sendSocialLoginToBackend(result);
    } catch (e) {
      SocialAuthErrorDialog.show('facebook');
    } finally {
      loadingProvider.value = null;
    }
  }

  Future<void> loginWithApple() async {
    try {
      loadingProvider.value = 'apple';
      final result = await _socialAuthService.signInWithApple();
      if (result != null) await _sendSocialLoginToBackend(result);
    } catch (e) {
      SocialAuthErrorDialog.show('apple');
    } finally {
      loadingProvider.value = null;
    }
  }

  /// Builds the correct per-provider payload and calls POST /auth/social-login.
  /// v2 API:
  ///   Google  → { provider, email, fullName?, avatar? }
  ///   Apple   → { provider, email, fullName?, avatar: null }
  ///   Facebook → { provider, accessToken }
  Future<void> _sendSocialLoginToBackend(SocialAuthResult result) async {
    try {
      final Map<String, dynamic> payload = {'provider': result.provider};

      switch (result.provider) {
        case 'google':
        case 'apple':
          // Trust-based: backend accepts user info directly, no token verification
          if (result.email != null) payload['email'] = result.email;
          if (result.fullName != null && result.fullName!.isNotEmpty) {
            payload['fullName'] = result.fullName;
          }
          if (result.avatar != null) payload['avatar'] = result.avatar;
          break;
        case 'facebook':
          // Backend verifies this token against the Facebook Graph API
          payload['accessToken'] = result.accessToken;
          break;
      }

      final fcmToken = await _notificationService.getFcmToken();
      if (fcmToken != null) payload['fcmToken'] = fcmToken;

      debugPrint('SOCIAL_LOGIN: Sending payload to backend: ${payload.keys.toList()}');

      final response = await _apiService.post(AppUrls.socialLogin, payload);
      debugPrint('SOCIAL_LOGIN: Response status: ${response.statusCode}');
      debugPrint('SOCIAL_LOGIN: Response body: ${response.body}');
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final authData = data['data'];
        final accessToken = authData['accessToken'];
        final refreshToken = authData['refreshToken'];

        await SharedPrefsService.saveString('accessToken', accessToken);
        if (refreshToken != null) {
          await SharedPrefsService.saveString('refreshToken', refreshToken);
        }
        if (authData['user']?['_id'] != null) {
          await SharedPrefsService.saveString('userId', authData['user']['_id']);
        }

        currentUser.value = UserModel.fromJson(authData['user']);
        userData.value = authData['user'];

        Get.find<SocketService>().initSocket(token: accessToken);

        Get.snackbar('Success', 'Logged in with ${result.provider.capitalizeFirst}');

        if (authData['isCompleteProfile'] == true) {
          Get.offAllNamed(AppRoutes.MAIN);
        } else {
          Get.offAllNamed(AppRoutes.PROFILE_BUILDING);
        }
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? '${result.provider.capitalizeFirst} Sign-In failed',
        );
      }
    } catch (e) {
      debugPrint('Social login backend error: $e');
      Get.snackbar(
        'Error',
        'Failed to complete ${result.provider.capitalizeFirst} Sign-In',
      );
    }
  }
}
