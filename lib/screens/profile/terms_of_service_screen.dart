import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

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
          "Terms of Service",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "1. Acceptance of Terms",
              "By accessing and using the Bonded App, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.",
            ),
            _buildSection(
              "2. User Responsibility",
              "You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.",
            ),
            _buildSection(
              "3. Content Guidelines",
              "Users are prohibited from posting offensive, illegal, or harmful content. Bonded App reserves the right to remove any content that violates these guidelines.",
            ),
            _buildSection(
              "4. Privacy",
              "Your use of the app is also governed by our Privacy Policy. Please review it to understand our practices regarding your data.",
            ),
            _buildSection(
              "5. Modifications",
              "Bonded App reserves the right to modify or replace these terms at any time. Your continued use of the app after changes indicates your acceptance.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B0B3B),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
