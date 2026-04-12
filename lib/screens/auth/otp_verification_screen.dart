import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/auth/signup_success_dialog.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

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
              "Enter OTP Code",
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Check your email inbox for the OTP code we sent you. Please enter it below to proceed.",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 48.h),

            // OTP Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => Container(
                  height: 70.h,
                  width: 70.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FF),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _otpControllers[index].text.isNotEmpty 
                          ? AppColors.primary 
                          : Colors.grey[200]!,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) {
                        setState(() {});
                        _onChanged(value, index);
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeading,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Resend Timer
            Center(
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      children: [
                        const TextSpan(text: "You can resend the code in "),
                        TextSpan(
                          text: "56",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: " seconds"),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () {
                      // Resend logic
                    },
                    child: Text(
                      "Resend code",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 60.h),

            // Verify Button
            GestureDetector(
              onTap: () => showSignupSuccessDialog(context),
              child: Container(
                height: 56.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Verify OTP",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),

    );
  }
}
