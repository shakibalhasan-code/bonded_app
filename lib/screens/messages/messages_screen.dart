import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/messages_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../widgets/messages/conversation_tile.dart';
import '../../widgets/custom_search_field.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessagesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80.h,
        leadingWidth: 60.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: SvgPicture.asset(AppAssets.appLogo, width: 32.sp, height: 32.sp),
        ),
        centerTitle: true,
        title: Text(
          "Messages",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
        actions: [
          _buildAppBarAction(Icons.person),
          SizedBox(width: 12.w),
          _buildAppBarAction(Icons.notifications),
          SizedBox(width: 20.w),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: CustomSearchField(
              controller: controller.searchController,
              hintText: "Search messages...",
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),
          Expanded(
            child: Obx(() => ListView.separated(
                  padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
                  itemCount: controller.filteredConversations.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ConversationTile(conversation: controller.filteredConversations[index]);
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7FF),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary, size: 20.sp),
    );
  }
}

