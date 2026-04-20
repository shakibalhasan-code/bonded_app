import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/home_models.dart';
import '../../controllers/circle_controller.dart';
import 'circle_comment_item.dart';

class CirclePostItem extends StatefulWidget {
  final PostModel post;

  const CirclePostItem({Key? key, required this.post}) : super(key: key);

  @override
  State<CirclePostItem> createState() => _CirclePostItemState();
}

class _CirclePostItemState extends State<CirclePostItem> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CircleController>();
    final commentController = TextEditingController();

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(),
          SizedBox(height: 12.h),
          if (widget.post.postText.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                widget.post.postText,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHeading,
                  height: 1.5,
                ),
              ),
            ),
          SizedBox(height: 12.h),
          if (widget.post.images.isNotEmpty) _buildImageCarousel(),
          SizedBox(height: 12.h),
          _buildStatsRow(),
          const Divider(height: 32),
          _buildInteractionRow(controller),
          
          // Comments Section
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: widget.post.comments.length,
                itemBuilder: (context, index) {
                  return CircleCommentItem(comment: widget.post.comments[index]);
                },
              )),
          
          // Comment Input
          Obx(() => widget.post.isCommenting.value
              ? _buildCommentInput(commentController, (text) {
                  controller.addComment(widget.post, text);
                  commentController.clear();
                })
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundImage: NetworkImage(widget.post.userImage),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.userName,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
                if (widget.post.userBio != null)
                  Text(
                    widget.post.userBio!,
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
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 300.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.post.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  image: DecorationImage(
                    image: NetworkImage(widget.post.images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.post.images.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.post.images.length,
                (index) => Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Color(0xFF6C38FF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.thumb_up, size: 10.sp, color: Colors.white),
          ),
          SizedBox(width: 4.w),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B3B),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite, size: 10.sp, color: Colors.white),
          ),
          SizedBox(width: 8.w),
          Text(
            widget.post.likesCount.value.toString(),
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
          const Spacer(),
          Text(
            "${widget.post.commentsCount.value} comments",
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          SizedBox(width: 12.w),
          Text(
            "${widget.post.sharesCount.value} shares",
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionRow(CircleController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.thumb_up_outlined, "Like", onTap: () => controller.toggleLikePost(widget.post)),
          _buildActionButton(Icons.chat_bubble_outline, "Comment", onTap: () => controller.toggleCommentInput(widget.post)),
          _buildActionButton(Icons.share_outlined, "Share"),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textHeading),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(TextEditingController controller, Function(String) onAdd) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: "Write a comment...",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
            icon: Icon(Icons.send, color: AppColors.primary, size: 22.sp),
          ),
        ],
      ),
    );
  }
}
