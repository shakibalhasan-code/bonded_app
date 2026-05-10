import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/section_header.dart';
import '../../widgets/circles/circle_post_item.dart';
import '../../widgets/circles/circle_card.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/home/upcoming_event_card.dart';
import '../../widgets/bond/bond_user_card.dart';
import '../../models/bond_user_model.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchHomeData(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Circle Posts (Circle Highlights) ──────────────────────
              Obx(() {
                if (controller.circleHighlights.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: "Circle Highlights"),
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.circleHighlights.length,
                      itemBuilder: (context, index) {
                        return CirclePostItem(
                          post: controller.circleHighlights[index],
                          circle: null, // no CircleModel context on home feed
                          showCircleName: true,
                        );
                      },
                    ),
                  ],
                );
              }),

              // ── Discovery Circles ──────────────────────────────────────
              Obx(() {
                if (controller.discoveryCircles.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: "Circles You May Like"),
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.discoveryCircles.length,
                      itemBuilder: (context, index) {
                        final circle = controller.discoveryCircles[index];
                        return CircleCard(
                          circle: circle,
                          onTap: () => Get.toNamed(
                            circle.isJoined.value
                                ? AppRoutes.JOINED_CIRCLE_DETAILS
                                : AppRoutes.PUBLIC_CIRCLE_DETAILS,
                            arguments: circle,
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
              
              // Upcoming Events Section
              Obx(() {
                if (controller.upcomingEvents.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: "Upcoming Events"),
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.upcomingEvents.length,
                      itemBuilder: (context, index) {
                        return UpcomingEventCard(event: controller.upcomingEvents[index]);
                      },
                    ),
                  ],
                );
              }),
              
              // People You May Know Section
              Obx(() {
                if (controller.peopleRecommendations.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: "People You May Know?"),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: controller.peopleRecommendations.length,
                      itemBuilder: (context, index) {
                        return BondUserCard(
                          connection: controller.peopleRecommendations[index],
                          status: BondStatus.nearby,
                        );
                      },
                    ),
                  ],
                );
              }),
              
              // Bottom Padding for Nav Bar
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}

