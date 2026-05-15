import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/date_utils.dart';
import '../../controllers/review_controller.dart';
import '../../models/event_model.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late final ReviewController controller;
  late final String eventId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    eventId = (Get.arguments is String) ? Get.arguments as String : '';
    controller = Get.put(ReviewController(), tag: eventId);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (eventId.isNotEmpty) controller.loadReviews(eventId);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMore.value &&
        !controller.isLoadingMore.value) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          "Reviews",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      bottomNavigationBar: eventId.isEmpty
          ? null
          : Container(
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
                onPressed: () async {
                  final didSubmit = await Get.toNamed(
                    AppRoutes.WRITE_REVIEW,
                    arguments: eventId,
                  );
                  if (didSubmit == true) {
                    controller.loadReviews(eventId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  "Write a Review",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
      body: Obx(() {
        if (controller.isLoading.value && controller.reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.loadReviews(eventId),
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildSummary(controller.summary.value),
              const Divider(),
              SizedBox(height: 10.h),
              if (controller.reviews.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Text(
                      "No reviews yet.",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                )
              else
                ...controller.reviews.map(_buildReviewItem),
              if (controller.isLoadingMore.value)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummary(ReviewSummary? summary) {
    final s = summary ?? ReviewSummary.empty();
    final avg = s.averageRating;
    final filledStars = avg.round().clamp(0, 5);
    final maxCount = s.ratingDistribution.values.fold<int>(
      0,
      (a, b) => b > a ? b : a,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    color: i < filledStars
                        ? Colors.orange
                        : Colors.orange.withOpacity(0.3),
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _formatReviewCount(s.totalReviews),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(width: 32.w),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1]
                  .map(
                    (star) => _buildRatingBar(
                      star,
                      maxCount == 0
                          ? 0
                          : (s.ratingDistribution[star] ?? 0) / maxCount,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatReviewCount(int total) {
    if (total >= 1000) {
      final k = (total / 1000).toStringAsFixed(1);
      return "(${k}k reviews)";
    }
    return "($total ${total == 1 ? 'review' : 'reviews'})";
  }

  Widget _buildRatingBar(int star, double progress) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(
            star.toString(),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                color: AppColors.primary,
                minHeight: 10.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: review.userImageUrl.isNotEmpty
                    ? NetworkImage(review.userImageUrl)
                    : null,
                child: review.userImageUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[500])
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isEmpty ? 'User' : review.userName,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B0B3B),
                      ),
                    ),
                    if (review.userEmail.isNotEmpty)
                      Text(
                        review.userEmail,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    color: i < review.rating.round()
                        ? Colors.orange
                        : Colors.grey[300],
                    size: 16.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppDateUtils.timeAgo(review.date),
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
