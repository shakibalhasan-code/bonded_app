import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../core/theme/app_colors.dart';

import '../../core/routes/app_routes.dart';
import 'package:get/get.dart';

class BookedEventCard extends StatelessWidget {
  final BookedEventModel event;

  const BookedEventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final eventModel = EventModel(
          id: event.eventId,
          title: event.title,
          imageUrl: event.coverImage,
          date: event.eventDate,
          time: event.eventTime,
          venueName: event.venueName,
          address: event.address,
          city: event.city,
          country: event.country,
          category: event.eventVisibility == 'virtual'
              ? EventCategory.virtual
              : EventCategory.inPerson,
        );
        Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: eventModel);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            ),
            child: Image.network(
              event.coverImage,
              width: 100.w,
              height: 110.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100.w,
                height: 110.h,
                color: const Color(0xFFFAF7FF),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.primary.withValues(alpha: 0.4),
                  size: 28.sp,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: event.isFree
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      event.isFree ? 'Free' : 'Paid',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: event.isFree ? Colors.green : AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12.sp, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text(
                        '${event.eventDate}  ${event.eventTime}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if ((event.venueName ?? event.address) != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12.sp, color: Colors.grey[500]),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            event.venueName ?? event.address!,
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
                  SizedBox(height: 6.h),
                  Text(
                    '${event.seatCount} seat${event.seatCount != 1 ? 's' : ''}  ·  ${event.ticketCount} ticket${event.ticketCount != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
