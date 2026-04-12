import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/social_icon_button.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

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
            const AuthTextField(
              label: "Email",
              hintText: "Email",
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(height: 20.h),
            const AuthTextField(
              label: "Password",
              hintText: "Password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            SizedBox(height: 20.h),
            const AuthTextField(
              label: "Confirm Password",
              hintText: "Password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
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
                      // Navigate to login
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
            GestureDetector(
              onTap: () => Get.to(() => const OtpVerificationScreen()),
              child: Container(
                height: 56.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
