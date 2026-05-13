import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/app_button.dart';

class ProfileReadyScreen extends StatelessWidget {
  const ProfileReadyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String title = args['title'] ?? "You’re All Set!";
    final String message = args['message'] ??
        "Everything’s ready! Start exploring, connecting, and enjoying all the features waiting for you.";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Success Illustration
              Center(
                child: Container(
                  height: 160.w,
                  width: 160.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      height: 100.w,
                      width: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 4.h,
                            width: 12.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            height: 24.w,
                            width: 24.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person,
                                color: Colors.white, size: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Divider
              Divider(color: Colors.grey[200]),

              SizedBox(height: 16.h),

              // Go to Homepage Button
              AppButton(
                text: "Go to Homepage",
                isPrimary: true,
                onPressed: () => Get.offAllNamed(AppRoutes.MAIN),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
