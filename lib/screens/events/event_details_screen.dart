import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/event_model.dart';
import '../../models/highlight_model.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/event_details_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/events/media_viewers.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel? event;
  EventDetailsScreen({Key? key, this.event}) : super(key: key);

  final controller = Get.put(EventDetailsController());
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final EventModel initialEvent = event ?? (args is EventModel 
        ? args 
        : EventModel.fromJson(args as Map<String, dynamic>));

    // Initialize controller with current event and fetch full details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setEvent(initialEvent);
    });

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
          "Event Details",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final currentEvent = controller.event.value ?? initialEvent;
        final currentUserId = authController.currentUser.value?.id ?? '';
        final isOwner = currentEvent.hostId == currentUserId;

        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isOwner || controller.isBooking.value
                ? null
                : () => Get.toNamed(
                    AppRoutes.BOOK_EVENT,
                    arguments: currentEvent,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOwner ? Colors.grey[400] : AppColors.primary,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: controller.isBooking.value
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    isOwner ? "Your event" : "Book Event",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      }),
      body: Obx(() {
        if (controller.isLoading.value && controller.event.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentEvent = controller.event.value ?? initialEvent;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.network(
                  AppUrls.imageUrl(currentEvent.imageUrl),
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200.h,
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200.h,
                      width: double.infinity,
                      color: const Color(0xFFFAF7FF),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.primary.withOpacity(0.5),
                            size: 40.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "No Preview Available",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),

              // Title & Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      currentEvent.title,
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B0B3B),
                      ),
                    ),
                  ),
                  Text(
                    currentEvent.price != null && currentEvent.price! > 0
                        ? "${currentEvent.price!.toStringAsFixed(0)}\$"
                        : "FREE",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Date & Time
              if (currentEvent.date != null || currentEvent.time != null)
                Text(
                  "${currentEvent.date ?? ''} . ${currentEvent.time ?? ''}",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (currentEvent.date != null || currentEvent.time != null)
                SizedBox(height: 20.h),

              // Description
              if (currentEvent.description != null &&
                  currentEvent.description!.isNotEmpty) ...[
                _buildSectionTitle("Description:"),
                SizedBox(height: 10.h),
                Text(
                  currentEvent.description!,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Hosted By
              if (currentEvent.hostDetails != null) ...[
                _buildSectionTitle("Hosted By"),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundImage: NetworkImage(
                        AppUrls.imageUrl(currentEvent.hostDetails!['avatar']),
                      ),
                      onBackgroundImageError: (_, __) =>
                          const Icon(Icons.person),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentEvent.hostDetails!['fullName'] ?? "Host",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B0B3B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "@${currentEvent.hostDetails!['username'] ?? "host"}",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        if (currentEvent.hostId != null) {
                          Get.toNamed(
                            AppRoutes.HOST_DETAILS,
                            arguments: currentEvent.hostId,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        "View Profile",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],

              // Reviews
              if (currentEvent.rating != null) ...[
                _buildSectionTitle("Reviews:"),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.REVIEWS,
                    arguments: currentEvent.id,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        currentEvent.rating?.toString() ?? "0.0",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B0B3B),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "(${currentEvent.reviewsCount ?? 0} reviews)",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Location
              if (currentEvent.address != null ||
                  currentEvent.city != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "${currentEvent.address ?? ''}, ${currentEvent.city ?? ''}, ${currentEvent.country ?? ''}",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Map placeholder or actual map could go here
                SizedBox(height: 24.h),
              ],

              // Virtual Meeting Links
              if (currentEvent.meetingLink != null ||
                  currentEvent.virtualLink != null) ...[
                _buildSectionTitle("Meeting Link"),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () async {
                    final link =
                        currentEvent.meetingLink ?? currentEvent.virtualLink;
                    if (link != null && link.isNotEmpty) {
                      final uri = Uri.parse(
                        link.startsWith('http') ? link : 'https://$link',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Get.snackbar("Error", "Could not launch meeting link");
                      }
                    }
                  },
                  child: Text(
                    currentEvent.meetingLink ?? currentEvent.virtualLink ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Suggested Venues
              if (currentEvent.suggestedVenues != null &&
                  currentEvent.suggestedVenues!.isNotEmpty) ...[
                _buildSectionTitle("Suggested Venues"),
                SizedBox(height: 12.h),
                ...currentEvent.suggestedVenues!
                    .map((v) => _buildVenueTile(v))
                    .toList(),
                SizedBox(height: 24.h),
              ],

              // Category
              _buildSectionTitle("Event Category"),
              SizedBox(height: 8.h),
              Text(
                currentEvent.category == EventCategory.virtual
                    ? "Virtual Event"
                    : currentEvent.category == EventCategory.highlights
                    ? "Event Highlight"
                    : "In-Person Event",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 24.h),

              // Seats
              if (currentEvent.remainingSeats != null) ...[
                _buildSectionTitle("Available Seats"),
                SizedBox(height: 8.h),
                Text(
                  "${currentEvent.remainingSeats} / ${currentEvent.totalSeats ?? 'N/A'}",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Phone Number
              if (currentEvent.phoneNumber != null &&
                  currentEvent.phoneNumber!.isNotEmpty) ...[
                _buildSectionTitle("Phone Number"),
                SizedBox(height: 8.h),
                Text(
                  currentEvent.phoneNumber!,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Social Media
              if (currentEvent.facebookLink != null ||
                  currentEvent.twitterLink != null) ...[
                _buildSectionTitle("Social Media"),
                SizedBox(height: 12.h),
                if (currentEvent.facebookLink != null)
                  _buildSocialTile(
                    Icons.facebook,
                    currentEvent.facebookLink!,
                    "Facebook",
                  ),
                if (currentEvent.twitterLink != null)
                  _buildSocialTile(
                    Icons.camera_alt, // Twitter/X logo
                    currentEvent.twitterLink!,
                    "Twitter",
                  ),
                SizedBox(height: 24.h),
              ],

              // Highlights Section
              Obx(() {
                if (controller.highlights.isNotEmpty ||
                    (currentEvent.hostId ==
                        authController.currentUser.value?.id)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle("Event Highlights"),
                          if (currentEvent.hostId ==
                              authController.currentUser.value?.id)
                            TextButton.icon(
                              onPressed: () => Get.toNamed(
                                AppRoutes.ADD_EVENT_HIGHLIGHT,
                                arguments: currentEvent,
                              ),
                              icon: Icon(
                                Icons.add_a_photo,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                "Add",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (controller.highlights.isEmpty)
                        Text(
                          "No highlights available yet.",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        SizedBox(
                          height: 120.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.highlights.length,
                            itemBuilder: (context, index) {
                              final highlight = controller.highlights[index];
                              return _buildHighlightCard(highlight);
                            },
                          ),
                        ),
                      SizedBox(height: 24.h),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1B0B3B),
      ),
    );
  }

  Widget _buildVenueTile(VenueModel venue) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            venue.name,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[700]),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
            ),
            child: Text(
              "View on map",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTile(IconData icon, String url, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              url,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(HighlightModel highlight) {
    final images = highlight.images ?? [];
    final videos = highlight.videos ?? [];

    String? displayImage = images.isNotEmpty
        ? AppUrls.imageUrl(images.first.url)
        : null;
    String? displayVideo = videos.isNotEmpty
        ? AppUrls.imageUrl(videos.first.url)
        : null;

    return GestureDetector(
      onTap: () {
        if (displayImage != null) {
          Get.to(() => FullScreenImageViewer(imageUrl: displayImage));
        } else if (displayVideo != null) {
          Get.to(() => MockVideoPlayer(videoUrl: displayVideo));
        }
      },
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: const Color(0xFFF0EDFF),
          image: displayImage != null
              ? DecorationImage(
                  image: NetworkImage(displayImage),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              if (displayVideo != null && displayImage == null)
                Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: AppColors.primary.withOpacity(0.7),
                    size: 32.sp,
                  ),
                ),
              if (displayVideo != null && displayImage != null)
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
