import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/profile_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          children: [
            // User Info
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
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
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
                              "Pro",
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
                  Text(
                    "Andrew Ainsley",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "andrew_ainsley@gmail.com",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Subscription Card
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
                            "Pro Tier",
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B0B3B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "\$14.99/month",
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

            // Settings List
            _buildMenuItem(
              title: "Edit Profile",
              onTap: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
            ),
            _buildMenuItem(
              title: "Notification",
              trailing: Obx(
                () => Switch(
                  value: controller.notificationsEnabled.value,
                  onChanged: (val) =>
                      controller.notificationsEnabled.value = val,
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
                onConfirm: () => Get.offAllNamed(AppRoutes.WELCOME),
              ),
            ),
            _buildMenuItem(
              title: "Disable Account",
              onTap: () => _showDisableConfirmationDialog(),
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
  }

  void _showDisableConfirmationDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.primary,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Warning!",
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Are you sure? You want to disable your account. You can Re-enable your account any time.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.snackbar("Status", "Account disabled");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Disable",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(message, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: Text(
              "Confirm",
              style: GoogleFonts.inter(
                color: title.contains("Delete")
                    ? Colors.red
                    : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        color: Colors.transparent,
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
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF1B0B3B),
                  size: 16.sp,
                ),
          ],
        ),
      ),
    );
  }
}
