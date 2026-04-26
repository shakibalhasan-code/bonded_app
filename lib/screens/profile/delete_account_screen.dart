import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/app_button.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Delete Account",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 24.sp),
                      SizedBox(width: 12.w),
                      Text(
                        "Delete your account will:",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "We're sorry to see you go. If you're sure you want to delete your Bonded App account, please be aware that this action is permanent and cannot be undone. All of your personal information, including your information and settings, will be permanently deleted.\n\nIf you're having trouble with your account or have concerns, please reach out to us at [contact email or support page] before proceeding with the account deletion. We'd love to help you resolve any issues and keep you as a valued Bonded App user.",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF1B0B3B),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    "Password",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FF),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "*****************",
                        hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                        border: InputBorder.none,
                        icon: Icon(Icons.lock, color: const Color(0xFF1B0B3B), size: 20.sp),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF1B0B3B),
                            size: 20.sp,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "To delete your account, please enter your password in the field below and confirm your decision by clicking the 'Delete My Account' button.",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: AppButton(
              text: "Delete Account",
              onPressed: () {
                if (_passwordController.text.isNotEmpty) {
                  Get.toNamed(AppRoutes.DELETE_ACCOUNT_OTP);
                } else {
                  Get.snackbar("Error", "Please enter your password");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
