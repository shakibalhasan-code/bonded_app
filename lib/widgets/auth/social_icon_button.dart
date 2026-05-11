import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color loaderColor;

  const SocialIconButton({
    Key? key,
    required this.iconPath,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.loaderColor = const Color(0xFF4285F4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || isDisabled) ? null : onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDisabled && !isLoading ? 0.35 : 1.0,
        child: Container(
          height: 60.h,
          width: 80.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isLoading
                  ? loaderColor.withValues(alpha: 0.35)
                  : Colors.grey[200]!,
            ),
          ),
          padding: EdgeInsets.all(14.w),
          child: isLoading
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(iconPath),
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(loaderColor),
                      ),
                    ),
                  ],
                )
              : SvgPicture.asset(iconPath),
        ),
      ),
    );
  }
}
