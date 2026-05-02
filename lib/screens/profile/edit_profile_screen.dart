import 'dart:io';
import 'package:bonded_app/controllers/auth_controller.dart';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';

import '../../controllers/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import 'map_selection_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: Obx(() {
        final authController = Get.find<AuthController>();
        final user = authController.currentUser.value;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile Image
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Obx(() {
                          ImageProvider imageProvider;
                          if (controller.profileImagePath.value.isNotEmpty) {
                            imageProvider = FileImage(
                              File(controller.profileImagePath.value),
                            );
                          } else {
                            final avatar = user?.avatar;
                            imageProvider = NetworkImage(AppUrls.imageUrl(avatar));
                          }
                          return Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: controller.pickImage,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.profileImagePath.value.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: controller.uploadPickedAvatar,
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  iconSize: 32.sp,
                                ),
                                IconButton(
                                  onPressed: () => controller.profileImagePath.value = '',
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  iconSize: 32.sp,
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: Text(
                              "Profile Picture",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              _buildLabel("Full Name"),
              SizedBox(height: 12.h),
              _buildTextField(controller.fullNameController, "Full Name"),
              SizedBox(height: 24.h),

              _buildLabel("Username"),
              SizedBox(height: 12.h),
              _buildTextField(controller.usernameController, "Username"),
              SizedBox(height: 24.h),

              _buildLabel("Short Bio"),
              SizedBox(height: 12.h),
              _buildTextField(controller.bioController, "Bio", maxLines: 4),
              SizedBox(height: 24.h),

              _buildLabel("Phone Number"),
              SizedBox(height: 12.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        onSelect: (Country country) {
                          controller.selectedCountryCode.value =
                              "+${country.phoneCode}";
                        },
                      );
                    },
                    child: Container(
                      height: 56.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7FF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Obx(() => Text(controller.selectedCountryCode.value)),
                          Icon(Icons.keyboard_arrow_down, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(controller.phoneController, "Phone"),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              _buildLabel("Date of Birth"),
              SizedBox(height: 12.h),
              Obx(
                () => _buildSelectField(
                  text: controller.dateOfBirth.value.isEmpty
                      ? "DD/MM/YYYY"
                      : controller.dateOfBirth.value,
                  icon: Icons.calendar_month,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      ),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.dateOfBirth.value =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ),
              SizedBox(height: 24.h),

              _buildLabel("Gender"),
              SizedBox(height: 12.h),
              Obx(
                () => _buildDropdown(
                  value: controller.selectedGender.value,
                  items: ["Male", "Female", "Other"],
                  onChanged: (val) => controller.selectedGender.value = val!,
                ),
              ),
              SizedBox(height: 24.h),

              _buildLabel("Country"),
              SizedBox(height: 12.h),
              Obx(
                () => _buildSelectField(
                  text: controller.selectedCountry.value,
                  icon: Icons.keyboard_arrow_down,
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      onSelect: (Country country) {
                        controller.selectedCountry.value = country.name;
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),

              _buildLabel("City"),
              SizedBox(height: 12.h),
              _buildTextField(controller.cityController, "City"),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel("Location"),
                  Text(
                    "(Private)",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Obx(
                () => _buildSelectField(
                  text: controller.currentAddress.value.isEmpty
                      ? "Pick Location"
                      : controller.currentAddress.value,
                  icon: Icons.map,
                  trailingIcon: Icons.my_location,
                  onTrailingIconTap: controller.fetchCurrentLocation,
                  onTap: () => Get.to(() => const MapSelectionScreen()),
                ),
              ),
              SizedBox(height: 24.h),

              _buildLabel("Profile Visibility"),
              SizedBox(height: 12.h),
              Obx(
                () => _buildDropdown(
                  value: controller.profileVisibility.value,
                  items: ["Public", "Connections Only", "Private"],
                  onChanged: (val) => controller.profileVisibility.value = val!,
                ),
              ),
              SizedBox(height: 32.h),

              _buildLabel("Connection Type"),
              SizedBox(height: 16.h),
              ...[
                "Small Group Hangouts",
                "One-on-One Friendship",
                "Event Based Meetup",
              ].map((type) {
                return Obx(() {
                  final isSelected = controller.selectedConnectionTypes
                      .contains(type);
                  return GestureDetector(
                    onTap: () => controller.toggleConnectionType(type),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[200]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 24.w,
                            width: 24.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[400]!,
                                width: 1.5,
                              ),
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            type,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHeading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              }).toList(),
              SizedBox(height: 32.h),

              _buildLabel("Interests"),
              SizedBox(height: 8.h),
              Text(
                "Pick your interests to discover people and activities that match your vibe.",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              Obx(() {
                if (controller.isLoadingInterests.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final categories = controller.interestsByCategory;
                if (categories.isEmpty) {
                  return const Center(child: Text("No interests found"));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.entries.map((category) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.key,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: category.value.map((interest) {
                            return Obx(() {
                              final isSelected = controller.selectedInterests
                                  .contains(interest.slug);
                              return GestureDetector(
                                onTap: () =>
                                    controller.toggleInterest(interest.slug),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(30.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey[200]!,
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    interest.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1B0B3B),
                                    ),
                                  ),
                                ),
                              );
                            });
                          }).toList(),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: 100.h),
            ],
          ),
        );
      }),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        color: Colors.white,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.updateProfile(isInitialFlow: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Save Changes",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFAF7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildSelectField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    IconData? trailingIcon,
    VoidCallback? onTrailingIconTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7FF),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: GoogleFonts.inter(fontSize: 14.sp)),
            ),
            if (trailingIcon != null)
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: IconButton(
                  icon: Icon(
                    trailingIcon,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  onPressed: onTrailingIconTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            Icon(icon, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7FF),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.inter(fontSize: 14.sp)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
