import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/onboarding/onboarding_widgets.dart';
import '../../widgets/auth/social_auth_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // App Logo
              SvgPicture.asset(
                AppAssets.appLogo,
                height: 140.h,
                width: 140.w,
              ),

              const Spacer(),

              // Titles
              Text(
                "Let’s Get Started!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Let’s dive into your account.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),

              const Spacer(flex: 2),

              // Social Buttons
              SocialAuthButton(
                iconPath: AppAssets.googleIcon,
                label: "Continue with Google",
                onPressed: () {},
              ),
              SizedBox(height: 16.h),
              SocialAuthButton(
                iconPath: AppAssets.appleIcon,
                label: "Continue with Apple",
                onPressed: () {},
              ),
              SizedBox(height: 16.h),
              SocialAuthButton(
                iconPath: AppAssets.facebookIcon,
                label: "Continue with Facebook",
                onPressed: () {},
              ),

              const Spacer(flex: 2),

              // Email Login Button
              OnboardingButton(
                text: "Login with Email",
                isPrimary: true,
                onPressed: () {},
              ),
              SizedBox(height: 16.h),

              // Sign Up Button
              OnboardingButton(
                text: "Sign Up",
                isPrimary: false,
                onPressed: () {},
              ),

              const Spacer(flex: 2),

              // Footer
              Text(
                "Privacy Policy  .  Terms of Service",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
