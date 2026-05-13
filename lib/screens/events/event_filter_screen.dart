import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/event_controller.dart';
import '../../core/theme/app_colors.dart';

class EventFilterScreen extends StatelessWidget {
  const EventFilterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.inputField,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, color: AppColors.textPrimary, size: 20.sp),
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Filter Events",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 120.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Range Section
            _buildSectionHeader("Price Range"),
            SizedBox(height: 16.h),
            Obx(
              () => _buildPriceRangeSlider(controller),
            ),
            SizedBox(height: 32.h),

            // Location Section
            _buildSectionHeader("Location"),
            SizedBox(height: 12.h),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.inputField,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        controller.selectedLocation.value,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => controller.getCurrentLocation(),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: controller.isLocationLoading.value
                            ? SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.my_location,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Distance Section
            _buildSectionHeader("Distance"),
            SizedBox(height: 16.h),
            Obx(
              () => _buildDistanceSlider(controller),
            ),
            SizedBox(height: 32.h),

            // Date & Time Section
            _buildSectionHeader("Date & Time"),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _buildPickerField(
                      label: "Date",
                      text: controller.selectedDate.value == null
                          ? "Select Date"
                          : DateFormat('dd MMM, yyyy').format(
                              controller.selectedDate.value!,
                            ),
                      icon: Icons.calendar_today_outlined,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) controller.selectedDate.value = date;
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Obx(
                    () => _buildPickerField(
                      label: "Time",
                      text: controller.selectedTime.value == null
                          ? "Select Time"
                          : controller.selectedTime.value!.format(context),
                      icon: Icons.access_time_outlined,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) controller.selectedTime.value = time;
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Categories Section
            _buildSectionHeader("Categories"),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: controller.availableFilterCategories.map((cat) {
                return Obx(() {
                  final isSelected = controller.activeFilterCategories.contains(cat);
                  return GestureDetector(
                    onTap: () => controller.toggleFilterCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {
                  controller.resetFilters();
                  controller.fetchEvents();
                  Get.back();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  "Reset All",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    controller.applyFilters();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    "Apply Filters",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPriceRangeSlider(EventController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "\$${controller.priceRange.value.start.round()}",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              "\$${controller.priceRange.value.end.round()}",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4.h,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.1),
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withOpacity(0.1),
            rangeThumbShape: RoundRangeSliderThumbShape(
              enabledThumbRadius: 10.r,
              elevation: 4,
            ),
          ),
          child: RangeSlider(
            values: controller.priceRange.value,
            min: 0,
            max: 500,
            onChanged: (val) => controller.priceRange.value = val,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceSlider(EventController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${controller.distanceRange.value.start.round()} km",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              "${controller.distanceRange.value.end.round()} km",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4.h,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.1),
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withOpacity(0.1),
            rangeThumbShape: RoundRangeSliderThumbShape(
              enabledThumbRadius: 10.r,
              elevation: 4,
            ),
          ),
          child: RangeSlider(
            values: controller.distanceRange.value,
            min: 0,
            max: 100,
            onChanged: (val) => controller.distanceRange.value = val,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.inputField,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
