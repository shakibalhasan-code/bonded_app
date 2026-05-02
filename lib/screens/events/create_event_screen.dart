import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/create_event_controller.dart';

class CreateEventScreen extends GetView<CreateEventController> {
  const CreateEventScreen({Key? key}) : super(key: key);

  final List<String> _categories = const [
    "Birthday Celebration",
    "Graduation",
    "Anniversary",
    "Celebrations",
  ];

  final List<String> _suggestedVenues = const [
    "Grand Place Hotel",
    "Sonny Restaurant",
    "Redfin Hotel",
    "Dreams Restaurant",
    "Five Star Hotel",
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      controller.coverImagePath.value = pickedFile.path;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      controller.selectedDate.value = pickedDate;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      controller.selectedTime.value = pickedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create Event",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7FF),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: controller.coverImagePath.value.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: Colors.grey[400],
                              size: 48.sp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "Add event cover image",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B0B3B),
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            File(controller.coverImagePath.value),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24.h),

              _buildLabel("Event Name"),
              _buildTextField(controller.nameController, "Event Name"),
              SizedBox(height: 24.h),

              _buildLabel("Description"),
              _buildTextField(
                controller.descriptionController,
                "Description...",
                maxLines: 4,
              ),
              SizedBox(height: 24.h),

              _buildLabel("Phone Number"),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7FF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "🇧🇩 +880",
                          style: GoogleFonts.inter(fontSize: 14.sp),
                        ),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildTextField(controller.phoneController, "1234567")),
                ],
              ),
              SizedBox(height: 24.h),

              _buildLabel("Add Social Media Links"),
              _buildSocialInput(
                Icons.facebook,
                controller.fbController,
                "Add Facebook Link",
                Colors.blue,
              ),
              SizedBox(height: 12.h),
              _buildSocialInput(
                Icons.alternate_email,
                controller.twitterController,
                "Add Twitter Link",
                Colors.lightBlue,
              ),
              SizedBox(height: 24.h),

              _buildLabel("Show phone number to attendees?"),
              Row(
                children: [
                  _buildRadioButton(
                    "Yes",
                    controller.showPhone.value,
                    (val) => controller.showPhone.value = true,
                  ),
                  SizedBox(width: 24.w),
                  _buildRadioButton(
                    "No",
                    !controller.showPhone.value,
                    (val) => controller.showPhone.value = false,
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              _buildLabel("Show social media links to attendees?"),
              Row(
                children: [
                  _buildRadioButton(
                    "Yes",
                    controller.showSocial.value,
                    (val) => controller.showSocial.value = true,
                  ),
                  SizedBox(width: 24.w),
                  _buildRadioButton(
                    "No",
                    !controller.showSocial.value,
                    (val) => controller.showSocial.value = false,
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              _buildLabel("Event Category"),
              _buildDropdown(),
              SizedBox(height: 24.h),

              _buildLabel("Date"),
              _buildPickerField(
                controller.selectedDate.value == null
                    ? "DD/MM/YYYY"
                    : "${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}",
                Icons.calendar_month_outlined,
                () => _selectDate(context),
              ),
              SizedBox(height: 24.h),

              _buildLabel("Time"),
              _buildPickerField(
                controller.selectedTime.value == null
                    ? "HH:MM"
                    : controller.selectedTime.value!.format(context),
                Icons.access_time,
                () => _selectTime(context),
              ),
              SizedBox(height: 24.h),

              if (!controller.isVirtual.value) ...[
                _buildLabel("Location"),
                _buildLocationField(),
                SizedBox(height: 24.h),

                _buildLabel("Suggested Venues"),
                SizedBox(height: 12.h),
                ..._suggestedVenues.map((v) => _buildVenueItem(v)).toList(),
                SizedBox(height: 24.h),
              ],

              if (controller.isVirtual.value) ...[
                _buildLabel("Add Virtual Link"),
                _buildTextField(controller.virtualLinkController, "Enter Link"),
                SizedBox(height: 24.h),
              ],

              Row(
                children: [
                  Checkbox(
                    value: controller.isPaid.value,
                    onChanged: (val) => controller.isPaid.value = val!,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Text(
                    "Is this a Paid event?",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                ],
              ),
              if (controller.isPaid.value) ...[
                SizedBox(height: 24.h),
                _buildLabel("Ticket Price"),
                _buildTextField(controller.priceController, "Ticket price"),
              ],
              SizedBox(height: 24.h),

              if (!controller.isVirtual.value) ...[
                _buildLabel("Available Seats Quantity"),
                _buildTextField(controller.seatsController, "Available seats"),
              ],
              SizedBox(height: 48.h),

              ElevatedButton(
                onPressed: () => controller.createEvent(),
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
                  "Create Event",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1B0B3B),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSocialInput(
    IconData icon,
    TextEditingController controller,
    String hint,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(child: _buildTextField(controller, hint)),
      ],
    );
  }

  Widget _buildRadioButton(
    String label,
    bool isSelected,
    Function(bool?)? onChanged,
  ) {
    return Row(
      children: [
        Radio<bool>(
          value: true,
          groupValue: isSelected,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedCategory.value,
          hint: Text(
            "Dropdown to select",
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[400]),
          ),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => controller.selectedCategory.value = val,
        ),
      ),
    );
  }

  Widget _buildPickerField(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7FF),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
            ),
            Icon(icon, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller.locationController,
        decoration: InputDecoration(
          hintText: "Location",
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
          suffixIcon: Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildVenueItem(String venue) {
    // Note: Mock venues don't have full state in controller yet, just UI toggles here for now
    // In a real app, this would be in the controller
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            venue,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[700]),
          ),
          SizedBox(
            height: 32.h,
            child: OutlinedButton(
              onPressed: () {
                controller.venueName.value = venue;
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Text(
                "Add",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

