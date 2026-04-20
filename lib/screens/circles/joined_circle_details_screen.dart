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

class JoinedCircleDetailsScreen extends StatefulWidget {
  const JoinedCircleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<JoinedCircleDetailsScreen> createState() =>
      _JoinedCircleDetailsScreenState();
}

class _JoinedCircleDetailsScreenState extends State<JoinedCircleDetailsScreen> {
  int _selectedTabIndex = 0; // 0: Feed, 1: Events, 2: Members
  final List<String> _tabs = ["Circle Feed", "Circle Events", "Members"];

  @override
  Widget build(BuildContext context) {
    final CircleModel circle = Get.arguments;

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
          // PopupMenuButton<int>(
          //   icon: const Icon(Icons.more_vert, color: Color(0xFF1B0B3B)),
          //   onSelected: (value) {
          //     if (value == 1) {
          //       Get.toNamed(AppRoutes.CIRCLE_MEMBERS, arguments: circle.detailedMembers);
          //     }
          //   },
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(16.r),
          //   ),
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //       value: 1,
          //       child: Row(
          //         children: [
          //           Icon(Icons.group_outlined, color: const Color(0xFF1B0B3B), size: 20.sp),
          //           SizedBox(width: 12.w),
          //           Text(
          //             "Group Members",
          //             style: GoogleFonts.inter(
          //               fontSize: 14.sp,
          //               fontWeight: FontWeight.w500,
          //               color: const Color(0xFF1B0B3B),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
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
              children: List.generate(
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
                            : const Color(0xFFF9F9FF),
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
            ),
          ),
          SizedBox(height: 16.h),

          // Date separator (Only for Feed)
          if (_selectedTabIndex == 0)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "Today",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

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
}
