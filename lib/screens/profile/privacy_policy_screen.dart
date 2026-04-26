import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

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
          "Privacy Policy",
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
              "Information We Collect",
              "We collect information you provide directly to us, such as when you create an account, update your profile, or communicate with other users.",
            ),
            _buildSection(
              "How We Use Information",
              "We use the information we collect to provide, maintain, and improve our services, and to communicate with you about updates and features.",
            ),
            _buildSection(
              "Data Security",
              "We implement industry-standard security measures to protect your personal information from unauthorized access, disclosure, or destruction.",
            ),
            _buildSection(
              "Sharing of Information",
              "We do not share your personal information with third parties except as described in this policy or with your explicit consent.",
            ),
            _buildSection(
              "Your Rights",
              "You have the right to access, update, or delete your personal information at any time through your account settings.",
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
