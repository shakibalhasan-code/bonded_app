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
          icon: const Icon(Icons.close, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Filters",
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
            // Price Range
            _buildSectionContainer(
              title: "Ticket Price Range",
              child: Obx(
                () => _buildRangeSlider(
                  values: controller.priceRange.value,
                  min: 0,
                  max: 100,
                  onChanged: (val) => controller.priceRange.value = val,
                  symbol: "\$",
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Location
            _buildLabel("Location"),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FF),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.selectedLocation.value,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: const Color(0xFF1B0B3B).withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Distance Range
            _buildSectionContainer(
              title: "Event Location Range (km)",
              child: Obx(
                () => _buildRangeSlider(
                  values: controller.distanceRange.value,
                  min: 0,
                  max: 50,
                  onChanged: (val) => controller.distanceRange.value = val,
                  symbol: "",
                  suffix: "km",
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Date"),
                      SizedBox(height: 12.h),
                      Obx(
                        () => _buildPickerField(
                          text: controller.selectedDate.value == null
                              ? "DD/MM/YYYY"
                              : DateFormat(
                                  'dd/MM/yyyy',
                                ).format(controller.selectedDate.value!),
                          icon: Icons.calendar_month_outlined,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null)
                              controller.selectedDate.value = date;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Time"),
                      SizedBox(height: 12.h),
                      Obx(
                        () => _buildPickerField(
                          text: controller.selectedTime.value == null
                              ? "Time"
                              : controller.selectedTime.value!.format(context),
                          icon: Icons.access_time,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null)
                              controller.selectedTime.value = time;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Others (Categories)
            _buildLabel("Others"),
            SizedBox(height: 16.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.availableFilterCategories.map((cat) {
                  return Obx(() {
                    final isSelected = controller.activeFilterCategories
                        .contains(cat);
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: GestureDetector(
                        onTap: () => controller.toggleFilterCategory(cat),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.resetFilters();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9F9FF),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  "Reset",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
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
                  "Apply",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(title),
          SizedBox(height: 24.h),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B0B3B),
      ),
    );
  }

  Widget _buildRangeSlider({
    required RangeValues values,
    required double min,
    required double max,
    required Function(RangeValues) onChanged,
    required String symbol,
    String suffix = "",
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6.h,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: const Color(0xFFE5E5E5),
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withOpacity(0.1),
            rangeThumbShape: RoundRangeSliderThumbShape(
              enabledThumbRadius: 10.r,
              elevation: 4,
            ),
            rangeValueIndicatorShape:
                const RectangularRangeSliderValueIndicatorShape(),
          ),
          child: RangeSlider(
            values: values,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        // Custom Tooltips (Image 1 style)
        _buildTooltip(values.start, min, max, symbol, suffix, true),
        _buildTooltip(values.end, min, max, symbol, suffix, false),
      ],
    );
  }

  Widget _buildTooltip(
    double value,
    double min,
    double max,
    String symbol,
    String suffix,
    bool isStart,
  ) {
    // Basic positioning logic for tooltips
    double percent = (value - min) / (max - min);
    return Positioned(
      left: (percent * 0.8 * 1.sw) + (isStart ? 0 : 20.w), // Approximation
      top: -35.h,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              "$symbol${value.round()}$suffix",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          CustomPaint(
            size: Size(10.w, 6.h),
            painter: TrianglePainter(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FF),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: const Color(0xFF1B0B3B).withOpacity(0.6),
                ),
              ),
            ),
            Icon(icon, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
