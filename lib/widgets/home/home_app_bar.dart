import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import 'package:get/get.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: SvgPicture.asset(
          AppAssets.appLogo,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      ),
      title: Text(
        "Home",
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textHeading,
        ),
      ),
      centerTitle: true,
      actions: [
        _buildActionIcon(
          Icons.person_outline,
          onTap: () => Get.toNamed(AppRoutes.PROFILE),
        ),
        SizedBox(width: 12.w),
        _buildActionIcon(
          Icons.notifications_outlined,
          onTap: () => Get.toNamed(AppRoutes.NOTIFICATION),
        ),
        SizedBox(width: 20.w),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7FF), // Subtle background
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
