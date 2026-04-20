import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/bond_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../widgets/bond/bond_user_card.dart';

class BondScreen extends StatelessWidget {
  const BondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BondController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 80.h,
          title: Row(
            children: [
              SvgPicture.asset(
                AppAssets.appLogo,
                width: 32.w,
                height: 32.h,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Bonded Connections",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
            ],
          ),
          actions: [
            _buildAppBarAction(
              Icons.person,
              onTap: () => Get.toNamed(AppRoutes.PROFILE),
            ),
            SizedBox(width: 12.w),
            _buildAppBarAction(
              Icons.notifications,
              onTap: () => Get.toNamed(AppRoutes.NOTIFICATION),
            ),
            SizedBox(width: 16.w),
          ],
          bottom: TabBar(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[500],
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "Nearby People"),
              Tab(text: "Bond Request"),
              Tab(text: "My Bond"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNearbyTab(controller),
            _buildRequestTab(controller),
            _buildMyBondTab(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
    );
  }

  Widget _buildNearbyTab(BondController controller) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Meet People Nearby",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.NEARBY_PEOPLE),
                child: Text(
                  "See All",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.nearbyPeople.length,
                itemBuilder: (context, index) {
                  return BondUserCard(user: controller.nearbyPeople[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTab(BondController controller) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bond Request for you",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B0B3B),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.bondRequests.length,
                itemBuilder: (context, index) {
                  return BondUserCard(user: controller.bondRequests[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBondTab(BondController controller) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "People I know",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B0B3B),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.myBonds.length,
                itemBuilder: (context, index) {
                  return BondUserCard(user: controller.myBonds[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
