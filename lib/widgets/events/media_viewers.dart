import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MockVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const MockVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<MockVideoPlayer> createState() => _MockVideoPlayerState();
}

class _MockVideoPlayerState extends State<MockVideoPlayer> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white70,
                  size: 80.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  _isPlaying ? "Simulating Video Playback..." : "Tap to Play",
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isPlaying) ...[
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white24,
                      color: const Color(0xFF7128D0),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Tap to toggle play/pause
          GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
