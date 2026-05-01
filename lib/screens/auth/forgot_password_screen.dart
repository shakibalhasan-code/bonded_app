import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/app_button.dart';

import '../../controllers/auth_controller.dart';

class ForgotPasswordScreen extends GetView<AuthController> {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHeading),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              "Forgot Password",
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Enter your email address and we'll send you an OTP code to reset your password.",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.h),

            // Email Field
            AuthTextField(
              label: "Email",
              hintText: "Enter your email",
              prefixIcon: Icons.email_outlined,
              controller: controller.emailController,
            ),

            SizedBox(height: 48.h),

            // Send OTP Button
            Obx(() => AppButton(
              text: "Send OTP",
              isPrimary: true,
              isLoading: controller.isLoading.value,
              onPressed: () {
                if (controller.emailController.text.isEmpty) {
                  Get.snackbar('Error', 'Please enter your email');
                  return;
                }
                controller.forgotPassword(controller.emailController.text);
              },
            )),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
