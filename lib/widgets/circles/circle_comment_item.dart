import 'dart:io';
import 'package:bonded_app/widgets/circles/reaction_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../models/home_models.dart';
import '../../models/circle_model.dart';
import '../../controllers/circle_controller.dart';
import 'package:intl/intl.dart';
import '../../core/utils/date_utils.dart';
import '../events/media_viewers.dart';

class CircleCommentItem extends StatefulWidget {
  final CommentModel comment;
  final PostModel post;
  final bool isReply;

  final CircleModel? circle;

  const CircleCommentItem({
    Key? key,
    required this.comment,
    this.circle,
    required this.post,
    this.isReply = false,
  }) : super(key: key);

  @override
  State<CircleCommentItem> createState() => _CircleCommentItemState();
}

class _CircleCommentItemState extends State<CircleCommentItem> {
  final TextEditingController _replyController = TextEditingController();
  File? _replyImage;
  File? _replyVideo;
  File? _replyFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _replyImage = File(image.path);
        _replyVideo = null;
        _replyFile = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _replyVideo = File(video.path);
        _replyImage = null;
        _replyFile = null;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _replyFile = File(result.files.single.path!);
        _replyImage = null;
        _replyVideo = null;
      });
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CircleController>();

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: widget.isReply ? 38.w : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: widget.isReply ? 12.r : 16.r,
            backgroundImage: NetworkImage(widget.comment.userImage),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment Bubble
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
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
                        widget.comment.userName,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeading,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.comment.text,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.textHeading.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                      if (widget.comment.media.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        ...widget.comment.media.map((m) {
                          if (m.type == 'image') {
                            return GestureDetector(
                              onTap: () => Get.to(
                                () =>
                                    FullScreenImageViewer(imageUrl: m.fullUrl),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  m.fullUrl,
                                  height: 150.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 150.h,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error_outline),
                                      ),
                                ),
                              ),
                            );
                          } else if (m.type == 'video') {
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => MockVideoPlayer(videoUrl: m.fullUrl),
                              ),
                              child: Container(
                                height: 150.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.videocam,
                                      color: Colors.white70,
                                      size: 40,
                                    ),
                                    const Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white70,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(m.fullUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                margin: EdgeInsets.only(top: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file,
                                      color: AppColors.primary,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Builder(
                                        builder: (context) {
                                          String ext = m.fullUrl
                                              .split('.')
                                              .last
                                              .toUpperCase();
                                          if (ext.length > 5 ||
                                              ext.contains('?'))
                                            ext = 'FILE';
                                          return Text(
                                            "$ext Attachment",
                                            style: GoogleFonts.inter(
                                              fontSize: 13.sp,
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Icon(
                                      Icons.download,
                                      color: Colors.grey[600],
                                      size: 20.sp,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }).toList(),
                      ],
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
                        _formatTimestamp(widget.comment.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Obx(() {
                        final isLiked = widget.comment.isLiked.value;
                        final type = widget.comment.reactionType.value;
                        String label = "React";
                        String emoji = "";
                        Color reactionColor = isLiked
                            ? AppColors.primary
                            : Colors.grey[700]!;
                        if (type != "none") {
                          switch (type) {
                            case "like":
                              label = "Liked";
                              reactionColor = Colors.blue;
                              break;
                            case "love":
                              label = "Loved";
                              emoji = "❤️";
                              reactionColor = Colors.red;
                              break;
                            case "care":
                              label = "Cared";
                              emoji = "🤗";
                              reactionColor = Colors.orange;
                              break;
                            case "haha":
                              label = "Haha";
                              emoji = "😆";
                              reactionColor = Colors.orange;
                              break;
                            case "wow":
                              label = "Wow";
                              emoji = "😮";
                              reactionColor = Colors.orange;
                              break;
                            case "sad":
                              label = "Sad";
                              emoji = "😢";
                              reactionColor = Colors.orange;
                              break;
                            case "angry":
                              label = "Angry";
                              emoji = "😡";
                              reactionColor = Colors.redAccent;
                              break;
                          }
                        }
                        return GestureDetector(
                          onTap: () =>
                              controller.toggleLikeComment(widget.comment),
                          onLongPressStart: (details) {
                            _showReactionMenu(
                              context,
                              details.globalPosition,
                              controller,
                            );
                          },
                          child: Row(
                            children: [
                              if (emoji.isNotEmpty) ...[
                                Text(emoji, style: TextStyle(fontSize: 12.sp)),
                                SizedBox(width: 4.w),
                              ],
                              Text(
                                label,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: reactionColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(width: 16.w),
                      _buildActionButton(
                        "Reply",
                        onTap: () =>
                            controller.toggleReplyInput(widget.comment),
                      ),
                    ],
                  ),
                ),

                // Reply Input Field
                Obx(
                  () => widget.comment.showReplyInput.value
                      ? Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_replyImage != null ||
                                  _replyVideo != null ||
                                  _replyFile != null)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        child: _replyImage != null
                                            ? Image.file(
                                                _replyImage!,
                                                height: 60.h,
                                                width: 60.w,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                height: 60.h,
                                                width: 60.w,
                                                color: Colors.black12,
                                                child: Icon(
                                                  _replyVideo != null
                                                      ? Icons.videocam
                                                      : Icons.insert_drive_file,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () => setState(() {
                                            _replyImage = null;
                                            _replyVideo = null;
                                            _replyFile = null;
                                          }),
                                          child: Container(
                                            padding: EdgeInsets.all(2.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 14.sp,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _pickImage,
                                    icon: Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey[600],
                                      size: 20.sp,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                  SizedBox(width: 4.w),
                                  IconButton(
                                    onPressed: _pickVideo,
                                    icon: Icon(
                                      Icons.videocam_outlined,
                                      color: Colors.grey[600],
                                      size: 20.sp,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                  SizedBox(width: 4.w),
                                  IconButton(
                                    onPressed: _pickFile,
                                    icon: Icon(
                                      Icons.attach_file,
                                      color: Colors.grey[600],
                                      size: 20.sp,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: TextField(
                                      controller: _replyController,
                                      style: GoogleFonts.inter(fontSize: 12.sp),
                                      decoration: InputDecoration(
                                        hintText: "Write a reply...",
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      controller.addCommentToPost(
                                        circle: widget.circle,
                                        post: widget.post,
                                        content: _replyController.text,
                                        parentPostId: widget.comment.id,
                                        imageFile: _replyImage,
                                        videoFile: _replyVideo,
                                        anyFile: _replyFile,
                                      );
                                      _replyController.clear();
                                      setState(() {
                                        _replyImage = null;
                                        _replyVideo = null;
                                        _replyFile = null;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.send,
                                      color: AppColors.primary,
                                      size: 18.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Nested Replies
                Obx(
                  () => widget.comment.replies.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Column(
                            children: widget.comment.replies
                                .map(
                                  (reply) => CircleCommentItem(
                                    comment: reply,
                                    circle: widget.circle,
                                    post: widget.post,
                                    isReply: true,
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReactionMenu(
    BuildContext context,
    Offset position,
    CircleController controller,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    const menuWidth = 320.0;

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
            top: position.dy - 80.h,
            child: ReactionSelector(
              onReactionSelected: (type) {
                controller.updateCommentReaction(widget.comment, type);
                Navigator.pop(context);
              },
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

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return "";
    return AppDateUtils.formatLocal(timestamp, format: 'd/M/y h:mm a').toLowerCase();
  }
}
