import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

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
          "Reviews",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
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
        child: ElevatedButton(
          onPressed: () => Get.toNamed(AppRoutes.WRITE_REVIEW),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          child: Text(
            "Write a Review",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            // Rating Overview
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        "4.8",
                        style: GoogleFonts.inter(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B0B3B),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: List.generate(5, (index) => Icon(
                          Icons.star,
                          color: index < 4 ? Colors.orange : Colors.orange.withOpacity(0.3),
                          size: 20.sp,
                        )),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "(4.8k reviews)",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 32.w),
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar(5, 0.9),
                        _buildRatingBar(4, 0.7),
                        _buildRatingBar(3, 0.4),
                        _buildRatingBar(2, 0.2),
                        _buildRatingBar(1, 0.1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            SizedBox(height: 10.h),

            // Reviews List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => SizedBox(height: 24.h),
              itemBuilder: (context, index) => _buildReviewItem(),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int star, double progress) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(star.toString(), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: AppColors.primary,
                minHeight: 10.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde"),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Andrew Ainsley",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  Text(
                    "andrew_ainsley@gmail.com",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Row(
              children: List.generate(5, (index) => Icon(
                Icons.star,
                color: Colors.orange,
                size: 16.sp,
              )),
            ),
            SizedBox(width: 12.w),
            Text(
              "4 month ago",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore 😍😍",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
