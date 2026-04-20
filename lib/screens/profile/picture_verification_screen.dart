import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile/verification_success_dialog.dart';
import '../../core/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';

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
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.KYC_DOCUMENT),
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
                color: const Color(0xFFFAF7FF),
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
                  onTap: () => _showImageSourceSelector(context, controller),
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

  void _showImageSourceSelector(BuildContext context, ProfileController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose Image Source",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: "Camera",
                  onTap: () => _handleImageSelection(controller, ImageSource.camera),
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: "Gallery",
                  onTap: () => _handleImageSelection(controller, ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 64.w,
            width: 64.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImageSelection(ProfileController controller, ImageSource source) async {
    Get.back(); // Close bottom sheet
    await controller.pickVerificationImage(source);
    if (controller.verificationImagePath.value.isNotEmpty) {
      Get.dialog(
        VerificationSuccessDialog(
          title: "Picture Verified Successfully!",
          description: "Your picture is verified—thanks for keeping your profile secure.",
          onPressed: () {
            Get.back(); // Close dialog
            Get.toNamed(AppRoutes.KYC_DOCUMENT);
          },
        ),
        barrierDismissible: false,
      );
    }
  }
}
