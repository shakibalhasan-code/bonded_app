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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Circle Details",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),

            // Circle Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.network(
                circle.image,
                width: double.infinity,
                height: 220.h,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 24.h),

            // Name and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    circle.name,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                ),
                Text(
                  "\$${circle.price ?? "\$5.00"}",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    circle.address ??
                        "Grand city St. 100, New York, United States.",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),
            const Divider(color: Color(0xFFF0F0F0), thickness: 1),
            SizedBox(height: 20.h),

            // Description Section
            Text(
              "Description:",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              circle.description,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),

            SizedBox(height: 20.h),
            const Divider(color: Color(0xFFF0F0F0), thickness: 1),
            SizedBox(height: 20.h),

            // Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Members",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "See All",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Members List
            if (circle.detailedMembers != null)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: circle.detailedMembers!.take(3).length,
                itemBuilder: (context, index) {
                  return CircleMemberTile(
                    member: circle.detailedMembers![index],
                  );
                },
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  "No detailed member information available.",
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
