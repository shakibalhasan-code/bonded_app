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

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({Key? key}) : super(key: key);

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
              "Login to Your Account",
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Welcome back! Please enter your details.",
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

            SizedBox(height: 12.h),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Signup Link
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.offNamed(AppRoutes.SIGNUP),
                    child: Text(
                      "Sign Up",
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

            // Login Button
            Obx(
              () => AppButton(
                text: "Login",
                isPrimary: true,
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (controller.emailController.text.isEmpty ||
                      controller.passwordController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill all fields');
                    return;
                  }
                  controller.login(
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
