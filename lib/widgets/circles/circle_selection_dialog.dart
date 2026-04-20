import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../app_button.dart';

class CircleSelectionDialog extends StatelessWidget {
  const CircleSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              Text(
                "Confirmation Required!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 12.h),

              // Description
              Text(
                "Select which circle you want to create? After selection you will proceed with the flow accordingly.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280).withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),

              // Public Circle Button
              AppButton(
                text: "Public Circle",
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.CREATE_CIRCLE, arguments: {'isPublic': true});
                },
              ),
              SizedBox(height: 12.h),

              // Private Circle Button
              AppButton(
                text: "Private Circle",
                isPrimary: false,
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.CREATE_CIRCLE, arguments: {'isPublic': false});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
