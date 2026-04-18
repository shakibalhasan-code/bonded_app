import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/profile_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none,
              title: "Notification",
              trailing: Obx(
                () => Switch(
                  value: controller.notificationsEnabled.value,
                  onChanged: (val) =>
                      controller.notificationsEnabled.value = val,
                  activeColor: AppColors.primary,
                ),
              ),
            ),
            _buildMenuItem(icon: Icons.lock_outline, title: "Change Password"),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: "Terms of Service",
            ),
            _buildMenuItem(icon: Icons.info_outline, title: "About Us"),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
            ),
            _buildMenuItem(icon: Icons.email_outlined, title: "Contact Us"),
            _buildMenuItem(icon: Icons.logout, title: "Logout"),
            _buildMenuItem(
              icon: Icons.no_accounts_outlined,
              title: "Disable Account",
            ),
            _buildMenuItem(
              icon: Icons.delete_outline,
              title: "Delete Account",
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? const Color(0xFF1B0B3B), size: 24.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: color ?? const Color(0xFF1B0B3B),
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xFF1B0B3B),
            size: 16.sp,
          ),
    );
  }
}
