import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class MyEventsSubNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const MyEventsSubNav({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      "Created Event",
      "Booked Event",
      "My E-Tickets",
      "My Wallet",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
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
            ),
          );
        }),
      ),
    );
  }
}
