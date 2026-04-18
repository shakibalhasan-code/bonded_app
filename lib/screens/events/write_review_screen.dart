import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({Key? key}) : super(key: key);

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.network(
                "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3",
                width: 200.w,
                height: 200.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              "Let's rate your Event Experience!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.star,
                    color: index < _rating ? Colors.orange : Colors.grey[300],
                    size: 40.sp,
                  ),
                ),
              )),
            ),
            SizedBox(height: 40.h),
            const Divider(),
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "The food is very tasty and in good condition. I like it very much 😍😍",
                  hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            const Divider(),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
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
                      "Cancel",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
