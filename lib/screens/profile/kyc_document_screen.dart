import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile/verification_success_dialog.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/app_button.dart';

class KYCDocumentScreen extends StatelessWidget {
  const KYCDocumentScreen({Key? key}) : super(key: key);

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
          "Add KYC Document",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _showCompletionDialog(),
            child: Text(
              "Skip",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              "Choose how you want to connect with others and discover new friendships, communities, and shared interests along the way.",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            
            // Front Side
            _buildUploadSection(
              title: "Upload ID Card Front-side",
              onTap: () => controller.pickKycImage(true),
              imagePathObs: controller.kycFrontPath,
            ),
            
            SizedBox(height: 24.h),
            
            // Back Side
            _buildUploadSection(
              title: "Upload ID Card Back-side",
              onTap: () => controller.pickKycImage(false),
              imagePathObs: controller.kycBackPath,
            ),
            
            SizedBox(height: 48.h),
            
            // Continue Button
            AppButton(
              text: "Continue",
              isPrimary: true,
              onPressed: () => _showCompletionDialog(),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required VoidCallback onTap,
    required RxString imagePathObs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onTap,
          child: Obx(() => Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FF),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
                style: BorderStyle.solid, // Note: Dash border requires custom painter in Flutter
              ),
            ),
            child: imagePathObs.value.isEmpty 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.article_outlined, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Upload Picture",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeading,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(
                    File(imagePathObs.value),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
          )),
        ),
      ],
    );
  }

  void _showCompletionDialog() {
    Get.dialog(
      VerificationSuccessDialog(
        title: "Profile Created Successfully!",
        description: "Your profile is all set! Start exploring, connect with others, and join communities that match your interests.",
        onPressed: () {
          Get.toNamed(AppRoutes.SUBSCRIPTION_PLAN);
        },
      ),
      barrierDismissible: false,
    );
  }
}
