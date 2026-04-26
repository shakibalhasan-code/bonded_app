import '../../controllers/circle_controller.dart';
import '../../core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/circle_model.dart';
import '../../widgets/circles/circle_member_tile.dart';
import '../../widgets/circles/circle_post_item.dart';
import '../../widgets/circles/create_post_sheet.dart';
import '../../widgets/custom_search_field.dart';

class PublicCircleDetailsScreen extends StatefulWidget {
  const PublicCircleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PublicCircleDetailsScreen> createState() => _PublicCircleDetailsScreenState();
}

class _PublicCircleDetailsScreenState extends State<PublicCircleDetailsScreen> {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;

  @override
  Widget build(BuildContext context) {
    final CircleModel circle = Get.arguments;

    return Obx(
      () => circle.isJoined.value
          ? _buildFeedView(context, circle)
          : _buildLandingView(context, circle),
    );
  }

  Widget _buildLandingView(BuildContext context, CircleModel circle) {
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
          circle.name,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: 24.sp,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),

            // Circle Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.network(
                circle.image,
                width: double.infinity,
                height: 220.h,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 24.h),

            // Name and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    circle.name,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                ),
                Text(
                  "\$${circle.price ?? "5.00"}",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    circle.address ??
                        "Grand city St. 100, New York, United States.",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),
            const Divider(color: Color(0xFFF0F0F0), thickness: 1),
            SizedBox(height: 20.h),

            // Description Section
            Text(
              "Description:",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              circle.description,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),

            SizedBox(height: 20.h),
            const Divider(color: Color(0xFFF0F0F0), thickness: 1),
            SizedBox(height: 20.h),

            // Interest Section
            Text(
              "Circle Interest",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: circle.tags
                  .map((tag) => _buildInterestChip(tag))
                  .toList(),
            ),

            SizedBox(height: 32.h),

            // Members List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Members List",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "See All",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Members List
            if (circle.detailedMembers != null) ...[
              CustomSearchField(
                controller: searchController,
                hintText: "Search members...",
                onChanged: (val) => searchQuery.value = val,
              ),
              SizedBox(height: 16.h),
              Obx(() {
                final query = searchQuery.value.toLowerCase();
                final filtered = circle.detailedMembers!
                    .where((m) =>
                        m.name.toLowerCase().contains(query) ||
                        m.role.toLowerCase().contains(query))
                    .toList();
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.take(3).length,
                  itemBuilder: (context, index) {
                    return CircleMemberTile(
                      member: filtered[index],
                    );
                  },
                );
              }),
            ],

            SizedBox(height: 40.h),

            // Join Button
            ElevatedButton(
              onPressed: () => circle.isJoined.value = true,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                "Join Circle",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildFeedView(BuildContext context, CircleModel circle) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptionsDialog(context, circle),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          circle.name,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.primary, size: 24.sp),
            onSelected: (value) {
              final controller = Get.find<CircleController>();
              switch (value) {
                case 'edit':
                  controller.editCircle(circle);
                  break;
                case 'delete':
                  controller.deleteCircle(circle);
                  break;
                case 'lock':
                  controller.lockCircle(circle);
                  break;
                case 'add_member':
                  Get.toNamed(AppRoutes.ADD_MEMBERS, arguments: circle);
                  break;
                case 'group_info':
                  _showGroupInfoBottomSheet(context, circle);
                  break;
                case 'group_members':
                  Get.toNamed(
                    AppRoutes.CIRCLE_MEMBERS,
                    arguments: circle.detailedMembers,
                  );
                  break;
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            itemBuilder: (context) {
              if (circle.isOwner) {
                return [
                  _buildPopupItem('edit', Icons.edit_outlined, "Edit Circle"),
                  _buildPopupItem(
                    'delete',
                    Icons.delete_outline,
                    "Delete Circle",
                  ),
                  _buildPopupItem('lock', Icons.lock_outline, "Lock Circle"),
                  _buildPopupItem(
                    'add_member',
                    Icons.person_add_outlined,
                    "Add Member",
                  ),
                ];
              } else {
                return [
                  _buildPopupItem(
                    'group_info',
                    Icons.info_outline,
                    "Group Info",
                  ),
                  _buildPopupItem(
                    'group_members',
                    Icons.people_outline,
                    "Group Members",
                  ),
                ];
              }
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Today Status Chip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Row(
              children: [
                _buildStatusChip("Today", isSelected: true),
                SizedBox(width: 8.w),
                _buildStatusChip("Circle Feed"),
                SizedBox(width: 8.w),
                _buildStatusChip("Circle Events"),
                SizedBox(width: 8.w),
                _buildStatusChip("Circle Members"),
              ],
            ),
          ),

          // Feed List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 20.h),
              itemCount: circle.posts.length,
              itemBuilder: (context, index) {
                return CirclePostItem(post: circle.posts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showGroupInfoBottomSheet(BuildContext context, CircleModel circle) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Group Info",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 20.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  circle.image,
                  width: double.infinity,
                  height: 150.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                circle.name,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                circle.description,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Members (${circle.detailedMembers?.length ?? 0})",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 12.h),
              if (circle.detailedMembers != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: circle.detailedMembers!.take(3).length,
                  itemBuilder: (context, index) {
                    return CircleMemberTile(
                      member: circle.detailedMembers![index],
                    );
                  },
                ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  "Close",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatusChip(String label, {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context, CircleModel circle) {
    Get.bottomSheet(
      CreatePostSheet(circle: circle),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCreateOptionsDialog(BuildContext context, CircleModel circle) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create Content",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "What would you like to create today?",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _showCreatePostSheet(context, circle);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  "Create Post",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _showCreateEventDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Create Event",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.h,
                height: 80.h,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 48.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                "Confirmation Required!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Select which event you want to create? After selection you will proceed with the flow accordingly.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.CREATE_EVENT,
                    arguments: {
                      'isVirtual': false,
                      'category': 'Birthday Celebration',
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "In-Person Event",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.CREATE_EVENT,
                    arguments: {
                      'isVirtual': true,
                      'category': 'Birthday Celebration',
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Bonded Virtual Event",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B0B3B), size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B0B3B),
            ),
          ),
        ],
      ),
    );
  }
}
