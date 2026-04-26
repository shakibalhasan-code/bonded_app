import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/circle_model.dart';
import '../../widgets/circles/circle_member_tile.dart';
import '../../widgets/custom_search_field.dart';

class CircleMembersScreen extends StatelessWidget {
  const CircleMembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MemberModel> allMembers = Get.arguments ?? [];
    final RxList<MemberModel> filteredMembers = RxList<MemberModel>(allMembers);
    final TextEditingController searchController = TextEditingController();

    void filterMembers(String query) {
      if (query.isEmpty) {
        filteredMembers.value = allMembers;
      } else {
        filteredMembers.value = allMembers
            .where((m) =>
                m.name.toLowerCase().contains(query.toLowerCase()) ||
                m.role.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }

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
          "Circle Members",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: CustomSearchField(
              controller: searchController,
              hintText: "Search members...",
              onChanged: filterMembers,
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: filteredMembers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          "Members List",
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHeading,
                          ),
                        ),
                      );
                    }
                    return CircleMemberTile(member: filteredMembers[index - 1]);
                  },
                )),
          ),
        ],
      ),
    );
  }
}
