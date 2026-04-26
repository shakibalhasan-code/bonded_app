import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';

class InterestSelectionSheet extends StatefulWidget {
  final List<String> initialSelected;
  final Function(List<String>) onSelected;

  const InterestSelectionSheet({
    Key? key,
    required this.initialSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<InterestSelectionSheet> createState() => _InterestSelectionSheetState();
}

class _InterestSelectionSheetState extends State<InterestSelectionSheet> {
  late List<String> _tempSelected;

  final Map<String, List<String>> interestCategories = {
    "Social & Lifestyle": [
      "Brunch Lovers", "Wine Nights", "Game Nights", "Movie Lovers", 
      "Foodies", "Coffee Dates", "Picnic & Outdoor Chill", "Book Clubs", 
      "Fashion & Style", "Pet Lovers", "Photography", "Creators"
    ],
    "Sports & Fitness": [
      "Gym & Fitness", "Running", "Yoga", "Hiking", "Cycling"
    ]
  };

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.initialSelected);
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_tempSelected.contains(interest)) {
        _tempSelected.remove(interest);
      } else {
        _tempSelected.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.8.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "Select Interests",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              children: interestCategories.entries.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.key,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...category.value.map((interest) {
                      final isSelected = _tempSelected.contains(interest);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => _toggleInterest(interest),
                        title: Text(
                          interest,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                      );
                    }),
                    SizedBox(height: 20.h),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSelected(_tempSelected);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  elevation: 0,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Done",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
