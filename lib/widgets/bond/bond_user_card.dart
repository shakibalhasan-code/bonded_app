import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bond_user_model.dart';
import '../../controllers/bond_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_endpoints.dart';

class BondUserCard extends StatelessWidget {
  final BondConnectionModel connection;
  final BondStatus status;

  const BondUserCard({Key? key, required this.connection, required this.status})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BondController>();
    final user = connection.user;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.BOND_PROFILE, arguments: user),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: user.avatar != null && user.avatar!.isNotEmpty
                      ? Image.network(
                          AppUrls.imageUrl(user.avatar),
                          width: 60.w,
                          height: 60.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(user.fullName),
                        )
                      : _buildPlaceholder(user.fullName),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName ?? user.username ?? "Unknown User",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B0B3B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.interests?.map((i) => i.name).take(3).join(', ') ??
                            "No interests",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (status == BondStatus.bonded) _buildMessageIcon(user),
              ],
            ),
            if (status != BondStatus.bonded) ...[
              SizedBox(height: 12.h),
              _buildActionRow(controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String? name) {
    return Container(
      width: 60.w,
      height: 60.w,
      color: AppColors.primary.withOpacity(0.1),
      child: Icon(Icons.person, color: AppColors.primary, size: 30.sp),
    );
  }

  Widget _buildActionRow(BondController controller) {
    if (status == BondStatus.nearby) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.sendBondRequest(connection.user.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                "Let’s Bond",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == BondStatus.requested) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  controller.rejectBondRequest(connection.bondId ?? ""),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0EDFF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                "Reject",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  controller.acceptBondRequest(connection.bondId ?? ""),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                "Accept",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == BondStatus.outgoing) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.cancelBondRequest(connection.bondId ?? ""),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAF7FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                "Cancel Request",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageIcon(dynamic user) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.CHAT, arguments: user),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EDFF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.chat_bubble_outline,
          color: AppColors.primary,
          size: 20.sp,
        ),
      ),
    );
  }
}
