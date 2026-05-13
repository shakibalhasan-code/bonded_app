import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/create_event_controller.dart';
import '../../widgets/circles/interest_selection_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';

class CreateEventScreen extends GetView<CreateEventController> {
  const CreateEventScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _categories = const [
    {"slug": "Celebrations", "name": "Celebrations"},
    {"slug": "Social", "name": "Social"},
    {"slug": "Food & Drinks", "name": "Food & Drinks"},
    {"slug": "Nightlife", "name": "Nightlife"},
    {"slug": "Networking & Professional", "name": "Networking & Professional"},
    {"slug": "Fitness & Wellness", "name": "Fitness & Wellness"},
    {"slug": "Arts & Culture", "name": "Arts & Culture"},
    {"slug": "Music & Entertainment", "name": "Music & Entertainment"},
    {"slug": "Travel & Adventure", "name": "Travel & Adventure"},
    {"slug": "Education & Workshops", "name": "Education & Workshops"},
    {"slug": "Dating & Singles", "name": "Dating & Singles"},
    {"slug": "Community & Causes", "name": "Community & Causes"},
    {"slug": "Virtual Events", "name": "Virtual Events"},
    {"slug": "Graduation", "name": "Graduation"},
    {"slug": "Religious/Faith-based", "name": "Religious/Faith-based"},
    {"slug": "Other", "name": "Other"},
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

  Future<void> _selectTime(BuildContext context, {bool isStart = true}) async {
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
      if (isStart) {
        controller.selectedTime.value = pickedTime;
      } else {
        controller.selectedEndTime.value = pickedTime;
      }
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
              SizedBox(height: 24.h),

              // CATEGORY SELECTION (REPLACED INTERESTS)
              _buildLabel("Select Event Category"),
              _buildDropdown(),
              SizedBox(height: 24.h),

              // Cover Image Selection (Category-based)
              Obx(() {
                if (controller.categoryImages.isEmpty &&
                    !controller.isLoadingImages.value) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Choose cover image"),
                    if (controller.isLoadingImages.value)
                      const Center(child: CircularProgressIndicator())
                    else
                      SizedBox(
                        height: 120.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.categoryImages.length,
                          itemBuilder: (context, index) {
                            final imageUrl = controller.categoryImages[index];
                            return Obx(() {
                              final isSelected =
                                  controller.selectedCoverImageUrl.value ==
                                  imageUrl;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectedCoverImageUrl.value =
                                      imageUrl;
                                  controller.coverImagePath.value = '';
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 12.w),
                                  width: 120.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 2.w,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          width: 120.w,
                                          height: 120.h,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: Colors.grey[100],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                        if (isSelected)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    SizedBox(height: 24.h),
                  ],
                );
              }),

              // Preview of selected image
              Obx(() {
                if (controller.selectedCoverImageUrl.value == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Preview"),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CachedNetworkImage(
                        imageUrl: controller.selectedCoverImageUrl.value!,
                        width: double.infinity,
                        height: 180.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180.h,
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                );
              }),

              SizedBox(height: 24.h),
              // Image Picker
              // GestureDetector(
              //   onTap: _pickImage,
              //   child: Obx(() => Container(
              //         height: 180.h,
              //         width: double.infinity,
              //         decoration: BoxDecoration(
              //           color: const Color(0xFFFAF7FF),
              //           borderRadius: BorderRadius.circular(16.r),
              //           border: Border.all(
              //             color: AppColors.primary.withOpacity(0.3),
              //             width: 1.5,
              //           ),
              //         ),
              //         child: controller.coverImagePath.value.isEmpty
              //             ? Column(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   Icon(
              //                     Icons.image_outlined,
              //                     color: Colors.grey[400],
              //                     size: 48.sp,
              //                   ),
              //                   SizedBox(height: 12.h),
              //                   Text(
              //                     "Or upload your own cover image",
              //                     style: GoogleFonts.inter(
              //                       fontSize: 14.sp,
              //                       fontWeight: FontWeight.w600,
              //                       color: const Color(0xFF1B0B3B),
              //                     ),
              //                   ),
              //                 ],
              //               )
              //             : ClipRRect(
              //                 borderRadius: BorderRadius.circular(16.r),
              //                 child: Image.file(
              //                   File(controller.coverImagePath.value),
              //                   fit: BoxFit.cover,
              //                   width: double.infinity,
              //                 ),
              //               ),
              //       )),
              // ),
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
                  GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          controller.countryCode.value = country.phoneCode;
                          controller.countryFlag.value = country.flagEmoji;
                        },
                      );
                    },
                    child: Container(
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
                          Obx(() => Text(
                                "${controller.countryFlag.value} +${controller.countryCode.value}",
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              )),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      controller.phoneController,
                      "1234567",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              _buildLabel("Add Social Media Links (Optional)"),
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

              // Duplicate category removed from here as it's now at the top
              // _buildLabel("Event Category"),
              // _buildDropdown(),
              // SizedBox(height: 24.h),
              _buildLabel("Date"),
              _buildPickerField(
                controller.selectedDate.value == null
                    ? "DD/MM/YYYY"
                    : "${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}",
                Icons.calendar_month_outlined,
                () => _selectDate(context),
              ),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Start Time"),
                        _buildPickerField(
                          controller.selectedTime.value == null
                              ? "HH:MM"
                              : controller.selectedTime.value!.format(context),
                          Icons.access_time,
                          () => _selectTime(context, isStart: true),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("End Time"),
                        _buildPickerField(
                          controller.selectedEndTime.value == null
                              ? "HH:MM"
                              : controller.selectedEndTime.value!.format(
                                  context,
                                ),
                          Icons.access_time,
                          () => _selectTime(context, isStart: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              if (!controller.isVirtual.value) ...[
                _buildLabel("Location"),
                _buildLocationField(),
                SizedBox(height: 24.h),

                _buildLabel("Suggested Venues"),
                SizedBox(height: 12.h),
                Obx(() {
                  if (controller.isLoadingVenues.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.suggestedVenues.isEmpty) {
                    return Text(
                      "No suggested venues found nearby",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    );
                  }
                  return Column(
                    children: controller.suggestedVenues.asMap().entries.map((
                      entry,
                    ) {
                      return _buildVenueItem(entry.value, entry.key);
                    }).toList(),
                  );
                }),
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
                onPressed: () => controller.createEvent(context),
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

  void _showInterestSelectionSheet(BuildContext context) {
    Get.bottomSheet(
      InterestSelectionSheet(
        initialSelected: controller.selectedInterestNames.toList(),
        onSelected: (selectedNames) {
          final List<String> slugs = [];
          for (var name in selectedNames) {
            final interest = controller.allInterests.firstWhereOrNull(
              (i) => i.name == name,
            );
            if (interest != null) {
              slugs.add(interest.slug);
            }
          }
          controller.selectedInterestNames.assignAll(selectedNames);
          controller.selectedInterests.assignAll(slugs);

          // Fetch images based on the first selected interest's category
          if (slugs.isNotEmpty) {
            final interest = controller.allInterests.firstWhereOrNull(
              (i) => i.slug == slugs.first,
            );
            if (interest != null) {
              controller.fetchEventInterestImages(interest.category);
            }
          } else {
            controller.categoryImages.clear();
            controller.selectedCoverImageUrl.value = null;
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
          value:
              _categories.any(
                (c) => c['slug'] == controller.selectedCategory.value,
              )
              ? controller.selectedCategory.value
              : null,
          hint: Text(
            "Select Category",
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[400]),
          ),
          items: _categories
              .map(
                (c) =>
                    DropdownMenuItem(value: c['slug'], child: Text(c['name']!)),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              controller.selectedCategory.value = val;
              controller.fetchEventInterestImages(val);
            }
          },
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
      child: Obx(
        () => TextField(
          controller: controller.locationController,
          decoration: InputDecoration(
            hintText: "Location",
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
            suffixIcon: controller.isLocating.value
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    onPressed: () => controller.getCurrentLocation(),
                  ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildVenueItem(Map<String, dynamic> venueData, int index) {
    final venueName = venueData['venueName'] ?? '';
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venueName,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
                Text(
                  venueData['address'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Obx(() {
            final isSelected = controller.selectedVenueIndex.value == index;
            return SizedBox(
              height: 32.h,
              child: ElevatedButton(
                onPressed: () => controller.selectVenue(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.primary
                      : Colors.white,
                  foregroundColor: isSelected
                      ? Colors.white
                      : AppColors.primary,
                  elevation: 0,
                  side: BorderSide(color: AppColors.primary, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                child: Text(
                  isSelected ? "Added" : "Add",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
