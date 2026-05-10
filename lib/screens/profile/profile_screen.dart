import 'package:bonded_app/controllers/auth_controller.dart';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/profile_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: Obx(() {
        final user = authController.currentUser.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => authController.fetchUserProfile(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              children: [
                /// User Info
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  AppUrls.imageUrl(user.avatar),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  user.subscriptionTier.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.fullName ?? user.username ?? "User",
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B0B3B),
                            ),
                          ),
                          if (user.selfieVerification == 'verified') ...[
                            SizedBox(width: 5.w),
                            const Icon(
                              Icons.verified,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.email,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                /// Subscription Card
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.SUBSCRIPTION_PLAN),
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: AppColors.primary,
                          size: 40.sp,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user.subscriptionTier.capitalizeFirst}",
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B0B3B),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                user.subscriptionTier == 'free'
                                    ? "Free Plan"
                                    : "Premium Plan",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                /// Menu Items
                _buildMenuItem(
                  title: "Edit Profile",
                  onTap: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                ),
                _buildMenuItem(
                  title: "Verify Identity",
                  onTap: () => Get.toNamed(AppRoutes.KYC_DOCUMENT),
                ),
                _buildMenuItem(
                  title: "Notification",
                  trailing: Obx(
                    () => Switch(
                      value: controller.notificationsEnabled.value,
                      onChanged: (val) =>
                          controller.updatePreferences(notifications: val),
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                _buildMenuItem(
                  title: "Change Password",
                  onTap: () => Get.toNamed(AppRoutes.SECURITY),
                ),
                _buildMenuItem(
                  title: "Terms of Service",
                  onTap: () => Get.toNamed(AppRoutes.TERMS_OF_SERVICE),
                ),
                _buildMenuItem(
                  title: "About Us",
                  onTap: () => Get.toNamed(AppRoutes.ABOUT_US),
                ),
                _buildMenuItem(
                  title: "Privacy Policy",
                  onTap: () => Get.toNamed(AppRoutes.PRIVACY_POLICY),
                ),
                _buildMenuItem(
                  title: "Contact Us",
                  onTap: () => Get.toNamed(AppRoutes.CONTACT_US),
                ),
                _buildMenuItem(
                  title: "Logout",
                  onTap: () => _showConfirmationDialog(
                    title: "Logout",
                    message: "Are you sure you want to log out?",
                    onConfirm: () => authController.logout(),
                  ),
                ),

                _buildMenuItem(
                  title: "Delete Account",
                  color: Colors.red,
                  onTap: () => Get.toNamed(AppRoutes.DELETE_ACCOUNT),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Common Dialog
  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  /// Menu Item Widget
  Widget _buildMenuItem({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: color ?? const Color(0xFF1B0B3B),
              ),
            ),
            trailing ?? Icon(Icons.arrow_forward_ios, size: 16.sp),
          ],
        ),
      ),
    );
  }
}
