import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';

class CircleHeader extends StatelessWidget {
  const CircleHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            AppAssets.appLogo,
            height: 32.h,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          Text(
            "Circles",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
          Row(
            children: [
              _buildIcon(
                Icons.person_outline,
                onTap: () => Get.toNamed(AppRoutes.PROFILE),
              ),
              SizedBox(width: 12.w),
              _buildIcon(
                Icons.notifications_outlined,
                onTap: () => Get.toNamed(AppRoutes.NOTIFICATION),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
    );
  }
}
