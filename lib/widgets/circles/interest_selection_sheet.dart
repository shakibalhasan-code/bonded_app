import 'package:bonded_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';

class InterestSelectionSheet extends StatefulWidget {
  final List<String> initialSelected; // Names
  final Function(List<String>) onSelected; // Returns names

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
  final profileController = Get.find<ProfileController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.initialSelected);
    // Fetch interests if not already fetched
    if (profileController.allInterests.isEmpty) {
      profileController.fetchInterests();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Interests",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeading,
                  ),
                ),
                if (_tempSelected.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _tempSelected.clear()),
                    child: Text(
                      "Clear All",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Search interests...",
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          Expanded(
            child: Obx(() {
              if (profileController.isLoadingInterests.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final allInterests = profileController.allInterests;
              if (allInterests.isEmpty) {
                return const Center(child: Text("No interests found"));
              }

              // Filter and Group
              final filteredInterests = allInterests
                  .where(
                    (i) =>
                        i.name.toLowerCase().contains(_searchQuery) ||
                        i.category.toLowerCase().contains(_searchQuery),
                  )
                  .toList();

              if (filteredInterests.isEmpty) {
                return Center(
                  child: Text(
                    "No match found for '$_searchQuery'",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                );
              }

              // Group manually to handle filtering
              final Map<String, List<Interest>> categories = {};
              for (var i in filteredInterests) {
                final cat = i.category
                    .split('-')
                    .map((word) => word.capitalizeFirst)
                    .join(' ');
                if (!categories.containsKey(cat)) categories[cat] = [];
                categories[cat]!.add(i);
              }

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: categories.entries.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          category.key,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B0B3B).withOpacity(0.8),
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: category.value.map((interest) {
                          final isSelected = _tempSelected.contains(
                            interest.name,
                          );
                          return GestureDetector(
                            onTap: () => _toggleInterest(interest.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.2,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              constraints: BoxConstraints(maxWidth: 0.8.sw),
                              child: Text(
                                interest.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1B0B3B),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  );
                }).toList(),
              );
            }),
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
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: Text(
                  "Done (${_tempSelected.length})",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
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
