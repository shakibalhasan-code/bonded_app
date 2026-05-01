import 'package:bonded_app/models/circle_model.dart';
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
import '../../widgets/circles/circle_selection_dialog.dart';

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
            Obx(
              () => CircleTabBar(
                selectedIndex: controller.selectedTab.value,
                tabs: const ["Public Circle", "Private Circle", "My Circle"],
                onTabChanged: controller.changeTab,
              ),
            ),
            Expanded(
              child: Obx(() {
                // Determine loading state
                bool isLoading = false;
                if (controller.selectedTab.value == 0) {
                  isLoading = controller.isLoadingPublic.value;
                } else if (controller.selectedTab.value == 1) {
                  isLoading = controller.isLoadingPrivate.value;
                } else if (controller.selectedTab.value == 2) {
                  isLoading = controller.myCircleSubTab.value == 0 
                      ? controller.isLoadingCreated.value 
                      : controller.isLoadingJoined.value;
                }

                if (isLoading && 
                   ((controller.selectedTab.value == 0 && controller.publicCircles.isEmpty) ||
                    (controller.selectedTab.value == 1 && controller.privateCircles.isEmpty) ||
                    (controller.selectedTab.value == 2 && 
                      ((controller.myCircleSubTab.value == 0 && controller.createdCircles.isEmpty) ||
                       (controller.myCircleSubTab.value == 1 && controller.joinedCircles.isEmpty))))) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.selectedTab.value == 2) {
                  return _buildMyCirclesView(controller);
                }

                final circles = controller.selectedTab.value == 0
                    ? controller.filteredPublicCircles
                    : controller.filteredPrivateCircles;

                return RefreshIndicator(
                  onRefresh: () => controller.fetchCircles(
                    visibility: controller.selectedTab.value == 0 ? 'public' : 'private'
                  ),
                  child: _buildCircleList(circles, controller),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            Get.toNamed(
              AppRoutes.CREATE_CIRCLE,
              arguments: {'isPublic': false},
            );
          },
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildCircleList(
    List<CircleModel> circles,
    CircleController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Circle Nearby",
          circles,
          controller,
          controller.selectedTab.value == 0
              ? "Public Circles"
              : "Private Circles",
        ),
        Expanded(
          child: circles.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: circles.length,
                  padding: EdgeInsets.only(bottom: 100.h),
                  itemBuilder: (context, index) {
                    final circle = circles[index];
                    return CircleCard(
                      circle: circle,
                      onTap: () {
                        if (controller.selectedTab.value == 0 ||
                            controller.selectedTab.value == 1) {
                          Get.toNamed(
                            AppRoutes.PUBLIC_CIRCLE_DETAILS,
                            arguments: circle,
                          );
                        } else {
                          Get.toNamed(
                            AppRoutes.JOINED_CIRCLE_DETAILS,
                            arguments: circle,
                          );
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMyCirclesView(CircleController controller) {
    final circles = controller.myCircleSubTab.value == 0
        ? controller.filteredMyCreatedCircles
        : controller.filteredMyJoinedCircles;

    return RefreshIndicator(
      onRefresh: () => controller.fetchCircles(
        scope: controller.myCircleSubTab.value == 0 ? 'created' : 'joined'
      ),
      child: Column(
        children: [
          CircleSubTabBar(
            selectedIndex: controller.myCircleSubTab.value,
            tabs: const ["Created Circle", "Joined Circle"],
            onTabChanged: controller.changeMyCircleSubTab,
          ),
          _buildSectionHeader(
            controller.myCircleSubTab.value == 0
                ? "My Created Circles"
                : "My Joined Circles",
            circles,
            controller,
            controller.myCircleSubTab.value == 0
                ? "Created Circles"
                : "Joined Circles",
          ),
          Expanded(
            child: circles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: circles.length,
                    padding: EdgeInsets.only(bottom: 100.h),
                    itemBuilder: (context, index) {
                      final circle = circles[index];
                      return CircleCard(
                        circle: circle,
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.JOINED_CIRCLE_DETAILS,
                            arguments: circle,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    List<CircleModel> circles,
    CircleController controller,
    String allCirclesTitle,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(() {
        final isSearch = controller.isSearchVisible.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isSearch)
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
            if (isSearch)
              Expanded(
                child: Container(
                  height: 40.h,
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.searchQuery.value = value,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search circles...",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => controller.toggleSearch(),
                  child: Icon(
                    isSearch ? Icons.close : Icons.search,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                if (!isSearch) ...[
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      AppRoutes.ALL_CIRCLES,
                      arguments: {'title': allCirclesTitle, 'circles': circles},
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
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "No circles found",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
