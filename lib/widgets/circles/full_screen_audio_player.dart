import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';

class FullScreenAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final bool isLocal;

  const FullScreenAudioPlayer({
    Key? key,
    required this.audioUrl,
    this.isLocal = false,
  }) : super(key: key);

  @override
  State<FullScreenAudioPlayer> createState() => _FullScreenAudioPlayerState();
}

class _FullScreenAudioPlayerState extends State<FullScreenAudioPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() async {
    if (widget.isLocal) {
      _controller = VideoPlayerController.file(File(widget.audioUrl));
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.audioUrl));
    }

    await _controller.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Audio Player",
          style: GoogleFonts.inter(
            color: const Color(0xFF1B0B3B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.music_note,
                  size: 100.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 48.h),
              if (_isInitialized) ...[
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, VideoPlayerValue value, child) {
                    final duration = value.duration.inMilliseconds;
                    final position = value.position.inMilliseconds;
                    return Column(
                      children: [
                        Slider(
                          value: position.toDouble().clamp(0.0, duration.toDouble()),
                          min: 0.0,
                          max: duration.toDouble() > 0 ? duration.toDouble() : 1.0,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            _controller.seekTo(Duration(milliseconds: val.toInt()));
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(value.position),
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _formatDuration(value.duration),
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.replay_10,
                        size: 32.sp,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        final newPos = _controller.value.position - const Duration(seconds: 10);
                        _controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                      },
                    ),
                    SizedBox(width: 24.w),
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 80.sp,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                    ),
                    SizedBox(width: 24.w),
                    IconButton(
                      icon: Icon(
                        Icons.forward_10,
                        size: 32.sp,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        final newPos = _controller.value.position + const Duration(seconds: 10);
                        _controller.seekTo(newPos > _controller.value.duration ? _controller.value.duration : newPos);
                      },
                    ),
                  ],
                ),
              ] else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
