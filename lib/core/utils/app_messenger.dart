import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../theme/app_colors.dart';

/// Single entry point for all user-facing messages (snackbars + dialogs).
///
/// Usage:
/// ```dart
/// AppMessenger.success("Profile updated");
/// AppMessenger.error("Could not save changes");
/// AppMessenger.showError(e);            // handles ApiException → uses e.message
/// AppMessenger.errorDialog("Long…");    // modal — use for blocking errors
/// final ok = await AppMessenger.confirm("Delete this event?");
/// ```
class AppMessenger {
  AppMessenger._();

  // ── Defaults ───────────────────────────────────────────────────────────────
  static const Duration _shortDuration = Duration(seconds: 3);
  static const Duration _longDuration = Duration(seconds: 5);

  /// Messages longer than this auto-promote from snackbar to dialog so the
  /// full text is readable.
  static const int _longMessageThreshold = 140;

  // ── Snackbars ──────────────────────────────────────────────────────────────

  static void success(String message, {String? title, Duration? duration}) {
    _show(
      message: message,
      title: title ?? "Success",
      icon: Icons.check_circle_outline,
      accent: const Color(0xFF22A06B),
      duration: duration ?? _shortDuration,
    );
  }

  static void error(String message, {String? title, Duration? duration}) {
    if (message.length > _longMessageThreshold) {
      errorDialog(message, title: title);
      return;
    }
    _show(
      message: message,
      title: title ?? "Error",
      icon: Icons.error_outline,
      accent: const Color(0xFFD92D20),
      duration: duration ?? _longDuration,
    );
  }

  static void info(String message, {String? title, Duration? duration}) {
    _show(
      message: message,
      title: title ?? "Info",
      icon: Icons.info_outline,
      accent: AppColors.primary,
      duration: duration ?? _shortDuration,
    );
  }

  static void warning(String message, {String? title, Duration? duration}) {
    _show(
      message: message,
      title: title ?? "Heads up",
      icon: Icons.warning_amber_outlined,
      accent: const Color(0xFFE08D14),
      duration: duration ?? _longDuration,
    );
  }

  /// Inspects any thrown object and shows the most relevant message.
  /// Pulls `e.message` from [ApiException]; falls back to [fallback] for
  /// network/parse failures.
  static void showError(
    Object error, {
    String fallback = "Something went wrong. Please try again.",
    String? title,
  }) {
    if (error is ApiException) {
      AppMessenger.error(error.message, title: title);
      return;
    }
    AppMessenger.error(fallback, title: title);
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  static Future<void> errorDialog(
    String message, {
    String? title,
    String okText = "OK",
    VoidCallback? onOk,
  }) {
    return _alertDialog(
      title: title ?? "Error",
      message: message,
      icon: Icons.error_outline,
      accent: const Color(0xFFD92D20),
      okText: okText,
      onOk: onOk,
    );
  }

  static Future<void> successDialog(
    String message, {
    String? title,
    String okText = "OK",
    VoidCallback? onOk,
  }) {
    return _alertDialog(
      title: title ?? "Success",
      message: message,
      icon: Icons.check_circle_outline,
      accent: const Color(0xFF22A06B),
      okText: okText,
      onOk: onOk,
    );
  }

  static Future<void> infoDialog(
    String message, {
    String? title,
    String okText = "OK",
    VoidCallback? onOk,
  }) {
    return _alertDialog(
      title: title ?? "Info",
      message: message,
      icon: Icons.info_outline,
      accent: AppColors.primary,
      okText: okText,
      onOk: onOk,
    );
  }

  /// Confirmation dialog. Resolves to `true` when the user confirms, `false`
  /// when they cancel or dismiss.
  static Future<bool> confirm(
    String message, {
    String? title,
    String confirmText = "Confirm",
    String cancelText = "Cancel",
    bool destructive = false,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          title ?? "Are you sure?",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive
                  ? const Color(0xFFD92D20)
                  : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              confirmText,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  static void _show({
    required String message,
    required String title,
    required IconData icon,
    required Color accent,
    required Duration duration,
  }) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.textHeading,
      icon: Icon(icon, color: accent),
      borderRadius: 14,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      duration: duration,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      titleText: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          color: AppColors.textHeading,
          height: 1.4,
        ),
      ),
    );
  }

  static Future<void> _alertDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color accent,
    required String okText,
    VoidCallback? onOk,
  }) {
    return Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        contentPadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 32.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeading,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                onOk?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                okText,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
