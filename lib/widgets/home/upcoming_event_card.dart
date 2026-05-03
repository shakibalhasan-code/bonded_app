import 'package:bonded_app/models/event_model.dart';
import 'package:bonded_app/screens/events/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';

class UpcomingEventCard extends StatelessWidget {
  final EventModel event;

  const UpcomingEventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => EventDetailsScreen(event: event)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: event.imageUrl.isNotEmpty 
                ? Image.network(
                    event.imageUrl,
                    height: 100.h,
                    width: 100.w,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 100.h,
                    width: 100.w,
                    color: Colors.grey[200],
                    child: Icon(Icons.event, color: Colors.grey[400]),
                  ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeading,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "${event.date ?? 'No date'} , ${event.time ?? 'No time'}",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16.sp, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          event.address ?? event.city ?? 'Location TBD',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
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
