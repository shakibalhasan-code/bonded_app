import 'package:bonded_app/controllers/circle_controller.dart';
import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/home_models.dart';
import '../../controllers/home_controller.dart';

class CircleHighlightCard extends StatelessWidget {
  final PostModel post;

  const CircleHighlightCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final commentController = TextEditingController();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 8.h),
          Text(
            post.postText,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textHeading,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          _buildStats(),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey[100]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => _buildInteractionButton(
                  post.isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
                  post.isLiked.value ? "Liked" : "Like",
                  isActive: post.isLiked.value,
                  onTap: () => controller.toggleLikePost(post),
                ),
              ),
              _buildInteractionButton(
                Icons.chat_bubble_outline,
                "Comment",
                onTap: () => controller.toggleCommentInput(post),
              ),
            ],
          ),

          // Comment Input Field
          Obx(
            () => post.isCommenting.value
                ? _buildCommentInput(commentController, (text) {
                    controller.addComment(post, text);
                    commentController.clear();
                  })
                : const SizedBox.shrink(),
          ),

          SizedBox(height: 12.h),

          // Comments List
          Obx(
            () => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: post.comments.length,
              itemBuilder: (context, index) {
                return _CommentItem(comment: post.comments[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          post.userName,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Find the circle from CircleController or create a dummy one
            final circleController = Get.find<CircleController>();
            final circle = circleController.publicCircles.firstWhere(
              (c) => c.name == post.userName,
              orElse: () => circleController.myJoinedCircles.firstWhere(
                (c) => c.name == post.userName,
                orElse: () => circleController.publicCircles.first,
              ),
            );
            Get.toNamed(AppRoutes.JOINED_CIRCLE_DETAILS, arguments: circle);
          },
          child: Text(
            "View Details",
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Icon(Icons.thumb_up, size: 14.sp, color: Colors.orange),
        SizedBox(width: 4.w),
        Obx(
          () => Text(
            "${post.likesCount.value}",
            style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey[600]),
          ),
        ),
        const Spacer(),
        Obx(
          () => Text(
            "${post.commentsCount.value} comments",
            style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isActive ? AppColors.primary : Colors.grey[600],
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput(
    TextEditingController controller,
    Function(String) onAdd,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: "Write a comment...",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () => onAdd(controller.text),
            icon: Icon(Icons.send, color: AppColors.primary, size: 20.sp),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentModel comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final replyController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FF),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundImage: NetworkImage(comment.userImage),
                ),
                SizedBox(width: 10.w),
                Expanded(
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
                      SizedBox(height: 2.h),
                      Text(
                        comment.text,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textHeading,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Obx(
                            () => _buildActionText(
                              comment.isLiked.value ? "Liked" : "Like",
                              isActive: comment.isLiked.value,
                              onTap: () =>
                                  controller.toggleLikeComment(comment),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          _buildActionText(
                            "Reply",
                            onTap: () => controller.toggleReplyInput(comment),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            comment.timestamp,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                          const Spacer(),
                          Obx(
                            () => comment.likesCount.value > 0
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_up,
                                        size: 10.sp,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "${comment.likesCount.value}",
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Reply Input
            Obx(
              () => comment.showReplyInput.value
                  ? Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 38.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyController,
                              style: GoogleFonts.inter(fontSize: 12.sp),
                              decoration: InputDecoration(
                                hintText: "Reply...",
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              controller.addReply(
                                comment,
                                replyController.text,
                              );
                              replyController.clear();
                            },
                            icon: Icon(
                              Icons.send,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Replies List
            Obx(
              () => comment.replies.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 38.w),
                      child: Column(
                        children: comment.replies
                            .map((reply) => _ReplyItem(reply: reply))
                            .toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionText(
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.primary : Colors.grey[700],
        ),
      ),
    );
  }
}

class _ReplyItem extends StatelessWidget {
  final CommentModel reply;

  const _ReplyItem({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10.r,
            backgroundImage: NetworkImage(reply.userImage),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.userName,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(reply.text, style: GoogleFonts.inter(fontSize: 11.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
