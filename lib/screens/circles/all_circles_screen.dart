import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/circle_model.dart';
import '../../widgets/circles/circle_card.dart';
import '../../widgets/custom_search_field.dart';

class AllCirclesScreen extends StatelessWidget {
  const AllCirclesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments;
    final String title = args['title'] ?? "Circles";
    final List<CircleModel> allCircles = args['circles'] ?? [];
    final RxList<CircleModel> filteredCircles = RxList<CircleModel>(allCircles);
    final TextEditingController searchController = TextEditingController();

    void filterCircles(String query) {
      if (query.isEmpty) {
        filteredCircles.value = allCircles;
      } else {
        filteredCircles.value = allCircles
            .where((c) =>
                c.name.toLowerCase().contains(query.toLowerCase()) ||
                c.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHeading),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: CustomSearchField(
              controller: searchController,
              hintText: "Search circles...",
              onChanged: filterCircles,
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: filteredCircles.length,
                  padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                  itemBuilder: (context, index) {
                    final circle = filteredCircles[index];
                    return CircleCard(
                      circle: circle,
                      onTap: () {
                        if (circle.isLocked.value && !circle.isOwner) {
                          Get.snackbar(
                            "Circle Locked",
                            "This circle is currently locked by the creator.",
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                          return;
                        }
                        if (title.contains("Joined") || title.contains("Created")) {
                          Get.toNamed(AppRoutes.JOINED_CIRCLE_DETAILS, arguments: circle);
                        } else {
                          Get.toNamed(AppRoutes.PUBLIC_CIRCLE_DETAILS, arguments: circle);
                        }
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
