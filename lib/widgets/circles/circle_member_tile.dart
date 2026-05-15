import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/circle_model.dart';
import '../../services/shared_prefs_service.dart';
import 'package:get/get.dart';
import '../../controllers/bond_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/circle_controller.dart';

class CircleMemberTile extends StatelessWidget {
  final MemberModel member;
  final CircleModel? circle;

  const CircleMemberTile({Key? key, required this.member, this.circle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final currentUserId =
        authController.currentUser.value?.id ??
        SharedPrefsService.getString('userId');
    final bool isMe = member.userId == currentUserId;
    final bool isOwner = member.isOwner;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            height: 56.w,
            width: 56.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: NetworkImage(member.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeading,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "Me",
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ] else if (isOwner) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEFEF),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "Creator",
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.red[400],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  member.role,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!isMe)
            SizedBox(
              height: 32.h,
              child: Obx(() => _buildBondButton(context)),
            ),
        ],
      ),
    );
  }

  Widget _buildBondButton(BuildContext context) {
    String buttonText = "Bond";
    bool isPrimary = false;
    VoidCallback? onPressed;

    switch (member.bondStatus.value) {
      case 'accepted':
        buttonText = "Bonded";
        isPrimary = true;
        onPressed = null;
        break;
      case 'pending_sent':
        buttonText = "Requested";
        isPrimary = true;
        onPressed = null;
        break;
      case 'pending_received':
        buttonText = "Accept";
        isPrimary = false;
        onPressed = () {
          // We need requestId for this. If member.id or userId works as requestId, we can use it.
          // Usually accept request takes requestId.
          // For now let's assume we can use userId if no bondId is available.
          // Get.find<BondController>().acceptBondRequest(member.userId);
        };
        break;
      case 'none':
      default:
        buttonText = "Bond";
        isPrimary = false;
        onPressed = () async {
          final previous = member.bondStatus.value;
          member.bondStatus.value = 'pending_sent';
          final ok = await Get.find<BondController>().sendBondRequest(member.userId);
          if (!ok) {
            member.bondStatus.value = previous;
            return;
          }
          if (circle != null && Get.isRegistered<CircleController>()) {
            Get.find<CircleController>().fetchCircleMembers(circle!);
          }
        };
        break;
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : Colors.white,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
      ),
      child: Text(
        buttonText,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: isPrimary ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}
