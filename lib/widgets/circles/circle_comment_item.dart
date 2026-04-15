import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/home_models.dart';
import '../../controllers/circle_controller.dart';

class CircleCommentItem extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;

  const CircleCommentItem({
    Key? key,
    required this.comment,
    this.isReply = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CircleController>();
    final replyController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: isReply ? 38.w : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 12.r : 16.r,
            backgroundImage: NetworkImage(comment.userImage),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment Bubble
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFFF), // Light purple bubble
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(2.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeading,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        comment.text,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.textHeading.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 6.h),
                
                // Action Buttons
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Row(
                    children: [
                      Text(
                        comment.timestamp,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      _buildActionButton("Like", onTap: () => controller.toggleLikeComment(comment)),
                      SizedBox(width: 16.w),
                      _buildActionButton("Reply", onTap: () => controller.toggleReplyInput(comment)),
                      SizedBox(width: 16.w),
                      _buildActionButton("Share"),
                    ],
                  ),
                ),

                // Reply Input Field
                Obx(() => comment.showReplyInput.value
                    ? Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: replyController,
                                style: GoogleFonts.inter(fontSize: 12.sp),
                                decoration: InputDecoration(
                                  hintText: "Write a reply...",
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.addReply(comment, replyController.text);
                                replyController.clear();
                              },
                              icon: Icon(Icons.send, color: AppColors.primary, size: 18.sp),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),

                // Nested Replies
                Obx(() => comment.replies.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Column(
                          children: comment.replies
                              .map((reply) => CircleCommentItem(comment: reply, isReply: true))
                              .toList(),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
