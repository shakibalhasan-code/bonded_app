import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/circle_model.dart';
import '../../widgets/circles/circle_card.dart';

class AllCirclesScreen extends StatelessWidget {
  const AllCirclesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments;
    final String title = args['title'] ?? "Circles";
    final List<CircleModel> circles = args['circles'] ?? [];

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
      body: ListView.builder(
        itemCount: circles.length,
        padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
        itemBuilder: (context, index) {
          final circle = circles[index];
          return CircleCard(
            circle: circle,
            onTap: () {
              if (title.contains("Joined") || title.contains("Created")) {
                Get.toNamed(AppRoutes.JOINED_CIRCLE_DETAILS, arguments: circle);
              } else {
                Get.toNamed(AppRoutes.PUBLIC_CIRCLE_DETAILS, arguments: circle);
              }
            },
          );
        },
      ),
    );
  }
}
