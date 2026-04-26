import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final bool isExpandable;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final String? title;

  const CustomSearchField({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hintText = "Search...",
    this.onClear,
    this.isExpandable = false,
    this.isExpanded = true,
    this.onToggle,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isExpandable && !isExpanded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != null)
            Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeading,
              ),
            ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              Icons.search,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    autofocus: isExpandable && isExpanded,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textHeading,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged("");
                      if (onClear != null) onClear!();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 18.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isExpandable)
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
