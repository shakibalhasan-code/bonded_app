import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final CircleController circleController = Get.find<CircleController>();
  final ProfileController profileController = Get.find<ProfileController>();

  List<String> selectedInterestSlugs = [];
  List<String> selectedInterestNames = [];

  bool isPaid = false;
  late bool isPublic;
  String? _selectedCoverImageUrl;
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    isPublic = Get.arguments?['isPublic'] ?? true;
    circleController.fetchStoreProducts();
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
            // Add Circle Interest (NOW AT TOP)
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
                          color: selectedInterestNames.isEmpty
                              ? Colors.grey[400]
                              : const Color(0xFF1B0B3B),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.12),
                      ),
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
                              // Clear images if no category is left
                              if (selectedInterestSlugs.isEmpty) {
                                circleController.categoryImages.clear();
                                _selectedCoverImageUrl = null;
                              }
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

            // Cover Image Selection (Category-based)
            Obx(() {
              if (circleController.categoryImages.isEmpty &&
                  !circleController.isLoadingImages.value) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose cover image",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (circleController.isLoadingImages.value)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      height: 120.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: circleController.categoryImages.length,
                        itemBuilder: (context, index) {
                          final imageUrl =
                              circleController.categoryImages[index];
                          final isSelected = _selectedCoverImageUrl == imageUrl;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCoverImageUrl = imageUrl;
                              });
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
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[100],
                                        child: const Center(
                                          child: CircularProgressIndicator(
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
                                          color: Colors.black.withOpacity(0.3),
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
                        },
                      ),
                    ),
                  SizedBox(height: 24.h),
                ],
              );
            }),

            // Preview of selected image
            if (_selectedCoverImageUrl != null) ...[
              Text(
                "Preview",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CachedNetworkImage(
                  imageUrl: _selectedCoverImageUrl!,
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 180.h,
                    color: Colors.grey[100],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              SizedBox(height: 24.h),
            ],

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
            Obx(
              () => _buildTextField(
                locationController,
                profileController.isLoadingLocation.value
                    ? "Fetching location..."
                    : "Address (e.g., New York)",
                suffixIcon: Icons.my_location,
                onSuffixTap: () async {
                  await profileController.fetchCurrentLocation();
                  if (profileController.currentAddress.value.isNotEmpty) {
                    locationController.text =
                        profileController.currentAddress.value;
                  }
                },
              ),
            ),
            SizedBox(height: 20.h),

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
              Row(
                children: [
                  _buildSectionTitle("Circle Price"),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _showPricingInfo,
                    child: Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Obx(() {
                if (circleController.isLoadingProducts.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (circleController.storeProducts.isEmpty) {
                  return Text(
                    "No pricing tiers available",
                    style: GoogleFonts.inter(
                      color: Colors.red,
                      fontSize: 12.sp,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7FF),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          hint: Text(
                            "Select Pricing Tier",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          items: circleController.storeProducts.map((product) {
                            final price = product['price'];
                            final currency = product['currency'] ?? "\$";
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: product,
                              child: Text(
                                "${price.toStringAsFixed(0)}\$",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textHeading,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                priceController.text = val['price'].toString();
                                _selectedProductId = val['productId'];
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                );
              }),
            ],
            SizedBox(height: 48.h),

            // Create Button
            Obx(
              () => SizedBox(
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
              ),
            ),
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
    if (selectedInterestSlugs.isEmpty) {
      Get.snackbar('Error', 'Please select at least one interest');
      return;
    }
    if (_selectedCoverImageUrl == null) {
      Get.snackbar('Error', 'Please select a cover image');
      return;
    }

    final firstInterest = profileController.allInterests.firstWhereOrNull(
      (i) => i.slug == selectedInterestSlugs.first,
    );

    final circleData = {
      "name": nameController.text,
      "description": descController.text,
      "category": firstInterest?.category ?? "social-lifestyle",
      "visibility": isPublic ? "public" : "private",
      "interestSlugs": selectedInterestSlugs,
      "isPaid": isPaid,
      "price": double.tryParse(priceController.text) ?? 0,
      // "productId": _selectedProductId,
      "coverImage": _selectedCoverImageUrl,
      "address": locationController.text.isEmpty
          ? "Not Specified"
          : locationController.text,
      "location": {
        "longitude": profileController.longitude.value,
        "latitude": profileController.latitude.value,
      },
    };

    circleController.createCircle(circleData: circleData);
  }

  void _showPricingInfo() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Circle Pricing Information",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "To ensure a secure and stable digital economy, circle prices are set to predefined tiers. These tiers correspond to verified store products on Apple and Google platforms.",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Please select one of the available prices to continue.",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
                  "Got it",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showInterestSelectionSheet() {
    Get.bottomSheet(
      InterestSelectionSheet(
        initialSelected: selectedInterestNames,
        onSelected: (selectedNames) {
          final List<String> slugs = [];
          for (var name in selectedNames) {
            final interest = profileController.allInterests.firstWhereOrNull(
              (i) => i.name == name,
            );
            if (interest != null) {
              slugs.add(interest.slug);
            }
          }
          setState(() {
            selectedInterestNames = selectedNames;
            selectedInterestSlugs = slugs;

            // Fetch images based on the first selected interest's category
            if (slugs.isNotEmpty) {
              final interest = profileController.allInterests.firstWhereOrNull(
                (i) => i.slug == slugs.first,
              );
              if (interest != null) {
                circleController.fetchInterestImages(interest.category);
              }
            } else {
              circleController.categoryImages.clear();
              _selectedCoverImageUrl = null;
            }
          });
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
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
