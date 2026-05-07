import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/highlight_model.dart';
import '../../core/constants/app_endpoints.dart';
import '../../widgets/events/media_viewers.dart';

class EventHighlightDetailsScreen extends StatelessWidget {
  const EventHighlightDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HighlightModel highlight = Get.arguments;

    final List<HighlightVideo> videos = highlight.videos ?? [];
    final List<HighlightImage> images = highlight.images ?? [];

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
          highlight.event?.title ?? "Highlight Details",
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
              highlight.event?.title ?? "N/A",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 24.h),

            // Video Highlights Section
            if (videos.isNotEmpty) ...[
              _buildSectionTitle("Video Highlights"),
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
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final videoUrl = AppUrls.imageUrl(videos[index].url);
                  return GestureDetector(
                    onTap: () => Get.to(() => MockVideoPlayer(videoUrl: videoUrl)),
                    child: _buildVideoThumbnail(videoUrl),
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],

            // Images Section
            if (images.isNotEmpty) ...[
              _buildSectionTitle("Images"),
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
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final imageUrl = AppUrls.imageUrl(images[index].url);
                  return GestureDetector(
                    onTap: () => Get.to(() => FullScreenImageViewer(imageUrl: imageUrl)),
                    child: _buildImageThumbnail(imageUrl),
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],

            // Caption Section
            if (highlight.caption != null && highlight.caption!.isNotEmpty) ...[
              _buildSectionTitle("Caption"),
              SizedBox(height: 12.h),
              Text(
                highlight.caption!,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: const Color(0xFF1B0B3B),
                  height: 1.6,
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Tagged Attendees
            if (highlight.taggedAttendees != null && highlight.taggedAttendees!.isNotEmpty) ...[
              _buildSectionTitle("Tagged Attendees"),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                children: highlight.taggedAttendees!.map((user) => Chip(
                  avatar: CircleAvatar(
                    backgroundImage: NetworkImage(AppUrls.imageUrl(user.avatar)),
                  ),
                  label: Text(user.fullName ?? "User"),
                )).toList(),
              ),
              SizedBox(height: 24.h),
            ],

            // Tagged Circles
            if (highlight.taggedCircles != null && highlight.taggedCircles!.isNotEmpty) ...[
              _buildSectionTitle("Tagged Circles"),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                children: highlight.taggedCircles!.map((circle) => Chip(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  label: Text(circle.name ?? "Circle", style: TextStyle(color: AppColors.primary)),
                )).toList(),
              ),
              SizedBox(height: 24.h),
            ],
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

  Widget _buildVideoThumbnail(String url) {
    return Container(
      width: 120.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFF7128D0).withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.play_arrow, color: Colors.white, size: 24.sp),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
