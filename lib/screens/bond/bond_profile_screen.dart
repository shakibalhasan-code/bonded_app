import 'package:bonded_app/controllers/bond_controller.dart';
import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../models/bond_user_model.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_colors.dart';

class BondProfileScreen extends StatelessWidget {
  const BondProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserModel user = Get.arguments;
    final controller = Get.find<BondController>();

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
          "Profile View",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.chat_bubble_outline, color: AppColors.primary),
          //   onPressed: () => Get.toNamed(AppRoutes.CHAT, arguments: user),
          // ),
          // SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image & Info
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: user.avatar != null && user.avatar!.isNotEmpty
                            ? Image.network(
                                user.avatar!.startsWith('http')
                                    ? user.avatar!
                                    : 'https://bonded-backend.onrender.com/${user.avatar}',
                                width: 100.w,
                                height: 100.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(user.fullName),
                              )
                            : _buildPlaceholder(user.fullName),
                      ),
                      if (user.selfieVerification == 'verified')
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                "Verified",
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    user.fullName ?? user.username ?? "Unknown User",
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  Text(
                    user.email,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            const Divider(),
            SizedBox(height: 24.h),

            // More About User
            Text(
              "More About ${user.fullName?.split(' ')[0] ?? 'User'}:",
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 20.h),

            // Grid Info
            _buildInfoGrid(user),
            SizedBox(height: 24.h),

            // Location
            Text(
              "Location",
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "${user.city ?? ''}, ${user.country ?? ''}",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Bio
            Text(
              "Bio",
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              user.bio ?? "No bio available",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            SizedBox(height: 24.h),

            // Interest
            Text(
              "Interest",
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 20.h),
            _buildInterestsSection(user),
            SizedBox(height: 100.h), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: _buildFooter(user, controller),
    );
  }

  Widget _buildPlaceholder(String? name) {
    return Image.network(
      'https://ui-avatars.com/api/?name=${name ?? 'User'}&background=F0EDFF&color=6200EE&bold=true',
      width: 100.w,
      height: 100.w,
      fit: BoxFit.cover,
    );
  }

  Widget _buildFooter(UserModel user, BondController controller) {
    // Check if user is already bonded or if there's a pending request
    // For now, let's just show "Let's Bond" if they are in nearbyPeople
    final isNearby = controller.nearbyPeople.any((c) => c.user.id == user.id);
    final isRequest = controller.bondRequests.any((c) => c.user.id == user.id);
    final isBonded = controller.myBonds.any((c) => c.user.id == user.id);

    if (isBonded) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      color: Colors.white,
      child: isRequest
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final bond = controller.bondRequests.firstWhere(
                        (c) => c.user.id == user.id,
                      );
                      controller.rejectBondRequest(bond.bondId ?? "");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFAF7FF),
                      elevation: 0,
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      "Reject",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final bond = controller.bondRequests.firstWhere(
                        (c) => c.user.id == user.id,
                      );
                      controller.acceptBondRequest(bond.bondId ?? "");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      "Accept",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ElevatedButton(
              onPressed: () => controller.sendBondRequest(user.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                "Let’s Bond",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Widget _buildInfoGrid(UserModel user) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoItem("Username", user.username ?? "N/A"),
            _buildInfoItem("Gender", user.gender ?? "N/A"),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoItem("Date Of Birth", user.dateOfBirth ?? "N/A"),
            _buildInfoItem(
              "Connection Type",
              user.connectionType?.join(', ') ?? "N/A",
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoItem("City", user.city ?? "N/A"),
            _buildInfoItem("Country", user.country ?? "N/A"),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return SizedBox(
      width: 160.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B0B3B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(UserModel user) {
    if (user.interests == null || user.interests!.isEmpty) {
      return Text(
        "No interests selected",
        style: GoogleFonts.inter(color: Colors.grey),
      );
    }

    // Group interests by category
    Map<String, List<Interest>> grouped = {};
    for (var interest in user.interests!) {
      grouped.putIfAbsent(interest.category, () => []).add(interest);
    }

    return Column(
      children: grouped.entries.map((category) {
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.key,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 24.w,
                runSpacing: 12.h,
                children: category.value.map((interest) {
                  return Text(
                    interest.name,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF1B0B3B),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
