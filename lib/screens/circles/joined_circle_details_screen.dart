import 'package:bonded_app/controllers/circle_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/circle_model.dart';
import '../../widgets/circles/circle_post_item.dart';
import '../../widgets/circles/circle_member_tile.dart';
import '../../widgets/home/upcoming_event_card.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/circles/create_post_sheet.dart';
import '../../models/marketplace_model.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinedCircleDetailsScreen extends StatefulWidget {
  const JoinedCircleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<JoinedCircleDetailsScreen> createState() =>
      _JoinedCircleDetailsScreenState();
}

class _JoinedCircleDetailsScreenState extends State<JoinedCircleDetailsScreen> {
  int _selectedTabIndex = 0; // 0: Feed, 1: Events, 2: Members
  final List<String> _tabs = ["Circle Feed", "Circle Events", "Circle Members", "Marketplace"];
  final TextEditingController _memberSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic args = Get.arguments;
      final CircleModel circle = args is CircleModel 
          ? args 
          : CircleModel.fromJson(args as Map<String, dynamic>);
      Get.find<CircleController>().fetchCircleFeed(circle);
    });
  }

  @override
  void dispose() {
    // _memberSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final CircleModel circle = args is CircleModel 
        ? args 
        : CircleModel.fromJson(args as Map<String, dynamic>);

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
                case 'leave':
                  controller.leaveCircle(circle);
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
                  // _buildPopupItem(
                  //   'delete',
                  //   Icons.delete_outline,
                  //   "Delete Circle",
                  // ),
                  _buildPopupItem(
                    'lock',
                    circle.isLocked
                        ? Icons.lock_open_outlined
                        : Icons.lock_outline,
                    circle.isLocked ? "Unlock Circle" : "Lock Circle",
                  ),
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
                  _buildPopupItem('leave', Icons.exit_to_app, "Leave Circle"),
                ];
              }
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        final controller = Get.find<CircleController>();
        return Stack(
          children: [
            Column(
              children: [
                // Content Type Chips
                SizedBox(height: 12.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      ...List.generate(
                        _tabs.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedTabIndex = index);
                              if (index == 0)
                                controller.fetchCircleFeed(circle);
                              if (index == 1)
                                controller.fetchCircleEvents(circle);
                              if (index == 2)
                                controller.fetchCircleMembers(circle);
                              if (index == 3)
                                controller.fetchCircleMarketplace(circle);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == index
                                    ? AppColors.primary
                                    : const Color(0xFFFAF7FF),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: _selectedTabIndex == index
                                      ? AppColors.primary
                                      : Colors.grey[200]!,
                                ),
                              ),
                              child: Text(
                                _tabs[index],
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: _selectedTabIndex == index
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: _selectedTabIndex == index
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Main Content Area
                Expanded(child: _buildMainContent(circle)),
              ],
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: CircularProgressIndicator()),
              ),
            SizedBox(height: 200.h),
          ],
        );
      }),
    );
  }

  Widget _buildMainContent(CircleModel circle) {
    final controller = Get.find<CircleController>();
    switch (_selectedTabIndex) {
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
                    padding: EdgeInsets.only(bottom: 100.h),
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
            child: _buildEventsView(circle),
          ),
        );
      case 2: // Members
        return Obx(
          () => RefreshIndicator(
            onRefresh: () => controller.fetchCircleMembers(circle),
            child: _buildMembersView(circle),
          ),
        );
      case 3: // Marketplace
        return Obx(
          () => RefreshIndicator(
            onRefresh: () => controller.fetchCircleMarketplace(circle),
            child: _buildMarketplaceView(circle),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEventsView(CircleModel circle) {
    if (circle.events.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          _buildEmptyState("No events scheduled for this circle."),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 100.h),
      itemCount: circle.events.length,
      itemBuilder: (context, index) {
        return UpcomingEventCard(event: circle.events[index]);
      },
    );
  }

  Widget _buildMarketplaceView(CircleModel circle) {
    if (circle.marketplaceProducts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          _buildEmptyState("No products found in marketplace."),
        ],
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: circle.marketplaceProducts.length,
      itemBuilder: (context, index) {
        final product = circle.marketplaceProducts[index];
        return _buildMarketplaceCard(product);
      },
    );
  }

  Widget _buildMarketplaceCard(MarketplaceProduct product) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[100],
                  child: Icon(Icons.image, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.interest,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  product.priceRange,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () => _launchURL(product.amazonUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 32.h),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    product.ctaLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not launch $url");
    }
  }

  Widget _buildMembersView(CircleModel circle) {
    return Column(
      children: [
        // Member Search Field
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to filter members
              },
              controller: _memberSearchController,
              decoration: InputDecoration(
                hintText: "Search members...",
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ),

        Expanded(
          child: Obx(() {
            final query = _memberSearchController.text.toLowerCase();
            final filteredMembers = circle.detailedMembers
                .where(
                  (m) =>
                      m.name.toLowerCase().contains(query) ||
                      m.role.toLowerCase().contains(query),
                )
                .toList();

            if (filteredMembers.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100.h),
                  _buildEmptyState(
                    query.isEmpty
                        ? "No members information available."
                        : "No members found for \"$query\"",
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 100.h),
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                return CircleMemberTile(member: filteredMembers[index]);
              },
            );
          }),
        ),
      ],
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Create Post",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _showCreateEventDialog(context, circle);
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Create Event",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  void _showCreateEventDialog(BuildContext context, CircleModel circle) {
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
                      'circleId': circle.id,
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "In-Person Event",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
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
                      'circleId': circle.id,
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Bonded Virtual Event",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
                    Hero(
                      tag: 'circle_image_${circle.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Image.network(
                          circle.image.isNotEmpty
                              ? circle.image
                              : _getPlaceholderImage(circle.id),
                          width: double.infinity,
                          height: 180.h,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180.h,
                              color: const Color(0xFFF8F7FF),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180.h,
                              width: double.infinity,
                              color: const Color(0xFFFAF7FF),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.primary.withOpacity(0.3),
                                  size: 40.sp,
                                ),
                              ),
                            );
                          },
                        ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
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
                        _buildStatItem(
                          Icons.people_outline,
                          "${circle.memberCount.value} Members",
                        ),
                        SizedBox(width: 24.w),
                        _buildStatItem(
                          Icons.article_outlined,
                          "${circle.postCount.value} Posts",
                        ),
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
                        children: circle.hashtags
                            .map(
                              (tag) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE5E0FF),
                                  ),
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
                              ),
                            )
                            .toList(),
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
                        "Back to Circle",
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
