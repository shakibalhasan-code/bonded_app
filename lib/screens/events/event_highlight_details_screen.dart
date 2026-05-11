import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/theme/app_colors.dart';
import '../../models/highlight_model.dart';
import '../../core/constants/app_endpoints.dart';
import '../../widgets/events/media_viewers.dart';

class EventHighlightDetailsScreen extends StatefulWidget {
  const EventHighlightDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EventHighlightDetailsScreen> createState() => _EventHighlightDetailsScreenState();
}

class _EventHighlightDetailsScreenState extends State<EventHighlightDetailsScreen> {
  late List<_HighlightMediaItem> _mediaItems;
  bool _showReel = false;

  @override
  void initState() {
    super.initState();
    final HighlightModel highlight = Get.arguments;
    final List<HighlightVideo> videos = highlight.videos ?? [];
    final List<HighlightImage> images = highlight.images ?? [];

    _mediaItems = [
      ...videos.map((v) => _HighlightMediaItem(url: AppUrls.imageUrl(v.url ?? ""), isVideo: true)),
      ...images.map((i) => _HighlightMediaItem(url: AppUrls.imageUrl(i.url ?? ""), isVideo: false)),
    ];

    if (_mediaItems.isNotEmpty) {
      _showReel = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HighlightModel highlight = Get.arguments;

    if (_showReel) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _mediaItems.length,
              itemBuilder: (context, index) {
                final item = _mediaItems[index];
                if (item.isVideo) {
                  return _ReelVideoPlayer(videoUrl: item.url);
                } else {
                  return _ReelImageViewer(imageUrl: item.url);
                }
              },
            ),
            // Header
            Positioned(
              top: 50.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      highlight.event?.title ?? "Highlight",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showReel = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Details",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Caption Overlay (Bottom)
            Positioned(
              bottom: 40.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (highlight.caption != null && highlight.caption!.isNotEmpty)
                    Text(
                      highlight.caption!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  if (highlight.taggedAttendees != null && highlight.taggedAttendees!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 32.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: highlight.taggedAttendees!.length,
                        itemBuilder: (context, idx) {
                          final user = highlight.taggedAttendees![idx];
                          return Container(
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 10.r,
                                  backgroundImage: NetworkImage(AppUrls.imageUrl(user.avatar ?? "")),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  user.fullName ?? "User",
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Traditional Details View
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () {
            if (_mediaItems.isNotEmpty) {
              setState(() => _showReel = true);
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          highlight.event?.title ?? "Highlight Details",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Grid (if any)
            if (_mediaItems.isNotEmpty) ...[
              _buildSectionTitle("Highlights"),
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
                itemCount: _mediaItems.length,
                itemBuilder: (context, index) {
                  final item = _mediaItems[index];
                  return GestureDetector(
                    onTap: () {
                      // Optionally jump to specific page in reel
                      setState(() => _showReel = true);
                    },
                    child: item.isVideo 
                      ? _buildVideoThumbnail(item.url)
                      : _buildImageThumbnail(item.url),
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],

            // Event Name Section
            _buildSectionTitle("Event Name"),
            SizedBox(height: 8.h),
            Text(
              highlight.event?.title ?? "N/A",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 24.h),

            // Caption Section
            if (highlight.caption != null && highlight.caption!.isNotEmpty) ...[
              _buildSectionTitle("Caption"),
              SizedBox(height: 12.h),
              Text(
                highlight.caption!,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: const Color(0xFF1B0B3B),
                  height: 1.6,
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Tagged Attendees
            if (highlight.taggedAttendees != null && highlight.taggedAttendees!.isNotEmpty) ...[
              _buildSectionTitle("Tagged Attendees"),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                children: highlight.taggedAttendees!.map((user) => Chip(
                  avatar: CircleAvatar(
                    backgroundImage: NetworkImage(AppUrls.imageUrl(user.avatar ?? "")),
                  ),
                  label: Text(user.fullName ?? "User"),
                )).toList(),
              ),
              SizedBox(height: 24.h),
            ],

            // Tagged Circles
            if (highlight.taggedCircles != null && highlight.taggedCircles!.isNotEmpty) ...[
              _buildSectionTitle("Tagged Circles"),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                children: highlight.taggedCircles!.map((circle) => Chip(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  label: Text(circle.name ?? "Circle", style: TextStyle(color: AppColors.primary)),
                )).toList(),
              ),
              SizedBox(height: 24.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B0B3B),
      ),
    );
  }

  Widget _buildVideoThumbnail(String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFF7128D0).withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.play_arrow, color: Colors.white, size: 24.sp),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _HighlightMediaItem {
  final String url;
  final bool isVideo;
  _HighlightMediaItem({required this.url, required this.isVideo});
}

class _ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _ReelVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<_ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<_ReelVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      placeholder: Container(color: Colors.black),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
  }
}

class _ReelImageViewer extends StatelessWidget {
  final String imageUrl;

  const _ReelImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      ),
    );
  }
}
