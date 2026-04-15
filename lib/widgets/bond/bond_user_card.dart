import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bond_user_model.dart';
import '../../controllers/bond_controller.dart';
import '../../core/routes/app_routes.dart';

class BondUserCard extends StatelessWidget {
  final BondUserModel user;

  const BondUserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BondController>();

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
                  child: Image.network(
                    user.image,
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B0B3B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.interests.values.expand((e) => e).take(3).join(', '),
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
                if (user.bondStatus.value == BondStatus.bonded)
                  _buildMessageIcon(),
              ],
            ),
            if (user.bondStatus.value != BondStatus.bonded) ...[
              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 16.h),
              _buildActionRow(controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(BondController controller) {
    if (user.bondStatus.value == BondStatus.nearby) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.sendBondRequest(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                "Let’s Bond",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _buildMessageIcon(),
        ],
      );
    } else if (user.bondStatus.value == BondStatus.requested) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.rejectBondRequest(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0EDFF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                "Reject",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.acceptBondRequest(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                "Accept",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageIcon() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20.sp),
    );
  }
}
