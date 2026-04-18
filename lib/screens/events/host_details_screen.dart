import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';

class HostDetailsScreen extends StatelessWidget {
  const HostDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Host Details",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde"),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              "Pro",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Andrew Ainsley",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "andrew_ainsley@gmail.com",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            const Divider(),
            SizedBox(height: 24.h),

            // More About Section
            _buildSectionTitle("More About Andrew:"),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildInfoColumn("First Name", "Maria T."),
                SizedBox(width: 40.w),
                _buildInfoColumn("No. Of Hosted Events", "12 events hosted"),
              ],
            ),
            SizedBox(height: 24.h),

            // Bio
            _buildSectionTitle("Bio"),
            SizedBox(height: 12.h),
            Text(
              "Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit, Sed Do Eiusmod Tempor Incididunt Ut Labore Et Dolore Magna Aliqua. Ut Enim Ad Minim Veniam, Quis Nostrud Exercitation Ullamco Laboris Nisi Ut Aliquip Ex Ea Commodo Consequat.",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            // Social Media
            _buildSectionTitle("Social Media Details"),
            SizedBox(height: 16.h),
            _buildSocialItem(Icons.phone_outlined, "Phone Number", "+49-5410-81030619", showLabel: true),
            SizedBox(height: 16.h),
            _buildSocialItem(Icons.facebook, "Social Media", "https://www.facebook.com/bondedapp"),
            SizedBox(height: 16.h),
            _buildSocialItem(Icons.camera_alt, "", "https://www.twitter.com/bondedapp"),
            SizedBox(height: 32.h),

            // Verification
            _buildSectionTitle("Verification Badge"),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildInfoColumn("Phone Number", "Verified"),
                SizedBox(width: 40.w),
                _buildInfoColumn("ID Verification", "Verified"),
              ],
            ),
            SizedBox(height: 24.h),
            _buildInfoColumn("Social Verification", "Verified"),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1B0B3B),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialItem(IconData icon, String title, String value, {bool showLabel = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B0B3B),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
