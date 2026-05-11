import 'dart:io';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/home_models.dart';
import '../../models/circle_model.dart';
import '../../controllers/circle_controller.dart';
import '../../core/utils/date_utils.dart';
import '../messages/full_screen_video_player.dart';
import '../events/media_viewers.dart';
import 'circle_comment_item.dart';
import 'reaction_selector.dart';

class CirclePostItem extends StatefulWidget {
  final PostModel post;
  final CircleModel? circle;
  final bool showCircleName;

  const CirclePostItem({
    Key? key,
    required this.post,
    this.circle,
    this.showCircleName = false,
  }) : super(key: key);

  @override
  State<CirclePostItem> createState() => _CirclePostItemState();
}

class _CirclePostItemState extends State<CirclePostItem> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  File? _commentImage;
  File? _commentVideo;
  File? _commentFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _commentImage = File(image.path);
        _commentVideo = null;
        _commentFile = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _commentVideo = File(video.path);
        _commentImage = null;
        _commentFile = null;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _commentFile = File(result.files.single.path!);
        _commentImage = null;
        _commentVideo = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CircleController controller = Get.isRegistered<CircleController>()
        ? Get.find<CircleController>()
        : Get.put(CircleController());

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          if (widget.post.media.isNotEmpty) _buildMediaCarousel(),
          _buildFilesList(),
          SizedBox(height: 12.h),
          _buildStatsRow(),
          const Divider(height: 16),
          _buildInteractionRow(controller),
          SizedBox(height: 8.h),

          // Comments Section
          Obx(
            () => ListView.builder(
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
            ),
          ),

          // Comment Input
          Obx(
            () => widget.post.isCommenting.value
                ? _buildCommentInput(_commentController, (
                    text,
                    image,
                    video,
                    file,
                  ) {
                    controller.addCommentToPost(
                      circle: widget.circle,
                      post: widget.post,
                      content: text,
                      imageFile: image,
                      videoFile: video,
                      anyFile: file,
                    );
                    _commentController.clear();
                    setState(() {
                      _commentImage = null;
                      _commentVideo = null;
                      _commentFile = null;
                    });
                  })
                : const SizedBox.shrink(),
          ),
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
            backgroundImage: widget.post.userImage.isNotEmpty
                ? NetworkImage(widget.post.userImage)
                : null,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: widget.post.userImage.isEmpty
                ? Icon(Icons.person, color: AppColors.primary, size: 22.r)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.post.userName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B0B3B),
                        ),
                      ),
                    ),
                    if (widget.post.createdAt != null) ...[
                      SizedBox(width: 8.w),
                      Text(
                        AppDateUtils.timeAgo(
                          widget.post.createdAt!.toIso8601String(),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
                // Circle badge — shown on home feed when circleName is available
                if (widget.post.circleName != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the circle if possible
                        if (widget.circle != null) {
                          Get.toNamed(
                            widget.circle!.isJoined.value
                                ? '/joined-circle-details'
                                : '/public-circle-details',
                            arguments: widget.circle,
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 11.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                widget.post.circleName!,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (widget.post.userBio != null)
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

  Widget _buildMediaCarousel() {
    final mediaItems = widget.post.media;
    if (mediaItems.isEmpty) return const SizedBox.shrink();

    // Filter out files from carousel, handle them separately
    final visualMedia = mediaItems
        .where((m) => m.type == 'image' || m.type == 'video')
        .toList();
    if (visualMedia.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 300.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: visualMedia.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final media = visualMedia[index];
              final isNetwork =
                  media.url.startsWith('http') ||
                  media.url.startsWith('/uploads');
              final displayUrl = isNetwork ? media.fullUrl : media.url;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: media.type == 'video'
                          ? VideoPostPlayer(
                              videoUrl: displayUrl,
                              isLocal: !isNetwork,
                            )
                          : isNetwork
                          ? GestureDetector(
                              onTap: () => Get.to(
                                () => FullScreenImageViewer(
                                  imageUrl: media.fullUrl,
                                ),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: displayUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : Image.file(
                              File(media.url),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                    ),
                    if (media.isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (visualMedia.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                visualMedia.length,
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

  Widget _buildFilesList() {
    final files = widget.post.media.where((m) => m.type == 'file').toList();
    if (files.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: files.map((file) {
          return Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    file.url.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeading,
                    ),
                  ),
                ),
                if (file.isUploading)
                  SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.download_rounded,
                    color: Colors.grey[400],
                    size: 20.sp,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final reaction = widget.post.reactionType.value;
      if (reaction == "none") return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 8.h),
        child: Row(
          children: [
            Builder(
              builder: (context) {
                String emoji = "";
                IconData? icon;
                Color color = Colors.white;
                Color bgColor = AppColors.primary;

                switch (reaction) {
                  case "like":
                    emoji = "👍";
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
              },
            ),
            const Spacer(),
          ],
        ),
      );
    });
  }

  Widget _buildInteractionRow(CircleController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() {
            final reaction = widget.post.reactionType.value;
            IconData icon = Icons.add_reaction_outlined;
            Color color = widget.post.isLiked.value
                ? AppColors.primary
                : AppColors.textHeading;
            String label = "React";
            String emoji = widget.post.isLiked.value ? "👍" : "";

            if (reaction != "none") {
              switch (reaction) {
                case "like":
                  emoji = "👍";
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
              onLongPressStart: (details) => _showReactionMenu(
                context,
                details.globalPosition,
                controller,
              ),
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
          _buildActionButton(
            Icons.chat_bubble_outline,
            "Comment",
            onTap: () => controller.toggleCommentInput(widget.post),
          ),
          _buildActionButton(
            Icons.share_outlined,
            "Share",
            onTap: () => _showShareBottomSheet(context, controller),
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

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
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

  Widget _buildCommentInput(
    TextEditingController controller,
    Function(String, File?, File?, File?) onAdd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_commentImage != null ||
            _commentVideo != null ||
            _commentFile != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _commentImage != null
                      ? Image.file(
                          _commentImage!,
                          height: 80.h,
                          width: 80.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 80.h,
                          width: 80.w,
                          color: Colors.black12,
                          child: Icon(
                            _commentVideo != null
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
                      _commentImage = null;
                      _commentVideo = null;
                      _commentFile = null;
                    }),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
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
                icon: Icon(
                  Icons.image_outlined,
                  color: Colors.grey[600],
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: _pickVideo,
                icon: Icon(
                  Icons.videocam_outlined,
                  color: Colors.grey[600],
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: _pickFile,
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.grey[600],
                  size: 22.sp,
                ),
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
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
                onPressed: () => onAdd(
                  controller.text,
                  _commentImage,
                  _commentVideo,
                  _commentFile,
                ),
                icon: Icon(Icons.send, color: AppColors.primary, size: 22.sp),
              ),
              SizedBox(width: 8.w),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareBottomSheet(
    BuildContext context,
    CircleController controller,
  ) {
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Share Post",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Shared a post from ${widget.post.userName}. Download Bonded to view more.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                "Share Now",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class VideoPostPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isLocal;

  const VideoPostPlayer({
    Key? key,
    required this.videoUrl,
    required this.isLocal,
  }) : super(key: key);

  @override
  State<VideoPostPlayer> createState() => _VideoPostPlayerState();
}

class _VideoPostPlayerState extends State<VideoPostPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  void _initializeController() {
    if (widget.isLocal) {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    } else {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0); // Mute by default in feed
        _controller.play();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        _controller.play();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: () {
        Get.to(
          () => FullScreenVideoPlayer(
            videoUrl: widget.videoUrl,
            isLocal: widget.isLocal,
          ),
        );
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            // Play/Pause icon overlay
            if (!_isPlaying)
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
