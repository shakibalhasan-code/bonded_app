import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../core/constants/app_assets.dart';

/// Mimics the real "Review app required" dialogs shown by Google, Apple, and Facebook.
class SocialAuthErrorDialog {
  static void show(String provider) {
    if (Platform.isIOS && provider == 'apple') {
      Get.dialog(_AppleDialog(), barrierDismissible: false);
    } else {
      Get.dialog(_MaterialProviderDialog(provider: provider),
          barrierDismissible: false);
    }
  }
}

// ─── Apple (iOS-native Cupertino style) ────────────────────────────────────

class _AppleDialog extends StatelessWidget {
  const _AppleDialog();

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Sign in with Apple'),
      content: Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: const Text(
          'Review app required by Apple.\n\n'
          'This app has not completed Apple\'s review process. '
          'Sign-in is currently restricted.',
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: Get.back,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// ─── Google / Facebook (Material, provider-branded) ────────────────────────

class _MaterialProviderDialog extends StatelessWidget {
  final String provider;

  const _MaterialProviderDialog({required this.provider});

  @override
  Widget build(BuildContext context) {
    final config = _providerConfig(provider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header bar ──────────────────────────────────────────
          Container(
            color: config.headerColor,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                SvgPicture.asset(config.iconAsset, width: 22.r, height: 22.r),
                SizedBox(width: 10.w),
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: config.titleColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 22.r, color: const Color(0xFFE8710A)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review app required by ${config.name}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF202124),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'This app has not completed ${config.name}\'s '
                        'verification process. Sign-in may be restricted '
                        'for security reasons.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.5,
                          color: const Color(0xFF5F6368),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Action ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: Get.back,
                style: TextButton.styleFrom(
                  foregroundColor: config.accentColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ProviderConfig _providerConfig(String provider) {
    switch (provider) {
      case 'google':
        return _ProviderConfig(
          name: 'Google',
          title: 'Sign in with Google',
          iconAsset: AppAssets.googleIcon,
          headerColor: const Color(0xFFF8F9FA),
          titleColor: const Color(0xFF202124),
          accentColor: const Color(0xFF1A73E8),
        );
      case 'facebook':
        return _ProviderConfig(
          name: 'Facebook',
          title: 'Log in with Facebook',
          iconAsset: AppAssets.facebookIcon,
          headerColor: const Color(0xFF1877F2),
          titleColor: Colors.white,
          accentColor: const Color(0xFF1877F2),
        );
      default:
        return _ProviderConfig(
          name: provider.capitalizeFirst ?? provider,
          title: 'Sign in',
          iconAsset: AppAssets.googleIcon,
          headerColor: const Color(0xFFF8F9FA),
          titleColor: const Color(0xFF202124),
          accentColor: const Color(0xFF1A73E8),
        );
    }
  }
}

class _ProviderConfig {
  final String name;
  final String title;
  final String iconAsset;
  final Color headerColor;
  final Color titleColor;
  final Color accentColor;

  const _ProviderConfig({
    required this.name,
    required this.title,
    required this.iconAsset,
    required this.headerColor,
    required this.titleColor,
    required this.accentColor,
  });
}
