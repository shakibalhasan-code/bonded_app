import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/circle_controller.dart';
import '../../widgets/circles/circle_header.dart';
import '../../widgets/circles/circle_tab_bar.dart';
import '../../widgets/circles/circle_card.dart';

class CirclesScreen extends StatelessWidget {
  const CirclesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CircleController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CircleHeader(),
            Obx(() => CircleTabBar(
                  selectedIndex: controller.selectedTab.value,
                  tabs: const ["Public Circle", "Private Circle", "My Circle"],
                  onTabChanged: controller.changeTab,
                )),
            Expanded(
              child: Obx(() {
                if (controller.selectedTab.value == 2) {
                  return _buildMyCirclesView(controller);
                }
                
                final circles = controller.selectedTab.value == 0
                    ? controller.publicCircles
                    : controller.privateCircles;
                
                return _buildCircleList(circles, controller);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCircleList(List circles, CircleController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Circle Nearby",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.ALL_CIRCLES,
                  arguments: {
                    'title': controller.selectedTab.value == 0 ? "Public Circles" : "Private Circles",
                    'circles': circles,
                  },
                ),
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
        ),
        Expanded(
          child: ListView.builder(
            itemCount: circles.length,
            padding: EdgeInsets.only(bottom: 100.h),
            itemBuilder: (context, index) {
              final circle = circles[index];
              return CircleCard(
                circle: circle,
                onTap: () => Get.toNamed(AppRoutes.CIRCLE_DETAILS, arguments: circle),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyCirclesView(CircleController controller) {
    return Column(
      children: [
        CircleSubTabBar(
          selectedIndex: controller.myCircleSubTab.value,
          tabs: const ["Created Circle", "Joined Circle"],
          onTabChanged: controller.changeMyCircleSubTab,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.myCircleSubTab.value == 0 ? "My Created Circles" : "My Joined Circles",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.ALL_CIRCLES,
                  arguments: {
                    'title': controller.myCircleSubTab.value == 0 ? "Created Circles" : "Joined Circles",
                    'circles': controller.myCircleSubTab.value == 0
                        ? controller.myCreatedCircles
                        : controller.myJoinedCircles,
                  },
                ),
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
        ),
        Expanded(
          child: ListView.builder(
            itemCount: controller.myCircleSubTab.value == 0
                ? controller.myCreatedCircles.length
                : controller.myJoinedCircles.length,
            padding: EdgeInsets.only(bottom: 100.h),
            itemBuilder: (context, index) {
              final circle = controller.myCircleSubTab.value == 0
                  ? controller.myCreatedCircles[index]
                  : controller.myJoinedCircles[index];
              return CircleCard(
                circle: circle,
                onTap: () => Get.toNamed(AppRoutes.CIRCLE_DETAILS, arguments: circle),
              );
            },
          ),
        ),
      ],
    );
  }
}
