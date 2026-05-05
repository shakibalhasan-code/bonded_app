import 'package:bonded_app/controllers/auth_controller.dart';
import 'package:bonded_app/widgets/auth/social_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/app_button.dart';

class SignupScreen extends GetView<AuthController> {
  const SignupScreen({super.key});

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
              "Create Your Account",
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Elevate your Bonded account with this App.",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.h),

            // Form Fields
            AuthTextField(
              label: "Email",
              hintText: "Email",
              prefixIcon: Icons.email_outlined,
              controller: controller.emailController,
            ),
            SizedBox(height: 20.h),
            AuthTextField(
              label: "Password",
              hintText: "Password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: controller.passwordController,
            ),
            SizedBox(height: 20.h),
            AuthTextField(
              label: "Confirm Password",
              hintText: "Password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: controller.confirmPasswordController,
            ),

            SizedBox(height: 24.h),

            // Login Link
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.clearControllers();
                      Get.offNamed(AppRoutes.LOGIN);
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    "Or Continue with",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            SizedBox(height: 32.h),

            // Social Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SocialIconButton(
                  iconPath: AppAssets.googleIcon,
                  onPressed: () {},
                ),
                SocialIconButton(
                  iconPath: AppAssets.facebookIcon,
                  onPressed: () {},
                ),
                SocialIconButton(
                  iconPath: AppAssets.appleIcon,
                  onPressed: () {},
                ),
              ],
            ),

            SizedBox(height: 60.h),

            // Signup Button
            Obx(
              () => AppButton(
                text: "Sign Up",
                isPrimary: true,
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (controller.emailController.text.isEmpty ||
                      controller.passwordController.text.isEmpty ||
                      controller.confirmPasswordController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill all fields');
                    return;
                  }
                  if (controller.passwordController.text !=
                      controller.confirmPasswordController.text) {
                    Get.snackbar('Error', 'Passwords do not match');
                    return;
                  }
                  controller.register(
                    controller.emailController.text,
                    controller.passwordController.text,
                  );
                },
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
