import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../core/routes/app_routes.dart';
import 'map_selection_screen.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHeading),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Add Location",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              "Please provide your location details to help us find the best matches for you.",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            // Country
            Text(
              "Country",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  onSelect: (Country country) {
                    controller.selectedCountry.value = country.name;
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7FF),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() => Text(
                        controller.selectedCountry.value,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      )),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // City
            Text(
              "City",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7FF),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: controller.cityController,
                decoration: InputDecoration(
                  hintText: "Enter your city",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Location with Map Icon
            Text(
              "Location",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => Get.to(() => const MapSelectionScreen()),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7FF),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() => Text(
                        controller.currentAddress.value.isEmpty ? "Enter your location" : controller.currentAddress.value,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: controller.currentAddress.value.isEmpty ? Colors.grey[400] : AppColors.textPrimary,
                        ),
                      )),
                    ),
                    Icon(Icons.location_on, color: AppColors.primary, size: 24.sp),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Auto-fetch location button
            Obx(() => TextButton.icon(
              onPressed: controller.isLoadingLocation.value ? null : controller.fetchCurrentLocation,
              icon: controller.isLoadingLocation.value 
                  ? SizedBox(height: 16.h, width: 16.w, child: const CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, color: AppColors.primary),
              label: Text(
                controller.isLoadingLocation.value ? "Fetching location..." : "Use current location",
                style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            )),

            SizedBox(height: 100.h),

            // Continue Button
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.CHOOSE_INTEREST),
              child: Container(
                height: 56.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Continue",
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
