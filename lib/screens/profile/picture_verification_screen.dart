import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile/verification_success_dialog.dart';
import 'kyc_document_screen.dart';

class PictureVerificationScreen extends StatelessWidget {
  const PictureVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHeading),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Add Picture Verification",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            
            // Illustration Placeholder
            Container(
              height: 250.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FF),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Obx(() => controller.verificationImagePath.value.isEmpty 
                    ? Icon(Icons.person_outline, size: 100.sp, color: Colors.grey[300])
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Image.file(
                          File(controller.verificationImagePath.value),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                   ),
                ],
              ),
            ),
            
            SizedBox(height: 40.h),
            
            Text(
              "Add a Photo to Verify Your Identity",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Text(
              "Choose how you want to connect with others, discover new friendships and communities, let people know when you're available, and verify your profile for a trusted experience.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            
            const Spacer(),
            
            // Camera Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    await controller.captureSelfie();
                    if (controller.verificationImagePath.value.isNotEmpty) {
                      Get.dialog(
                        VerificationSuccessDialog(
                          title: "Picture Verified Successfully!",
                          description: "Your picture is verified—thanks for keeping your profile secure.",
                          onPressed: () {
                            Get.back(); // Close dialog
                            Get.to(() => const KYCDocumentScreen());
                          },
                        ),
                        barrierDismissible: false,
                      );
                    }
                  },
                  child: Container(
                    height: 64.w,
                    width: 64.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4D7128D0),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 28.sp),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
