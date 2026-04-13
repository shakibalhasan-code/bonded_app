import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/circle_model.dart';
import '../../widgets/circles/circle_member_tile.dart';

class CircleDetailsScreen extends StatelessWidget {
  const CircleDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CircleModel circle = Get.arguments;

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
          "Circle Details",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.network(
                  circle.image,
                  height: 250.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Header Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          circle.name,
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHeading,
                          ),
                        ),
                      ),
                      Text(
                        circle.price ?? "\$5.00",
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          circle.address ?? "Grand city St. 100, New York, United States.",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),

                  // Description
                  Text(
                    "Description:",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeading,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    circle.description,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),

                  const Divider(height: 32),

                  // Members List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Members",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeading,
                        ),
                      ),
                      Text(
                        "See All",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (circle.detailedMembers != null)
                    ...circle.detailedMembers!.map((member) => CircleMemberTile(member: member)).toList()
                  else
                    const Text("No members available"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
