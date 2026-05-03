import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/section_header.dart';
import '../../widgets/home/circle_highlight_card.dart';
import '../../widgets/home/upcoming_event_card.dart';
import '../../widgets/home/people_recommendation_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circle Highlights Section
            const SectionHeader(title: "Circle Highlights"),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.circleHighlights.length,
              itemBuilder: (context, index) {
                return CircleHighlightCard(post: controller.circleHighlights[index]);
              },
            )),
            
            SizedBox(height: 8.h),
            
            // Upcoming Events Section
            const SectionHeader(title: "Upcoming Events"),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.upcomingEvents.length,
              itemBuilder: (context, index) {
                return UpcomingEventCard(event: controller.upcomingEvents[index]);
              },
            )),
            
            SizedBox(height: 8.h),
            
            // People You May Know Section
            const SectionHeader(title: "People You May Know?"),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.peopleRecommendations.length,
              itemBuilder: (context, index) {
                return PeopleRecommendationCard(data: controller.peopleRecommendations[index]);
              },
            )),
            
            // Bottom Padding for Nav Bar
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
}
