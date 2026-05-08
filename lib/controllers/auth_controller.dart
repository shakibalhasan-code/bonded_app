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
import 'base_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends BaseController {
  final ApiService _apiService = ApiService();
  final SocialAuthService _socialAuthService = SocialAuthService();

  // Observable variables
  final RxBool isPasswordVisible = false.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

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
      final response = await _apiService.post(
        AppUrls.register,
        {
          "email": email,
          "password": password,
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
      final response = await _apiService.post(
        AppUrls.login,
        {
          "email": email,
          "password": password,
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
  Future<void> changePassword(String oldPassword, String newPassword) async {
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
        Get.snackbar('Success', data['message'] ?? 'Password changed successfully');
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
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

  // Social Login Methods
  Future<void> loginWithGoogle() async {
    try {
      setLoading(true);
      final credential = await _socialAuthService.signInWithGoogle();
      if (credential != null) {
        await _handleSocialLoginSuccess(credential, 'google');
      }
    } catch (e) {
      Get.snackbar('Error', 'Google Sign-In failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      setLoading(true);
      final credential = await _socialAuthService.signInWithFacebook();
      if (credential != null) {
        await _handleSocialLoginSuccess(credential, 'facebook');
      }
    } catch (e) {
      Get.snackbar('Error', 'Facebook Sign-In failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loginWithApple() async {
    try {
      setLoading(true);
      final credential = await _socialAuthService.signInWithApple();
      if (credential != null) {
        await _handleSocialLoginSuccess(credential, 'apple');
      }
    } catch (e) {
      Get.snackbar('Error', 'Apple Sign-In failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _handleSocialLoginSuccess(UserCredential credential, String provider) async {
    try {
      // Get Firebase ID token to send to backend
      final String? idToken = await credential.user?.getIdToken();
      if (idToken == null) {
        Get.snackbar('Error', 'Failed to get authentication token');
        return;
      }

      // Send Firebase token to your backend for verification & JWT issuance
      final response = await _apiService.post(
        AppUrls.socialLogin,
        {
          "idToken": idToken,
          "provider": provider,
          "email": credential.user?.email,
          "name": credential.user?.displayName,
          "photoUrl": credential.user?.photoURL,
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
        userData.value = authData['user'];

        // Initialize Socket
        Get.find<SocketService>().initSocket(token: accessToken);

        Get.snackbar('Success', 'Logged in with ${provider.capitalizeFirst}');

        // Navigate based on profile completion
        if (authData['isCompleteProfile'] == true) {
          Get.offAllNamed(AppRoutes.MAIN);
        } else {
          Get.offAllNamed(AppRoutes.PROFILE_BUILDING);
        }
      } else {
        Get.snackbar('Error', data['message'] ?? '${provider.capitalizeFirst} Sign-In failed');
      }
    } catch (e) {
      debugPrint('Social login backend error: $e');
      Get.snackbar('Error', 'Failed to complete ${provider.capitalizeFirst} Sign-In');
    }
  }
}
