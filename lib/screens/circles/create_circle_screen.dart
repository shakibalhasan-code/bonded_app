import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/circles/interest_selection_sheet.dart';
import '../../widgets/custom_search_field.dart';
import '../../controllers/circle_controller.dart';
import '../../controllers/profile_controller.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({Key? key}) : super(key: key);

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController memberSearchController = TextEditingController();

  final CircleController circleController = Get.find<CircleController>();
  final ProfileController profileController = Get.find<ProfileController>();

  List<String> selectedInterestSlugs = [];
  List<String> selectedInterestNames = [];

  bool isPaid = false;
  late bool isPublic;

  @override
  void initState() {
    super.initState();
    isPublic = Get.arguments?['isPublic'] ?? true;
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
          isPublic ? "Create Public Circle" : "Create Private Circle",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Text(
              "Add circle cover image",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7FF),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: AppColors.primary.withOpacity(0.4),
                    gap: 6,
                    dash: 8,
                  ),
                  child: _selectedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImage = null),
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: AppColors.primary,
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey[400],
                                size: 30.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "Add circle cover image",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: const Color(0xFF1B0B3B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Circle Name
            _buildSectionTitle("Circle Name"),
            SizedBox(height: 8.h),
            _buildTextField(nameController, "Circle Name"),
            SizedBox(height: 20.h),

            // Description
            _buildSectionTitle("Description"),
            SizedBox(height: 8.h),
            _buildTextField(descController, "Description...", maxLines: 4),
            SizedBox(height: 20.h),

            // Location
            _buildSectionTitle("Location"),
            SizedBox(height: 8.h),
            Obx(() => _buildTextField(
              locationController,
              profileController.isLoadingLocation.value 
                  ? "Fetching location..." 
                  : "Address (e.g., Dhaka, Bangladesh)",
              suffixIcon: Icons.my_location,
              onSuffixTap: () async {
                await profileController.fetchCurrentLocation();
                if (profileController.currentAddress.value.isNotEmpty) {
                  locationController.text = profileController.currentAddress.value;
                }
              },
            )),
            SizedBox(height: 20.h),

            // Add Circle Interest
            _buildSectionTitle("Add Circle Interest"),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: _showInterestSelectionSheet,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7FF),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedInterestNames.isEmpty 
                          ? "Select Interests" 
                          : selectedInterestNames.join(", "),
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: selectedInterestNames.isEmpty ? Colors.grey[400] : const Color(0xFF1B0B3B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (selectedInterestNames.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: selectedInterestNames.asMap().entries.map((entry) {
                  final index = entry.key;
                  final name = entry.value;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.primary.withOpacity(0.12)),
                    ),
                    constraints: BoxConstraints(maxWidth: 0.7.sw),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedInterestNames.removeAt(index);
                              selectedInterestSlugs.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 24.h),

            // Is Paid Circle
            Row(
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: Checkbox(
                    value: isPaid,
                    onChanged: (val) => setState(() => isPaid = val ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "Is this a paid circle?",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
              ],
            ),
            if (isPaid) ...[
              SizedBox(height: 16.h),
              _buildSectionTitle("Circle Price"),
              SizedBox(height: 8.h),
              _buildTextField(
                priceController,
                "Enter Price (e.g., 10)",
                suffixIcon: Icons.attach_money,
              ),
            ],
            SizedBox(height: 48.h),

            // Create Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: circleController.isLoading.value 
                  ? null 
                  : _handleCreateCircle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: circleController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Create Circle",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              ),
            )),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  void _handleCreateCircle() {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a circle name');
      return;
    }

    final circleData = {
      "name": nameController.text,
      "description": descController.text,
      "category": "social-lifestyle", // As per user request example
      "visibility": isPublic ? "public" : "private",
      "interestSlugs": selectedInterestSlugs,
      "isPaid": isPaid,
      "price": double.tryParse(priceController.text) ?? 0,
      "address": locationController.text.isEmpty ? "Not Specified" : locationController.text,
      "location": {
        "longitude": profileController.longitude.value, // Using profile location as fallback or default
        "latitude": profileController.latitude.value
      }
    };

    circleController.createCircle(
      circleData: circleData,
      imageFile: _selectedImage,
    );
  }
  
  void _showInterestSelectionSheet() {
    Get.bottomSheet(
      InterestSelectionSheet(
        initialSelected: selectedInterestNames,
        onSelected: (selectedNames) {
          // Find slugs for the selected names from profileController.allInterests
          final List<String> slugs = [];
          for (var name in selectedNames) {
            final interest = profileController.allInterests.firstWhereOrNull((i) => i.name == name);
            if (interest != null) {
              slugs.add(interest.slug);
            }
          }
          setState(() {
            selectedInterestNames = selectedNames;
            selectedInterestSlugs = slugs;
          });
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1B0B3B),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        color: const Color(0xFF1B0B3B),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFFAF7FF),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: maxLines > 1 ? 16.h : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: AppColors.primary, size: 20.sp),
                onPressed: onSuffixTap,
              )
            : null,
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double gap;
  final double dash;

  DashedBorderPainter({required this.color, this.gap = 5.0, this.dash = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(16.r),
    );
    path.addRRect(rrect);

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
