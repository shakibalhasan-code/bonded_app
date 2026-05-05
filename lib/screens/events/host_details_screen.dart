import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/host_details_controller.dart';
import '../../core/constants/app_endpoints.dart';

class HostDetailsScreen extends StatelessWidget {
  HostDetailsScreen({Key? key}) : super(key: key);

  final HostDetailsController controller = Get.put(HostDetailsController());

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.hostProfile;
        if (profile.isEmpty) {
          return Center(
            child: Text(
              "Host profile not found.",
              style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey),
            ),
          );
        }

        final bool locationSharing = profile['preferences']?['locationSharing'] ?? false;
        final String? city = profile['city'];
        final String? country = profile['country'];
        final String locationText = (city != null && country != null)
            ? "$city, $country"
            : (city ?? country ?? "");

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundImage: NetworkImage(AppUrls.imageUrl(profile['avatar'])),
                      onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 50),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      profile['fullName'] ?? "Host User",
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B0B3B),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "@${profile['username'] ?? 'username'}",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (locationSharing && locationText.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, size: 14.sp, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text(
                            locationText,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              const Divider(),
              SizedBox(height: 24.h),

              // More About Section
              _buildSectionTitle("More About ${profile['fullName']?.split(' ').first ?? 'Host'}"),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _buildInfoColumn("Rating", "${profile['averageRating'] ?? 0} (${profile['reviewCount'] ?? 0} reviews)"),
                  SizedBox(width: 40.w),
                  _buildInfoColumn("Subscription", profile['subscriptionTier']?.toString().capitalizeFirst ?? 'Free'),
                ],
              ),
              SizedBox(height: 24.h),

              if (profile['bio'] != null && profile['bio'].toString().isNotEmpty) ...[
                // Bio
                _buildSectionTitle("Bio"),
                SizedBox(height: 12.h),
                Text(
                  profile['bio'],
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
              ],

              // Social Media (If available)
              if (profile['phone'] != null || profile['facebook'] != null) ...[
                _buildSectionTitle("Social Media Details"),
                SizedBox(height: 16.h),
                if (profile['phone'] != null)
                  _buildSocialItem(Icons.phone_outlined, "Phone Number", "${profile['phoneCountryCode'] ?? ''} ${profile['phone']}", showLabel: true),
                SizedBox(height: 16.h),
                if (profile['facebook'] != null)
                  _buildSocialItem(Icons.facebook, "Social Media", profile['facebook']),
                SizedBox(height: 32.h),
              ],

              // Verification
              _buildSectionTitle("Verification Badge"),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _buildInfoColumn("Profile Completed", (profile['profileCompleted'] == true) ? "Verified" : "Pending"),
                  SizedBox(width: 40.w),
                  _buildInfoColumn("ID Verification", (profile['documentVerification'] == 'verified') ? "Verified" : "Pending"),
                ],
              ),
              SizedBox(height: 24.h),
              _buildInfoColumn("Selfie Verification", (profile['selfieVerification'] == 'verified') ? "Verified" : "Pending"),
              SizedBox(height: 60.h),
            ],
          ),
        );
      }),
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
