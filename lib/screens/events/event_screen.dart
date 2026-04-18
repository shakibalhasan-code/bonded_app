import 'package:bonded_app/models/event_model.dart';
import 'package:bonded_app/widgets/events/category_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../controllers/event_controller.dart';
import '../../widgets/events/event_card.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/events/my_events_sub_nav.dart';
import '../../widgets/events/e_ticket_card.dart';
import '../../widgets/events/wallet_widgets.dart';

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
            onPressed: () => Get.toNamed(AppRoutes.PROFILE),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Colors.grey[600],
              size: 28.sp,
            ),
            onPressed: () => Get.toNamed(AppRoutes.NOTIFICATION),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: Obx(() {
        if (controller.selectedTab.value == 0) {
          return _buildPublicEvents(controller);
        } else {
          return _buildMyEvents(controller);
        }
      }),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () => Get.toNamed(
            AppRoutes.CREATE_EVENT,
            arguments: {'isVirtual': controller.selectedCategory.value == 1},
          ),
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildPublicEvents(EventController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainTabs(controller),
        SizedBox(height: 24.h),
        CategoryFilter(
          categories: const [
            "In-Person Events",
            "Virtual Events",
            "Event Highlights",
          ],
          selectedIndex: controller.selectedCategory.value,
          onCategoryChanged: controller.changeCategory,
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.selectedCategory.value == 1
                    ? "Upcoming Events"
                    : controller.selectedCategory.value == 2
                    ? "Recently Happened"
                    : "Explore Events Nearby",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.filter_list, color: AppColors.primary, size: 24.sp),
                onPressed: () => Get.toNamed(AppRoutes.EVENT_FILTER),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: controller.filteredEvents.length,
            itemBuilder: (context, index) {
              final event = controller.filteredEvents[index];
              return EventCard(
                event: event,
                onTap: () => Get.toNamed(
                  event.category == EventCategory.highlights
                      ? AppRoutes.EVENT_HIGHLIGHT_DETAILS
                      : AppRoutes.EVENT_DETAILS,
                  arguments: event,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyEvents(EventController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainTabs(controller),
        SizedBox(height: 24.h),
        MyEventsSubNav(
          selectedIndex: controller.selectedMyEventTab.value,
          onTabChanged: controller.changeMyEventTab,
        ),
        SizedBox(height: 24.h),
        Expanded(child: _buildSubTabContent(controller)),
      ],
    );
  }

  Widget _buildSubTabContent(EventController controller) {
    final subTab = controller.selectedMyEventTab.value;

    if (subTab == 0 || subTab == 1) {
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
        itemBuilder: (context, index) => EventCard(
          event: list[index],
          showOptions: subTab == 0,
          onTap: () =>
              Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: list[index]),
        ),
      );
    } else if (subTab == 2) {
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
        itemCount: controller.tickets.length,
        itemBuilder: (context, index) =>
            ETicketCard(ticket: controller.tickets[index]),
      );
    } else {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WalletDashboardCard(balance: 958476.50),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transaction History",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
                Icon(
                  Icons.file_download_outlined,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...controller.transactions
                .map((tr) => TransactionTile(transaction: tr))
                .toList(),
          ],
        ),
      );
    }
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
