import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/app_button.dart';

import '../../controllers/auth_controller.dart';

class ResetPasswordScreen extends GetView<AuthController> {
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
            AuthTextField(
              label: "New Password",
              hintText: "Enter new password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: controller.passwordController,
            ),
            SizedBox(height: 20.h),
            
            // Confirm Password Field
            AuthTextField(
              label: "Confirm Password",
              hintText: "Confirm new password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: controller.confirmPasswordController,
            ),

            SizedBox(height: 48.h),

            // Reset Password Button
            Obx(() => AppButton(
              text: "Reset Password",
              isPrimary: true,
              isLoading: controller.isLoading.value,
              onPressed: () {
                if (controller.passwordController.text.isEmpty || 
                    controller.confirmPasswordController.text.isEmpty) {
                  Get.snackbar('Error', 'Please fill all fields');
                  return;
                }
                if (controller.passwordController.text != controller.confirmPasswordController.text) {
                  Get.snackbar('Error', 'Passwords do not match');
                  return;
                }
                
                final args = Get.arguments as Map<String, dynamic>?;
                final resetToken = args?['resetToken'] ?? '';
                
                controller.resetPassword(resetToken, controller.passwordController.text);
              },
            )),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
