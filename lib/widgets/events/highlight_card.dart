import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/highlight_model.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/theme/app_colors.dart';

class HighlightCard extends StatelessWidget {
  final HighlightModel highlight;
  final VoidCallback onTap;

  const HighlightCard({
    Key? key,
    required this.highlight,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = highlight.images ?? [];
    final videos = highlight.videos ?? [];
    
    String? displayImage = images.isNotEmpty ? AppUrls.imageUrl(images.first.url) : null;
    bool hasVideo = videos.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Preview
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                      image: displayImage != null
                          ? DecorationImage(
                              image: NetworkImage(displayImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[200],
                    ),
                  ),
                  if (hasVideo)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow, color: Colors.white, size: 20.sp),
                      ),
                    ),
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        "${(images.length + videos.length)} items",
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Caption & Creator
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight.caption ?? "No caption",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeading,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8.r,
                        backgroundImage: highlight.creator?.avatar != null
                            ? NetworkImage(AppUrls.imageUrl(highlight.creator!.avatar))
                            : null,
                        child: highlight.creator?.avatar == null
                            ? Icon(Icons.person, size: 10.sp)
                            : null,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          highlight.creator?.fullName ?? "Host",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
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
