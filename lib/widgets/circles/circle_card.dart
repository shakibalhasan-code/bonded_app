import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/circle_model.dart';
import '../app_button.dart';

class CircleCard extends StatelessWidget {
  final CircleModel circle;
  final VoidCallback onTap;

  const CircleCard({Key? key, required this.circle, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  child: Image.network(
                    circle.image,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (circle.isLocked)
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                if (circle.isOwner)
                  Positioned(top: 8.h, right: 8.w, child: _buildOwnerMenu()),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          circle.name,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHeading,
                          ),
                        ),
                      ),
                      _buildAvatarStack(circle.memberAvatars),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    circle.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: circle.tags.map((tag) => _buildTag(tag)).toList(),
                  ),
                  SizedBox(height: 16.h),
                  if (circle.isLocked)
                    _buildUnlockAction()
                  else if (!circle.isJoined && !circle.isOwner)
                    AppButton(text: "Join Circle", onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<String> avatars) {
    final displayAvatars = avatars.take(5).toList();
    return SizedBox(
      height: 24.w,
      width: (displayAvatars.length * 16.w) + 12.w,
      child: Stack(
        children: [
          ...displayAvatars.asMap().entries.map((entry) {
            return Positioned(
              left: entry.key * 14.w,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 12.r,
                  backgroundImage: NetworkImage(entry.value),
                ),
              ),
            );
          }).toList(),
          if (avatars.length > 5)
            Positioned(
              left: 5 * 14.w,
              child: Container(
                height: 24.w,
                width: 24.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${avatars.length - 5}+",
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.buttonSecondary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildUnlockAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 150.w,
          child: AppButton(
            text: "Unlock Circle",
            onPressed: () => Get.toNamed(AppRoutes.SUBSCRIPTION_PLAN),
          ),
        ),
        Text(
          "Price: ${circle.price ?? '${4.99}'}",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_vert, color: AppColors.primary, size: 18.sp),
      ),
      onSelected: (value) {},
      itemBuilder: (context) => [
        _buildMenuItem(Icons.edit_outlined, "Edit Circle"),
        _buildMenuItem(Icons.delete_outline, "Delete Circle"),
        _buildMenuItem(Icons.lock_open_outlined, "Unlock Circle"),
        _buildMenuItem(Icons.person_add_outlined, "Add Member"),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String title) {
    return PopupMenuItem(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey[700]),
          SizedBox(width: 12.w),
          Text(title, style: GoogleFonts.inter(fontSize: 14.sp)),
        ],
      ),
    );
  }
}
