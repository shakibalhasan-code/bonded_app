import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';

class EventSuccessDialog extends StatelessWidget {
  const EventSuccessDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100.w,
              width: 100.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.check, color: Colors.white, size: 50.sp),
            ),
            SizedBox(height: 32.h),
            Text(
              "Congratulations!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "You have successfully create event successfully. Enjoy your event.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.MAIN); // Go to main first to reset stack
                // Then navigate to details if you want, but offAll is safer to avoid dialog persistence
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "View Details",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.MAIN),
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                backgroundColor: AppColors.primary.withOpacity(0.05),
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
          ],
        ),
      ),
    );
  }
}
