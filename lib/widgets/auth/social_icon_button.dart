import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialIconButton({
    Key? key,
    required this.iconPath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 60.h,
        width: 80.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: EdgeInsets.all(16.w),
        child: SvgPicture.asset(
          iconPath,
        ),
      ),
    );
  }
}
