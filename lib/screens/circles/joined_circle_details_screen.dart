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

class JoinedCircleDetailsScreen extends StatefulWidget {
  const JoinedCircleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<JoinedCircleDetailsScreen> createState() =>
      _JoinedCircleDetailsScreenState();
}

class _JoinedCircleDetailsScreenState extends State<JoinedCircleDetailsScreen> {
  int _selectedTabIndex = 0; // 0: Feed, 1: Events, 2: Members
  final List<String> _tabs = ["Circle Feed", "Circle Events", "Circle Members"];

  @override
  Widget build(BuildContext context) {
    final CircleModel circle = Get.arguments;

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
                  // _buildPopupItem(
                  //   'delete',
                  //   Icons.delete_outline,
                  //   "Delete Circle",
                  // ),
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
          // Content Type Chips
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                if (_selectedTabIndex == 0) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7FF),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      "Today",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                ...List.generate(
                  _tabs.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = index),
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
    );
  }

  Widget _buildMainContent(CircleModel circle) {
    switch (_selectedTabIndex) {
      case 0: // Feed
        return Obx(() {
          if (circle.posts.isEmpty) {
            return _buildEmptyState("No posts yet.");
          }
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 20.h),
            itemCount: circle.posts.length,
            itemBuilder: (context, index) {
              return CirclePostItem(post: circle.posts[index]);
            },
          );
        });
      case 1: // Events
        return _buildEventsView();
      case 2: // Members
        return _buildMembersView(circle);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEventsView() {
    // Mock events for now
    final mockEvents = [
      {
        'title': 'Weekend Brunch Meetup',
        'image':
            'https://images.unsplash.com/photo-1528605248644-14dd04022da1?q=80&w=870&auto=format&fit=crop',
        'date': 'Oct 12, 2024',
        'time': '10:00 AM',
        'location': 'Grand Central Cafe, NY',
      },
      {
        'title': 'Wine & Cheese Night',
        'image':
            'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?q=80&w=870&auto=format&fit=crop',
        'date': 'Oct 15, 2024',
        'time': '07:00 PM',
        'location': 'The Vineyard Lounge, NY',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      itemCount: mockEvents.length,
      itemBuilder: (context, index) {
        return UpcomingEventCard(data: mockEvents[index]);
      },
    );
  }

  Widget _buildMembersView(CircleModel circle) {
    if (circle.detailedMembers == null || circle.detailedMembers!.isEmpty) {
      return _buildEmptyState("No members information available.");
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: circle.detailedMembers!.length,
      itemBuilder: (context, index) {
        return CircleMemberTile(member: circle.detailedMembers![index]);
      },
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

  void _showCreatePostSheet(BuildContext context, CircleModel circle) {
    Get.bottomSheet(
      CreatePostSheet(circle: circle),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
