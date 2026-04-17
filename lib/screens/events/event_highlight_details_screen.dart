import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/event_model.dart';

class EventHighlightDetailsScreen extends StatelessWidget {
  const EventHighlightDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EventModel event = Get.arguments;

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
          event.title,
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
            // Event Name Section
            _buildSectionTitle("Event Name"),
            SizedBox(height: 8.h),
            Text(
              "Weekend Hangouts Circle",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 24.h),

            // Video Highlights Section
            _buildSectionTitle("Video Highlights"),
            SizedBox(height: 12.h),
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildVideoThumbnail();
                },
              ),
            ),
            SizedBox(height: 24.h),

            // Add Images Section
            _buildSectionTitle("Add Images"),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.8,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildImageThumbnail(index);
              },
            ),
            SizedBox(height: 24.h),

            // Caption Section
            _buildSectionTitle("Caption"),
            SizedBox(height: 12.h),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF1B0B3B).withOpacity(0.8),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B0B3B),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1501281668745-f7f57925c3b4'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.play_arrow, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    final List<String> images = [
      'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14',
      'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
      'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4',
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        image: DecorationImage(
          image: NetworkImage(images[index]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
