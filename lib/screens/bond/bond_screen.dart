import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:bonded_app/models/bond_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/bond_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../widgets/bond/bond_user_card.dart';
import '../../widgets/custom_search_field.dart';

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
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: CustomSearchField(
                controller: controller.searchController,
                hintText: "Search connections...",
                onChanged: (value) => controller.searchQuery.value = value,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildNearbyTab(controller),
                  _buildRequestTab(controller),
                  _buildMyBondTab(controller),
                ],
              ),
            ),
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
    return RefreshIndicator(
      onRefresh: controller.fetchNearbyPeople,
      child: Padding(
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
                () => controller.isLoadingNearby.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredNearbyPeople.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 400.h,
                            child: const Center(child: Text("No one nearby found")),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.filteredNearbyPeople.length,
                        itemBuilder: (context, index) {
                          return BondUserCard(
                            connection: controller.filteredNearbyPeople[index],
                            status: BondStatus.nearby,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTab(BondController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        if (controller.showOutgoingRequests.value) {
          await controller.fetchOutgoingRequests();
        } else {
          await controller.fetchIncomingRequests();
        }
      },
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    controller.showOutgoingRequests.value
                        ? "Bond Request Sent"
                        : "Bond Request for you",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                ),
                Obx(
                  () => TextButton(
                    onPressed: () => controller.showOutgoingRequests.toggle(),
                    child: Text(
                      controller.showOutgoingRequests.value
                          ? "View incoming"
                          : "View sent",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Obx(() {
                final isLoading = controller.showOutgoingRequests.value
                    ? controller.isLoadingOutgoing.value
                    : controller.isLoadingRequests.value;

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.filteredBondRequests;
                if (list.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400.h,
                        child: Center(
                          child: Text(
                            controller.showOutgoingRequests.value
                                ? "No outgoing requests"
                                : "No incoming requests",
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return BondUserCard(
                      connection: list[index],
                      status: controller.showOutgoingRequests.value
                          ? BondStatus.outgoing
                          : BondStatus.requested,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBondTab(BondController controller) {
    return RefreshIndicator(
      onRefresh: controller.fetchMyBonds,
      child: Padding(
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
                () => controller.isLoadingMyBonds.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredMyBonds.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 400.h,
                            child: const Center(child: Text("You have no bonds yet")),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.filteredMyBonds.length,
                        itemBuilder: (context, index) {
                          return BondUserCard(
                            connection: controller.filteredMyBonds[index],
                            status: BondStatus.bonded,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
