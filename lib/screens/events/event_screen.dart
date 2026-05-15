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
import '../../widgets/events/highlight_card.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/events/my_events_sub_nav.dart';
import '../../widgets/events/e_ticket_card.dart';
import '../../widgets/events/booked_event_card.dart';
import '../../widgets/events/wallet_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_search_field.dart';

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
          child: SvgPicture.asset(
            AppAssets.appLogo,
            height: 32.h,
            width: 32.w,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          "Events",
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
      body: Column(
        children: [
          _buildMainTabs(controller),
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildPublicEvents(controller);
              } else {
                return _buildMyEvents(controller);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 100.h),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () => _showCreateEventDialog(context, controller),
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildPublicEvents(EventController controller) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        _buildSearchBar(controller),
        SizedBox(height: 16.h),
        CategoryFilter(
          categories: const [
            "In-Person Events",
            "Virtual Events",
            "Event Highlights",
            "Bonded Events",
          ],
          selectedIndex: controller.selectedCategory.value,
          onCategoryChanged: controller.changeCategory,
        ),
        SizedBox(height: 24.h),
        Expanded(
          child: controller.selectedCategory.value == 3
              ? _buildComingSoon()
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.selectedCategory.value == 1
                                ? "Upcoming Events"
                                : controller.selectedCategory.value == 2
                                ? "Event Highlights"
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
                            icon: Icon(
                              Icons.filter_list,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                            onPressed: () =>
                                Get.toNamed(AppRoutes.EVENT_FILTER),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: controller.refreshData,
                          color: AppColors.primary,
                          child:
                              (controller.selectedCategory.value == 2
                                  ? controller.publicHighlights.isEmpty
                                  : controller.filteredEvents.isEmpty)
                              ? _buildEmptyEventsState()
                              : GridView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    20.w,
                                    0,
                                    20.w,
                                    100.h,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.8,
                                        crossAxisSpacing: 16.w,
                                        mainAxisSpacing: 16.h,
                                      ),
                                  itemCount:
                                      controller.selectedCategory.value == 2
                                      ? controller.filteredHighlights.length
                                      : controller.filteredEvents.length,
                                  itemBuilder: (context, index) {
                                    if (controller.selectedCategory.value ==
                                        2) {
                                      final highlight =
                                          controller.filteredHighlights[index];
                                      return HighlightCard(
                                        highlight: highlight,
                                        onTap: () => Get.toNamed(
                                          AppRoutes.EVENT_HIGHLIGHT_DETAILS,
                                          arguments: highlight,
                                        ),
                                      );
                                    }
                                    final event =
                                        controller.filteredEvents[index];
                                    return EventCard(
                                      event: event,
                                      onTap: () {
                                        if (event.isExternal) {
                                          _showExternalEventBottomSheet(
                                            context,
                                            event,
                                          );
                                        } else {
                                          Get.toNamed(
                                            AppRoutes.EVENT_DETAILS,
                                            arguments: event,
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                        );
                      }),
                    ),
                  ],
                ),
        ),
      ],
    ));
  }

  Widget _buildMyEvents(EventController controller) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        _buildSearchBar(controller),
        SizedBox(height: 16.h),
        MyEventsSubNav(
          selectedIndex: controller.selectedMyEventTab.value,
          onTabChanged: controller.changeMyEventTab,
        ),
        SizedBox(height: 24.h),
        Expanded(child: _buildSubTabContent(controller)),
      ],
    ));
  }

  Widget _buildSubTabContent(EventController controller) {
    final subTab = controller.selectedMyEventTab.value;

    if (subTab == 0) {
      final list = controller.filteredEvents;
      return Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primary,
          child: list.isEmpty
              ? _buildEmptyEventsState()
              : GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                    showOptions: true,
                    onTap: () {
                      if (list[index].isExternal) {
                        _showExternalEventBottomSheet(context, list[index]);
                      } else {
                        Get.toNamed(
                          AppRoutes.EVENT_DETAILS,
                          arguments: list[index],
                        );
                      }
                    },
                  ),
                ),
        );
      });
    } else if (subTab == 1) {
      return Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primary,
          child: controller.bookedEvents.isEmpty
              ? _buildEmptyEventsState(message: "No booked events found")
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                  itemCount: controller.bookedEvents.length,
                  itemBuilder: (context, index) =>
                      BookedEventCard(event: controller.bookedEvents[index]),
                ),
        );
      });
    } else if (subTab == 2) {
      return Obx(() => RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: controller.filteredTickets.isEmpty
            ? _buildEmptyEventsState(message: "No tickets found")
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                itemCount: controller.filteredTickets.length,
                itemBuilder: (context, index) =>
                    ETicketCard(ticket: controller.filteredTickets[index]),
              ),
      ));
    } else {
      return Obx(() {
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WalletDashboardCard(
                  wallet: controller.wallet.value,
                  isConnected: controller.isStripeConnected.value,
                  isOnboarding: controller.isOnboardingStripe.value,
                  isChecking: controller.isCheckingStripe.value,
                  onConnect: () => controller.connectStripe(),
                  onCheckStatus: () => controller.checkStripeStatus(),
                ),
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
          ),
        );
      });
    }
  }

  void _showExternalEventBottomSheet(BuildContext context, EventModel event) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 20.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    event.imageUrl,
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 100.w,
                      height: 100.w,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "External Event",
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeading,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            "${event.rating?.toStringAsFixed(1) ?? '0.0'} (${event.reviewsCount ?? 0} reviews)",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            if (event.description != null && event.description!.isNotEmpty) ...[
              Text(
                "About this Event",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                event.description!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Price from",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      event.price != null && event.price! > 0
                          ? "${event.price!.toStringAsFixed(0)}\$"
                          : "FREE",
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (event.externalLink != null) {
                      final uri = Uri.parse(event.externalLink!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Get.snackbar("Error", "Could not launch external link");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Book Event",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.open_in_new, size: 16.sp),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCreateEventDialog(
    BuildContext context,
    EventController controller,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.h,
                height: 80.h,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 48.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                "Confirmation Required!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,

                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Select which event you want to create? After selection you will proceed with the flow accordingly.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.CREATE_EVENT,
                    arguments: {'isVirtual': false, 'category': 'Celebrations'},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "In-Person Event",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.CREATE_EVENT,
                    arguments: {'isVirtual': true, 'category': 'celebrations'},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Bonded Virtual Event",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildComingSoon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_outlined,
              color: AppColors.primary,
              size: 64.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Coming Soon",
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeading,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "We are working on bringing you exclusive Bonded Events. Stay tuned!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsState({String message = "No events found"}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 400.h,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
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

  Widget _buildSearchBar(EventController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: CustomSearchField(
        controller: controller.searchController,
        hintText: "Search events, cities, or venues...",
        onChanged: (value) => controller.updateSearch(value),
        onClear: () => controller.clearSearch(),
        onSearch: () =>
            controller.fetchEvents(searchTerm: controller.searchQuery.value),
      ),
    );
  }
}
