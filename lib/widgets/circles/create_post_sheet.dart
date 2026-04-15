import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/circle_model.dart';
import '../../controllers/circle_controller.dart';

class CreatePostSheet extends StatelessWidget {
  final CircleModel circle;

  const CreatePostSheet({Key? key, required this.circle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CircleController>();
    final textController = TextEditingController();

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          SizedBox(height: 20.h),

          // Title
          Text(
            "Create Post",
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 16.h),

          // User Header
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=andrew'),
              ),
              SizedBox(width: 12.w),
              Text(
                "Andrew Ainsley",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Input
          TextField(
            controller: textController,
            maxLines: 6,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textHeading,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              border: InputBorder.none,
              hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
            ),
          ),
          
          const Divider(),
          SizedBox(height: 16.h),

          // Footer Actions
          Row(
            children: [
              _buildActionIcon(Icons.mic_none),
              SizedBox(width: 16.w),
              _buildActionIcon(Icons.emoji_emotions_outlined),
              SizedBox(width: 16.w),
              _buildActionIcon(Icons.image_outlined),
              SizedBox(width: 16.w),
              _buildActionIcon(Icons.videocam_outlined),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.createPost(circle, textController.text),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 24.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Icon(icon, color: Colors.grey[500], size: 26.sp);
  }
}
