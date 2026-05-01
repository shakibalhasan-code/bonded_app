import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import 'package:country_picker/country_picker.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.pickImage(),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Profile Picture",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Form Fields
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
            _buildSelectField(
              text: controller.dateOfBirth.value.isEmpty
                  ? "DD/MM/YYYY"
                  : controller.dateOfBirth.value,
              icon: Icons.calendar_month,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1994, 8, 28),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  controller.dateOfBirth.value =
                      "${date.day}/${date.month}/${date.year}";
                }
              },
            ),
            SizedBox(height: 24.h),

            _buildLabel("Gender"),
            SizedBox(height: 12.h),
            _buildDropdown(
              value: "Male",
              items: ["Male", "Female", "Other"],
              onChanged: (val) {},
            ),
            SizedBox(height: 24.h),

            _buildLabel("Country"),
            SizedBox(height: 12.h),
            _buildDropdown(
              value: "United States of America",
              items: ["United States of America", "Canada", "UK"],
              onChanged: (val) {},
            ),
            SizedBox(height: 24.h),

            _buildLabel("City"),
            SizedBox(height: 12.h),
            _buildDropdown(
              value: "New Jersey",
              items: ["New Jersey", "New York"],
              onChanged: (val) {},
            ),
            SizedBox(height: 24.h),

            _buildLabel("Location"),
            SizedBox(height: 12.h),
            _buildSelectField(
              text: "2464 Royal Ln. Mesa",
              icon: Icons.location_on,
              onTap: () {},
            ),
            SizedBox(height: 24.h),

            _buildLabel("Connection Type"),
            SizedBox(height: 12.h),
            _buildDropdown(
              value: "One-on-One Friendship",
              items: ["One-on-One Friendship", "Networking", "Business"],
              onChanged: (val) {},
            ),
            SizedBox(height: 24.h),

            _buildLabel("Profile Visibility"),
            SizedBox(height: 12.h),
            _buildDropdown(
              value: "Public",
              items: ["Public", "Connections Only", "Private"],
              onChanged: (val) {},
            ),
            SizedBox(height: 48.h),

            // Interests Section
            Text(
              "Interests",
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B0B3B),
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
                children: categories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ...entry.value.map((interest) {
                        return Obx(() {
                          final isSelected = controller.selectedInterests.contains(interest.slug);
                          return CheckboxListTile(
                            title: Text(
                              interest.name,
                              style: GoogleFonts.inter(fontSize: 14.sp),
                            ),
                            value: isSelected,
                            onChanged: (val) => controller.toggleInterest(interest.slug),
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.trailing,
                          );
                        });
                      }),
                      SizedBox(height: 24.h),
                    ],
                  );
                }).toList(),
              );
            }),
            SizedBox(height: 100.h),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          child: Text(
            "Save Changes",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B0B3B),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 14.sp),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }

  Widget _buildSelectField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7FF),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: GoogleFonts.inter(fontSize: 14.sp)),
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
