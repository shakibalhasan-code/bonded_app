import 'dart:io';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/circle_model.dart';
import '../../controllers/circle_controller.dart';
import '../../controllers/auth_controller.dart';

class CreatePostSheet extends StatefulWidget {
  final CircleModel circle;

  const CreatePostSheet({Key? key, required this.circle}) : super(key: key);

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedImages = [];
  File? _selectedVideo;
  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CircleController>();
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        12.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 48.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Header
            Row(
              children: [
                Text(
                  "Create Post",
                  style: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
                const Spacer(),
                Obx(
                  () => controller.isLoading.value
                      ? SizedBox(
                          height: 20.w,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            if (_textController.text.trim().isEmpty &&
                                _selectedImages.isEmpty &&
                                _selectedVideo == null &&
                                _selectedFile == null) {
                              Get.snackbar(
                                "Empty Post",
                                "Please add some content or media to your post.",
                              );
                              return;
                            }
                            controller.createCirclePost(
                              circle: widget.circle,
                              content: _textController.text,
                              images: _selectedImages,
                              video: _selectedVideo,
                              file: _selectedFile,
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 8.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          child: Text(
                            "Post",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // User Info
            if (user != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: NetworkImage(
                      AppUrls.imageUrl(user.avatar),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName ?? user.username ?? "Anonymous",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B0B3B),
                        ),
                      ),
                      Text(
                        "Posting to ${widget.circle.name}",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 16.h),

            // Input Area
            TextField(
              controller: _textController,
              maxLines: null,
              minLines: 3,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                color: const Color(0xFF1B0B3B),
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 15.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 16.h),

            // Media Preview
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 12.w),
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4.h,
                          right: 16.w,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: const BoxDecoration(
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
                    );
                  },
                ),
              ),

            if (_selectedVideo != null)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 40.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Video Selected",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: _removeVideo,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            if (_selectedFile != null)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 100.h,
                    margin: EdgeInsets.only(top: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 32.sp,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "File Selected",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: _removeFile,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            SizedBox(height: 24.h),
            const Divider(height: 1),
            SizedBox(height: 16.h),

            // Actions
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.image_outlined,
                          label: "Photo",
                          color: const Color(0xFF4CAF50),
                          onTap: _pickImages,
                        ),
                        SizedBox(width: 8.w),
                        _buildActionButton(
                          icon: Icons.videocam_outlined,
                          label: "Video",
                          color: const Color(0xFFE91E63),
                          onTap: _pickVideo,
                        ),
                        SizedBox(width: 8.w),
                        _buildActionButton(
                          icon: Icons.attach_file,
                          label: "File",
                          color: const Color(0xFF2196F3),
                          onTap: _pickFile,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "${_textController.text.length}/1000",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
