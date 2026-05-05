import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../core/routes/app_routes.dart';

class ChooseInterestScreen extends StatefulWidget {
  const ChooseInterestScreen({Key? key}) : super(key: key);

  @override
  State<ChooseInterestScreen> createState() => _ChooseInterestScreenState();
}

class _ChooseInterestScreenState extends State<ChooseInterestScreen> {
  final controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    // Fetch interests when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchInterests();
    });
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textHeading),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Choose Interest",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingInterests.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.allInterests.isEmpty) {
                return Center(
                  child: Text(
                    "No interests found",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                );
              }

              final categories = controller.interestsByCategory;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      "Pick your interests to discover people, communities, and activities that match your vibe.",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    ...categories.entries.map((category) {
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
                          SizedBox(height: 16.h),
                          ...category.value.map((interest) {
                            return Obx(() {
                              final isSelected = controller.selectedInterests.contains(interest.slug);
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (_) => controller.toggleInterest(interest.slug),
                                title: Text(
                                  interest.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                activeColor: AppColors.primary,
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.trailing,
                              );
                            });
                          }),
                          SizedBox(height: 24.h),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              );
            }),
          ),
          
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
            child: GestureDetector(
              onTap: () {
                if (controller.validateInterests()) {
                  Get.toNamed(AppRoutes.CONNECTION_TYPE);
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
          ),
        ],
      ),
    );
  }
}
