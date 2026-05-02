import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/event_model.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/routes/app_routes.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EventModel event = Get.arguments;

    // Mock data for the flow
    final mockDescription =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

    final List<VenueModel> venues = [
      VenueModel(name: "Grand Place Hotel", location: "New York"),
      VenueModel(name: "Sonny Restaurant", location: "New York"),
      VenueModel(name: "Redfin Hotel", location: "New York"),
      VenueModel(name: "Dreams Restaurant", location: "New York"),
      VenueModel(name: "Five Star Hotel", location: "New York"),
    ];

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
      bottomNavigationBar: Container(
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
          onPressed: () => Get.toNamed(AppRoutes.BOOK_EVENT, arguments: event),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          child: Text(
            "Book Event",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.network(
                AppUrls.imageUrl(event.imageUrl),
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
                    event.title,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                ),
                Text(
                  "\$${event.price?.toStringAsFixed(2) ?? "\$5.00"}",
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
            Text(
              "Mon, Dec 24 . 18:00 - 23:00 PM",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),

            // Description
            _buildSectionTitle("Description:"),
            SizedBox(height: 10.h),
            Text(
              mockDescription,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Reviews
            _buildSectionTitle("Reviews:"),
            SizedBox(height: 12.h),
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.REVIEWS),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "4.8",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "(4.8k reviews)",
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

            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Grand city St. 100, New York, United States.",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                "https://images.unsplash.com/photo-1524661135-423995f22d0b", // Placeholder map image
                width: double.infinity,
                height: 150.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFFAF7FF),
                  height: 150.h,
                  child: Center(
                    child: Icon(
                      Icons.map_outlined,
                      color: AppColors.primary.withOpacity(0.5),
                      size: 40.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "See location on map",
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Suggested Venues
            _buildSectionTitle("Suggested Venues"),
            SizedBox(height: 12.h),
            ...venues.map((v) => _buildVenueTile(v)).toList(),
            SizedBox(height: 24.h),

            // Category
            _buildSectionTitle("Event Category"),
            SizedBox(height: 8.h),
            Text(
              "Birthday Celebration",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24.h),

            // Phone Number
            _buildSectionTitle("Phone Number"),
            SizedBox(height: 8.h),
            Text(
              "+49-5410-81030619",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24.h),

            // Social Media
            _buildSectionTitle("Social Media"),
            SizedBox(height: 12.h),
            _buildSocialTile(
              Icons.phone,
              "https://www.whatsapp.com/bondedapp",
              "WhatsApp",
            ),
            _buildSocialTile(
              Icons.facebook,
              "https://www.facebook.com/bondedapp",
              "Facebook",
            ),
            _buildSocialTile(
              Icons.camera_alt,
              "https://www.twitter.com/bondedapp",
              "Twitter",
            ), // Twitter logo substitute
            _buildSocialTile(
              Icons.camera_alt,
              "https://www.instagram.com/bondedapp",
              "Instagram",
            ),
            SizedBox(height: 24.h),

            // Event Highlights
            _buildSectionTitle("Event Highlights"),
            SizedBox(height: 12.h),
            Text(
              "Video Highlights",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 140.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => _buildHighlightThumbnail(true),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Add Images",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.8,
              ),
              itemCount: 3,
              itemBuilder: (context, index) => _buildHighlightThumbnail(false),
            ),
            SizedBox(height: 24.h),

            // Caption
            _buildSectionTitle("Caption"),
            SizedBox(height: 12.h),
            Text(
              mockDescription,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
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

  Widget _buildHighlightThumbnail(bool isVideo) {
    return Container(
      width: 120.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.grey[100],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            "https://images.unsplash.com/photo-1492684223066-81342ee5ff30",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFFAF7FF),
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.primary.withOpacity(0.5),
                size: 24.sp,
              ),
            ),
          ),
          if (isVideo)
            Center(
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 18.sp),
              ),
            ),
        ],
      ),
    );
  }
}
