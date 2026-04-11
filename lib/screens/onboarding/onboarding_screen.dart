import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../controllers/onboarding_controller.dart';
import '../../widgets/onboarding/onboarding_widgets.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    // Set Status Bar Color for Onboarding
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return Column(
            children: [
              // Top Section with Image and Custom Curve
              Expanded(
                flex: 11,
                child: ClipPath(
                  clipper: CustomCurveClipper(),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                      PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: controller.onPageChanged,
                        itemCount: controller.steps.length,
                        itemBuilder: (context, index) {
                          final step = controller.steps[index];
                          return Container(
                            padding: EdgeInsets.only(top: screenHeight * 0.08),
                            alignment: Alignment.topCenter,
                            child: ScaleTransition(
                              scale: const AlwaysStoppedAnimation(1.0),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: screenHeight * 0.90,
                                  maxWidth: screenWidth * 0.90,
                                ),
                                child: Image.asset(
                                  step.imagePath,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Content Section
              Expanded(
                flex: 9,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Obx(() {
                        final step =
                            controller.steps[controller.currentIndex.value];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              step.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHeading,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              step.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13.5.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.normal,
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 24.h),
                      // Page indicator moved here
                      Obx(
                        () => OnboardingPageIndicator(
                          currentIndex: controller.currentIndex.value,
                          totalCount: controller.steps.length,
                        ),
                      ),
                      const Spacer(),
                      // Divider
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Divider(color: Colors.grey[100], thickness: 1),
                      ),
                      // Buttons
                      Row(
                        children: [
                          OnboardingButton(
                            text: 'Skip',
                            isPrimary: false,
                            onPressed: controller.skipOnboarding,
                          ),
                          SizedBox(width: 16.w),
                          OnboardingButton(
                            text: 'Continue',
                            isPrimary: true,
                            onPressed: controller.nextPage,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
