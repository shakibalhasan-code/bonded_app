import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/auth/auth_text_field.dart';
import 'add_location_screen.dart';

class ProfileBuildingScreen extends StatelessWidget {
  const ProfileBuildingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

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
          "Profile Building",
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
          children: [
            SizedBox(height: 20.h),
            
            // Profile Picture
            Center(
              child: Column(
                children: [
                  Obx(() => Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: controller.profileImagePath.value.isNotEmpty
                            ? FileImage(File(controller.profileImagePath.value))
                            : null,
                        child: controller.profileImagePath.value.isEmpty
                            ? Icon(Icons.person, size: 50.sp, color: Colors.grey[400])
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: controller.pickImage,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, color: Colors.white, size: 16.sp),
                          ),
                        ),
                      ),
                    ],
                  )),
                  SizedBox(height: 12.h),
                  Text(
                    "Profile Picture",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeading,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),

            // Form Fields
            Obx(() => AuthTextField(
              label: "Full Name",
              hintText: "Full Name",
              prefixIcon: Icons.person_outline,
              controller: controller.fullNameController,
              errorText: controller.fullNameError.value.isEmpty ? null : controller.fullNameError.value,
            )),
            SizedBox(height: 20.h),

            Obx(() => AuthTextField(
              label: "Username",
              hintText: "Username",
              prefixIcon: Icons.alternate_email,
              controller: controller.usernameController,
              errorText: controller.usernameError.value.isEmpty ? null : controller.usernameError.value,
            )),
            SizedBox(height: 20.h),

            AuthTextField(
              label: "Short Bio",
              hintText: "Bio",
              prefixIcon: Icons.info_outline,
              controller: controller.bioController,
              maxLines: 3,
            ),
            SizedBox(height: 20.h),

            // Phone Number
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Phone Number",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeading,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            controller.selectedCountryCode.value = "+${country.phoneCode}";
                          },
                        );
                      },
                      child: Container(
                        height: 56.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FF),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Obx(() => Text(
                              controller.selectedCountryCode.value,
                              style: GoogleFonts.inter(fontSize: 14.sp),
                            )),
                            Icon(Icons.keyboard_arrow_down, size: 20.sp),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Obx(() => AuthTextField(
                        label: "", // Label is handled above
                        hintText: "5xxxxxxx",
                        prefixIcon: Icons.phone_android_outlined,
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        errorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
                      )),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Date of Birth
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  controller.dateOfBirth.value = DateFormat('dd/MM/yyyy').format(pickedDate);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date of Birth",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeading,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FF),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          controller.dateOfBirth.value.isEmpty ? "DD/MM/YYYY" : controller.dateOfBirth.value,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: controller.dateOfBirth.value.isEmpty ? Colors.grey[400] : AppColors.textPrimary,
                          ),
                        )),
                        Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Gender
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gender",
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
                    color: const Color(0xFFF9F9FF),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Obx(() => DropdownButton<String>(
                    value: controller.selectedGender.value.isEmpty ? null : controller.selectedGender.value,
                    hint: Text("Dropdown to select", style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[400])),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: ["Male", "Female", "Other"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: GoogleFonts.inter(fontSize: 14.sp)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) controller.selectedGender.value = value;
                    },
                  )),
                ),
              ],
            ),

            SizedBox(height: 48.h),

            // Continue Button
            GestureDetector(
              onTap: () {
                if (controller.validateProfileFields()) {
                  Get.to(() => const AddLocationScreen());
                }
              },
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
