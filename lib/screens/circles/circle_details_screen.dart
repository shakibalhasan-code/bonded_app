import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/circle_controller.dart';
import '../../models/circle_model.dart';
import '../../widgets/circles/create_post_sheet.dart';
import '../../widgets/circles/circle_post_item.dart';
import '../../widgets/circles/circle_member_tile.dart';


class CircleDetailsScreen extends StatelessWidget {

  const CircleDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CircleModel circle = Get.arguments;
    final CircleController controller = Get.find<CircleController>();

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
          circle.name,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            icon: Icon(Icons.info_outline, color: AppColors.primary, size: 24.sp),
            onSelected: (value) {
              if (value == 'info') {
                _showCircleInfoBottomSheet(context, circle);
              } else if (value == 'members') {
                Get.toNamed(AppRoutes.CIRCLE_MEMBERS, arguments: circle.detailedMembers);
              }
            },
            itemBuilder: (context) => [
              _buildPopupMenuItem('info', Icons.info_outline, "Group Info"),
              const PopupMenuDivider(),
              _buildPopupMenuItem('members', Icons.people_outline, "Group Members"),
            ],
          ),
          SizedBox(width: 8.w),
        ],

      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                   SizedBox(height: 12.h),
                  // Today Chip
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9FF),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "Today",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Post Feed
                  Obx(() => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: circle.posts.length,
                        itemBuilder: (context, index) {
                          return CirclePostItem(post: circle.posts[index]);
                        },
                      )),
                ],
              ),
            ),
          ),
          
          // Bottom Input Bar
          _buildBottomInputBar(context, circle),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar(BuildContext context, CircleModel circle) {
    return GestureDetector(
      onTap: () => Get.bottomSheet(
        CreatePostSheet(circle: circle),
        isScrollControlled: true,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[100]!)),
        ),
        child: Row(
          children: [
            _buildInputIcon(Icons.mic_none),
            SizedBox(width: 12.w),
            _buildInputIcon(Icons.emoji_emotions_outlined),
            SizedBox(width: 12.w),
            _buildInputIcon(Icons.image_outlined),
            SizedBox(width: 12.w),
            _buildInputIcon(Icons.videocam_outlined),
            SizedBox(width: 16.w),
            const Spacer(),
            Icon(Icons.send_rounded, color: AppColors.primary, size: 28.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildInputIcon(IconData icon) {
    return Icon(icon, color: Colors.grey[500], size: 24.sp);
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, String title) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B0B3B), size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1B0B3B),
            ),
          ),
        ],
      ),
    );
  }

  void _showCircleInfoBottomSheet(BuildContext context, CircleModel circle) {

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "About Circle",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                circle.description,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              if (circle.address != null) ...[
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        circle.address!,
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 40),
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
                ...circle.detailedMembers!.take(3).map((member) => CircleMemberTile(member: member)).toList()
              else
                const Text("No members available"),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

