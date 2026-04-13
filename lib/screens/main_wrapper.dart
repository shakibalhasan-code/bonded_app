import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/main_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_assets.dart';
import 'home/home_screen.dart';
import 'circles/circles_screen.dart';
import 'bond/bond_screen.dart';
import 'messages/messages_screen.dart';
import 'events/event_screen.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());

    final List<Widget> screens = [
      const HomeScreen(),
      const CirclesScreen(),
      const BondScreen(),
      const MessagesScreen(),
      const EventScreen(),
    ];

    return Scaffold(
      extendBody: true, // Allows content to flow behind the bottom nav
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: screens,
          )),
      bottomNavigationBar: _GlassmorphismBottomNav(),
    );
  }
}

class _GlassmorphismBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                      icon: AppAssets.homeIcon,
                      label: "Home",
                      isActive: controller.currentIndex.value == 0,
                      onTap: () => controller.changeIndex(0),
                    ),
                    _BottomNavItem(
                      icon: AppAssets.circlesIcon,
                      label: "Circles",
                      isActive: controller.currentIndex.value == 1,
                      onTap: () => controller.changeIndex(1),
                    ),
                    _BottomNavItem(
                      icon: AppAssets.bondIcon,
                      label: "Bond",
                      isActive: controller.currentIndex.value == 2,
                      onTap: () => controller.changeIndex(2),
                    ),
                    _BottomNavItem(
                      icon: AppAssets.messagesIcon,
                      label: "Messages",
                      isActive: controller.currentIndex.value == 3,
                      onTap: () => controller.changeIndex(3),
                    ),
                    _BottomNavItem(
                      icon: AppAssets.eventIcon,
                      label: "Event",
                      isActive: controller.currentIndex.value == 4,
                      onTap: () => controller.changeIndex(4),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            height: 24.sp,
            width: 24.sp,
            colorFilter: ColorFilter.mode(
              isActive ? AppColors.primary : Colors.grey[400]!,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : Colors.grey[500]!,
            ),
          ),
        ],
      ),
    );
  }
}
