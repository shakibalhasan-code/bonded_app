import 'dart:io';

import 'package:bonded_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mock payment bottom sheet shown when [BillingConfig.useTestingMode]
/// is enabled.
///
/// Mimics Apple's subscription / IAP confirmation sheet so the UX can be
/// tested and reviewed without a real App Store connection.
class IosPaymentSheet extends StatefulWidget {
  const IosPaymentSheet({
    super.key,
    required this.productId,
    required this.displayName,
    required this.price,
    this.isSubscription = false,
    required this.onConfirm,
    required this.onCancel,
  });

  final String productId;
  final String displayName;
  final String price;
  final bool isSubscription;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  State<IosPaymentSheet> createState() => _IosPaymentSheetState();
}

class _IosPaymentSheetState extends State<IosPaymentSheet> {
  bool _processing = false;
  bool get _isIos => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7), // iOS grouped background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
              _header(),
              SizedBox(height: 12.h),
              _reviewNotice(),
              SizedBox(height: 16.h),
              _productCard(),
              SizedBox(height: 16.h),
              _debugBadge(),
              SizedBox(height: 24.h),
              _confirmButton(),
              SizedBox(height: 8.h),
              _cancelButton(),
              SizedBox(height: 16.h),
              _termsText(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Drag handle ────────────────────────────────────────────────────────────

  Widget _handle() => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
  );

  // ── App header (icon + name) ───────────────────────────────────────────────

  Widget _header() => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonded',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              _isIos ? 'App Store Purchase' : 'Google Play Purchase',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Review Notice ──────────────────────────────────────────────────────────

  Widget _reviewNotice() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.amber[50],
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.amber[200]!),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Colors.amber[800], size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            "This app is currently under review by ${_isIos ? 'Apple' : 'Google Play'} to meet their privacy policy. Use testing mode for immediate access.",
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.amber[900],
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Product card ───────────────────────────────────────────────────────────

  Widget _productCard() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              widget.isSubscription
                  ? Icons.workspace_premium
                  : Icons.shopping_bag_outlined,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.isSubscription
                      ? 'Auto-renewing subscription'
                      : 'One-time purchase',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            widget.price,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ),
  );

  // ── TEST MODE badge ────────────────────────────────────────────────────────

  Widget _debugBadge() => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: const Color(0xFF4CAF50), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.science_outlined,
          size: 14.sp,
          color: const Color(0xFF2E7D32),
        ),
        SizedBox(width: 8.w),
        Text(
          'TESTING MODE — NO REAL CHARGE',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E7D32),
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );

  // ── Confirm button ─────────────────────────────────────────────────────────

  Widget _confirmButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _processing ? null : _handleConfirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isIos ? const Color(0xFF007AFF) : AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
      ),
      child: _processing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              widget.isSubscription ? 'Subscribe Now' : 'Complete Purchase',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
    ),
  );

  // ── Cancel ─────────────────────────────────────────────────────────────────

  Widget _cancelButton() => TextButton(
    onPressed: _processing ? null : widget.onCancel,
    child: Text(
      'Cancel',
      style: GoogleFonts.inter(
        fontSize: 15.sp,
        color: Colors.grey[600],
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ── Terms ──────────────────────────────────────────────────────────────────

  Widget _termsText() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: Text(
      widget.isSubscription
          ? 'Subscription automatically renews unless cancelled in your account settings. Payment will be processed via your secure ${_isIos ? 'Apple ID' : 'Google Play'} account.'
          : 'One-time payment will be charged to your ${_isIos ? 'Apple ID' : 'Google Account'}.',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        color: Colors.grey[500],
        height: 1.5,
      ),
    ),
  );

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _handleConfirm() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    widget.onConfirm();
  }
}
