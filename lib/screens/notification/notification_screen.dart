import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/notification_controller.dart';
import '../../widgets/notification/notification_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

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
          "Notification",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
      ),
      body: Obx(() {
        final sections = controller.notificationsByDay.keys.toList();
        
        return ListView.builder(
          itemCount: sections.length,
          itemBuilder: (context, sectionIndex) {
            final day = sections[sectionIndex];
            final notifications = controller.notificationsByDay[day]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Section Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),
                
                // Notifications for this day
                ...notifications.map((notification) => NotificationTile(
                  notification: notification,
                  onTap: () => controller.markAsRead(notification.id),
                )).toList(),
              ],
            );
          },
        );
      }),
    );
  }
}
