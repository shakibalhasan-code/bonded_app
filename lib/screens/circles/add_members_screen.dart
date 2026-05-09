import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/circle_model.dart';
import '../../controllers/circle_controller.dart';
import '../../widgets/custom_search_field.dart';

class AddMembersScreen extends StatelessWidget {
  const AddMembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CircleController controller = Get.find<CircleController>();
    final CircleModel circle = Get.arguments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHeading),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Add Members",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                onChanged: (value) => controller.searchMembersToInvite(circle.id, value),
                decoration: InputDecoration(
                  hintText: "Search people...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Search Results",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (controller.isInviteLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.inviteSearchMembers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "Search for users to invite",
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.inviteSearchMembers.length,
                itemBuilder: (context, index) {
                  final member = controller.inviteSearchMembers[index];
                  return _buildAddMemberTile(context, member, circle, controller);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberTile(BuildContext context, MemberModel member,
      CircleModel circle, CircleController controller) {
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
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeading,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            height: 32.h,
            child: OutlinedButton(
              onPressed: () => controller.addMemberDirectly(circle, member.userId),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Text(
                "Add",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
