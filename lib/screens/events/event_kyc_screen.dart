import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/events/event_success_dialog.dart';

class EventKYCScreen extends StatefulWidget {
  const EventKYCScreen({Key? key}) : super(key: key);

  @override
  State<EventKYCScreen> createState() => _EventKYCScreenState();
}

class _EventKYCScreenState extends State<EventKYCScreen> {
  String? _frontImagePath;
  String? _backImagePath;

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isFront) _frontImagePath = pickedFile.path;
        else _backImagePath = pickedFile.path;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EventSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Add KYC Document",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              "Choose how you want to connect with others and discover new friendships, communities, and shared interests along the way.",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            _buildUploadSection("Upload ID Card Front-side", _frontImagePath, () => _pickImage(true)),
            SizedBox(height: 24.h),
            _buildUploadSection("Upload ID Card Back-side", _backImagePath, () => _pickImage(false)),

            SizedBox(height: 48.h),

            ElevatedButton(
              onPressed: _showSuccessDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.05),
                foregroundColor: AppColors.primary,
                elevation: 0,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                "Continue",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(String title, String? imagePath, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FF),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: imagePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.article_outlined, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Upload Picture",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B0B3B),
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(File(imagePath), fit: BoxFit.cover, width: double.infinity),
                ),
          ),
        ),
      ],
    );
  }
}
