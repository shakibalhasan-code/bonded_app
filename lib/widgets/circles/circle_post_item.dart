import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/home_models.dart';
import '../../models/circle_model.dart';
import '../../controllers/circle_controller.dart';
import 'circle_comment_item.dart';
import 'reaction_selector.dart';

class CirclePostItem extends StatefulWidget {
  final PostModel post;
  final CircleModel circle;

  const CirclePostItem({Key? key, required this.post, required this.circle}) : super(key: key);

  @override
  State<CirclePostItem> createState() => _CirclePostItemState();
}

class _CirclePostItemState extends State<CirclePostItem> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  File? _commentImage;
  File? _commentVideo;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _commentImage = File(image.path);
        _commentVideo = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _commentVideo = File(video.path);
        _commentImage = null;
      });
    }
  }

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
          SizedBox(height: 10.h),
          
          // Comments Section
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: widget.post.comments.length,
                itemBuilder: (context, index) {
                  return CircleCommentItem(
                    comment: widget.post.comments[index],
                    circle: widget.circle,
                    post: widget.post,
                  );
                },
              )),
          
          // Comment Input
          Obx(() => widget.post.isCommenting.value
              ? _buildCommentInput(commentController, (text, image, video) {
                  controller.addCommentToPost(
                    circle: widget.circle,
                    post: widget.post,
                    content: text,
                    imageFile: image,
                    videoFile: video,
                  );
                  commentController.clear();
                  setState(() {
                    _commentImage = null;
                    _commentVideo = null;
                  });
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
          Obx(() {
            final reaction = widget.post.reactionType.value;
            if (reaction == "none") return const SizedBox.shrink();

            String emoji = "";
            IconData? icon;
            Color color = Colors.white;
            Color bgColor = AppColors.primary;

            switch (reaction) {
              case "like":
                icon = Icons.thumb_up;
                bgColor = Colors.blue;
                break;
              case "love":
                emoji = "❤️";
                bgColor = Colors.red;
                break;
              case "care":
                emoji = "🤗";
                bgColor = Colors.orange;
                break;
              case "haha":
                emoji = "😆";
                bgColor = Colors.orange;
                break;
              case "wow":
                emoji = "😮";
                bgColor = Colors.orange;
                break;
              case "sad":
                emoji = "😢";
                bgColor = Colors.orange;
                break;
              case "angry":
                emoji = "😡";
                bgColor = Colors.redAccent;
                break;
            }

            return Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: emoji.isNotEmpty
                  ? Text(emoji, style: TextStyle(fontSize: 10.sp))
                  : Icon(icon, size: 10.sp, color: color),
            );
          }),
          const Spacer(),
          // All counts (likes, comments, shares) have been removed per user request
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
          Obx(() {
            final reaction = widget.post.reactionType.value;
            IconData icon = widget.post.isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined;
            Color color = widget.post.isLiked.value ? AppColors.primary : AppColors.textHeading;
            String label = "React";
            String emoji = "";

            if (reaction != "none") {
              switch (reaction) {
                case "like":
                  icon = Icons.thumb_up;
                  color = Colors.blue;
                  label = "Liked";
                  break;
                case "love":
                  emoji = "❤️";
                  color = Colors.red;
                  label = "Loved";
                  break;
                case "care":
                  emoji = "🤗";
                  color = Colors.orange;
                  label = "Cared";
                  break;
                case "haha":
                  emoji = "😆";
                  color = Colors.orange;
                  label = "Haha";
                  break;
                case "wow":
                  emoji = "😮";
                  color = Colors.orange;
                  label = "Wow";
                  break;
                case "sad":
                  emoji = "😢";
                  color = Colors.orange;
                  label = "Sad";
                  break;
                case "angry":
                  emoji = "😡";
                  color = Colors.redAccent;
                  label = "Angry";
                  break;
              }
            }

            return GestureDetector(
              onTap: () => controller.toggleLikePost(widget.post),
              onLongPressStart: (details) => _showReactionMenu(context, details.globalPosition, controller),
              child: Row(
                children: [
                  emoji.isNotEmpty
                      ? Text(emoji, style: TextStyle(fontSize: 20.sp))
                      : Icon(icon, size: 20.sp, color: color),
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
          _buildActionButton(Icons.chat_bubble_outline, "Comment",
              onTap: () => controller.toggleCommentInput(widget.post)),
          _buildActionButton(Icons.share_outlined, "Share",
              onTap: () => _showShareBottomSheet(context, controller)),
        ],
      ),
    );
  }

  void _showReactionMenu(BuildContext context, Offset position, CircleController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    const menuWidth = 320.0; // Estimated width including padding
    
    // Calculate centered position but clamp to screen edges
    double leftPosition = position.dx - (menuWidth / 2);
    if (leftPosition < 16.w) leftPosition = 16.w;
    if (leftPosition + menuWidth > screenWidth - 16.w) {
      leftPosition = screenWidth - menuWidth - 16.w;
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            left: leftPosition,
            top: position.dy - 80.h, // Position above the touch point
            child: ReactionSelector(
              onReactionSelected: (type) {
                controller.updatePostReaction(widget.post, type);
                Navigator.pop(context);
              },
            ),
          ),
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

  Widget _buildCommentInput(TextEditingController controller, Function(String, File?, File?) onAdd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_commentImage != null || _commentVideo != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _commentImage != null
                      ? Image.file(_commentImage!, height: 80.h, width: 80.w, fit: BoxFit.cover)
                      : Container(
                          height: 80.h,
                          width: 80.w,
                          color: Colors.black12,
                          child: Icon(Icons.videocam, color: AppColors.primary),
                        ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _commentImage = null;
                      _commentVideo = null;
                    }),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.close, size: 16.sp, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              IconButton(
                onPressed: _pickImage,
                icon: Icon(Icons.image_outlined, color: Colors.grey[600], size: 22.sp),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: _pickVideo,
                icon: Icon(Icons.videocam_outlined, color: Colors.grey[600], size: 22.sp),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 12.w),
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
                onPressed: () => onAdd(controller.text, _commentImage, _commentVideo),
                icon: Icon(Icons.send, color: AppColors.primary, size: 22.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareBottomSheet(BuildContext context, CircleController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
            ),
            SizedBox(height: 24.h),
            Text(
              "Share Post",
              style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1B0B3B)),
            ),
            SizedBox(height: 16.h),
            Text(
              "Shared a post from ${widget.post.userName}. Download Bonded to view more.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.sharePost(widget.circle, widget.post);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
              ),
              child: Text(
                "Share Now",
                style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
