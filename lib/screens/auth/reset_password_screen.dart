import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/app_button.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHeading),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              "Reset Password",
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Create a new password for your account.",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.h),

            // New Password Field
            const AuthTextField(
              label: "New Password",
              hintText: "Enter new password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            SizedBox(height: 20.h),
            
            // Confirm Password Field
            const AuthTextField(
              label: "Confirm Password",
              hintText: "Confirm new password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),

            SizedBox(height: 48.h),

            // Reset Password Button
            AppButton(
              text: "Reset Password",
              isPrimary: true,
              onPressed: () {
                // Show success dialog or snackbar and then go to login
                Get.snackbar(
                  "Success",
                  "Password reset successfully",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                Get.offAllNamed(AppRoutes.LOGIN);
              },
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
