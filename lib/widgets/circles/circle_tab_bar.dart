import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class CircleTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final List<String> tabs;

  const CircleTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onTabChanged(index),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[index],
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.grey[500],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class CircleSubTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final List<String> tabs;

  const CircleSubTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onTabChanged(index),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.primary,
                  width: 1,
                ),
              ),
              child: Text(
                tabs[index],
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
