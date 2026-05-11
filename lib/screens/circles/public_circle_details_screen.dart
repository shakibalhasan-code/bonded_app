import 'package:bonded_app/widgets/home/upcoming_event_card.dart';

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
  State<PublicCircleDetailsScreen> createState() =>
      _PublicCircleDetailsScreenState();
}

class _PublicCircleDetailsScreenState extends State<PublicCircleDetailsScreen> {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;
  final RxInt selectedTabIndex = 0.obs;
  final List<String> tabs = ["Circle Feed", "Circle Events", "Circle Members"];

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final CircleModel circle = args is CircleModel 
        ? args 
        : CircleModel.fromJson(args as Map<String, dynamic>);

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
                circle.image.isNotEmpty
                    ? circle.image
                    : _getPlaceholderImage(circle.id),
                width: double.infinity,
                height: 220.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    _getPlaceholderImage(circle.id),
                    height: 220.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
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
                    circle.address,
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
            CustomSearchField(
              controller: searchController,
              hintText: "Search members...",
              onChanged: (val) => searchQuery.value = val,
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final query = searchQuery.value.toLowerCase();
              final filtered = circle.detailedMembers
                  .where(
                    (m) =>
                        m.name.toLowerCase().contains(query) ||
                        m.role.toLowerCase().contains(query),
                  )
                  .toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.take(3).length,
                itemBuilder: (context, index) {
                  return CircleMemberTile(member: filtered[index]);
                },
              );
            }),

            SizedBox(height: 40.h),

            // Join Button
            ElevatedButton(
              onPressed: () => Get.find<CircleController>().joinCircle(circle),
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
      body: Obx(() {
        final controller = Get.find<CircleController>();
        return Column(
          children: [
            // Content Type Chips
            SizedBox(height: 12.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: List.generate(
                  tabs.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () {
                        selectedTabIndex.value = index;
                        if (index == 0) controller.fetchCircleFeed(circle);
                        if (index == 1) controller.fetchCircleEvents(circle);
                        if (index == 2) controller.fetchCircleMembers(circle);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: selectedTabIndex.value == index
                              ? AppColors.primary
                              : const Color(0xFFFAF7FF),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: selectedTabIndex.value == index
                                ? AppColors.primary
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: Text(
                          tabs[index],
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: selectedTabIndex.value == index
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: selectedTabIndex.value == index
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Main Content Area
            Expanded(child: _buildMainContent(circle)),
          ],
        );
      }),
    );
  }

  Widget _buildMainContent(CircleModel circle) {
    final controller = Get.find<CircleController>();
    switch (selectedTabIndex.value) {
      case 0: // Feed
        return Obx(
          () => RefreshIndicator(
            onRefresh: () => controller.fetchCircleFeed(circle),
            child: circle.posts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 100.h),
                      _buildEmptyState("No posts yet."),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 20.h),
                    itemCount: circle.posts.length,
                    itemBuilder: (context, index) {
                      return CirclePostItem(
                        post: circle.posts[index],
                        circle: circle,
                      );
                    },
                  ),
          ),
        );
      case 1: // Events
        return Obx(
          () => RefreshIndicator(
            onRefresh: () => controller.fetchCircleEvents(circle),
            child: _buildEventsSection(circle),
          ),
        );
      case 2: // Members
        return Obx(
          () => RefreshIndicator(
            onRefresh: () => controller.fetchCircleMembers(circle),
            child: _buildMembersSection(circle),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEventsSection(CircleModel circle) {
    if (circle.events.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          _buildEmptyState("No events scheduled."),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: circle.events.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: UpcomingEventCard(event: circle.events[index]),
      ),
    );
  }

  Widget _buildMembersSection(CircleModel circle) {
    if (circle.detailedMembers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          _buildEmptyState("No members yet."),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: circle.detailedMembers.length,
      itemBuilder: (context, index) =>
          CircleMemberTile(member: circle.detailedMembers[index]),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.inter(color: Colors.grey, fontSize: 14.sp),
      ),
    );
  }

  void _showGroupInfoBottomSheet(BuildContext context, CircleModel circle) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Group Info",
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B0B3B),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.close, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    
                    // Circle Cover Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.network(
                        circle.image,
                        width: double.infinity,
                        height: 180.h,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180.h,
                            color: const Color(0xFFF8F7FF),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180.h,
                            width: double.infinity,
                            color: const Color(0xFFFAF7FF),
                            child: Center(
                              child: Icon(Icons.image_not_supported_outlined, color: AppColors.primary.withOpacity(0.3), size: 40.sp),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    Text(
                      circle.name,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B0B3B),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Category Chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        circle.category,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    
                    Text(
                      circle.description,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Stats Row
                    Row(
                      children: [
                        _buildStatItem(Icons.people_outline, "${circle.memberCount.value} Members"),
                        SizedBox(width: 24.w),
                        _buildStatItem(Icons.article_outlined, "${circle.postCount.value} Posts"),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    
                    // Interests / Tags
                    if (circle.hashtags.isNotEmpty) ...[
                      Text(
                        "Interests",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B0B3B),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: circle.hashtags.map((tag) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E0FF)),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B4DFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                      SizedBox(height: 32.h),
                    ],
                    
                    // Close Button
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        elevation: 0,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ],
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
                      'category': 'Celebrations',
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
                      'category': 'Celebrations',
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

  String _getPlaceholderImage(String id) {
    final List<String> placeholders = [
      'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800&q=80',
      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&q=80',
      'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=800&q=80',
      'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=80',
      'https://images.unsplash.com/photo-1505236858219-8359eb29e329?w=800&q=80',
      'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800&q=80',
      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&q=80',
    ];
    int index = id.hashCode % placeholders.length;
    return placeholders[index.abs()];
  }
}
