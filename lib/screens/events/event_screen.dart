import 'package:bonded_app/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../controllers/event_controller.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/events/category_filter.dart';
import '../../core/routes/app_routes.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: SvgPicture.asset(AppAssets.appLogo, width: 30.w),
        ),
        title: Text(
          "Bonded Events",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_outline,
              color: Colors.grey[600],
              size: 28.sp,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Colors.grey[600],
              size: 28.sp,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Tabs
          _buildMainTabs(controller),
          SizedBox(height: 24.h),

          // Category Filters
          Obx(
            () => CategoryFilter(
              categories: const [
                "In-Person Events",
                "Virtual Events",
                "Event Highlights",
              ],
              selectedIndex: controller.selectedCategory.value,
              onCategoryChanged: controller.changeCategory,
            ),
          ),
          SizedBox(height: 24.h),

          // List Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  String title = "Explore Events Nearby";
                  if (controller.selectedCategory.value == 1)
                    title = "Upcoming Events";
                  if (controller.selectedCategory.value == 2)
                    title = "Recently Happened in Your City";
                  return Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeading,
                    ),
                  );
                }),
                Icon(Icons.filter_list, color: AppColors.primary, size: 24.sp),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Event Grid
          Expanded(
            child: Obx(() {
              final list = controller.filteredEvents;
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return EventCard(
                    event: list[index],
                    onTap: () {
                      if (list[index].category == EventCategory.highlights) {
                        Get.toNamed(
                          AppRoutes.EVENT_HIGHLIGHT_DETAILS,
                          arguments: list[index],
                        );
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildMainTabs(EventController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTabItem(
              "Events",
              controller.selectedTab.value == 0,
              () => controller.changeTab(0),
            ),
            _buildTabItem(
              "My Events",
              controller.selectedTab.value == 1,
              () => controller.changeTab(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}
