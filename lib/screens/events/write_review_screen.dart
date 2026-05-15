import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_messenger.dart';
import '../../controllers/review_controller.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({Key? key}) : super(key: key);

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 5;
  late final String _eventId;
  late final ReviewController _controller;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _eventId = (Get.arguments is String) ? Get.arguments as String : '';
    _controller = Get.isRegistered<ReviewController>(tag: _eventId)
        ? Get.find<ReviewController>(tag: _eventId)
        : Get.put(ReviewController(), tag: _eventId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (_eventId.isEmpty) {
      AppMessenger.error('Missing event reference');
      return;
    }
    if (comment.isEmpty) {
      AppMessenger.error('Please enter a comment');
      return;
    }
    if (_rating < 1 || _rating > 5) {
      AppMessenger.error('Please select a rating');
      return;
    }
    final ok = await _controller.submitReview(
      eventId: _eventId,
      rating: _rating,
      comment: comment,
    );
    if (ok && mounted) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.rate_review_rounded,
                size: 60.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              "Let's rate your Event Experience!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Share your honest feedback so other guests know what to expect.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      Icons.star,
                      color: index < _rating ? Colors.orange : Colors.grey[300],
                      size: 40.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            const Divider(),
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText:
                      "What did you like? What could have been better? 😍",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            const Divider(),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.05),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: _controller.isSubmitting.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: _controller.isSubmitting.value
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              "Submit",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
