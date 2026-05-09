import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/kyc_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/app_button.dart';

class KycChecklistScreen extends GetView<KycController> {
  const KycChecklistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHeading),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Creator Verification",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  "Become a verified creator to unlock payouts and premium circle features. Follow these two simple steps to complete your verification.",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),

                // Step 1: Verification Fee
                _buildChecklistItem(
                  index: 1,
                  title: "Pay verification fee",
                  description: controller.feeAmount > 0 
                      ? "One-time fee: ${controller.feeCurrency} ${controller.feeAmount.toStringAsFixed(2)}" 
                      : "One-time verification fee",
                  isCompleted: controller.isFeePaid,
                  onTap: controller.isFeePaid ? null : () => controller.billingController.purchaseKycVerification(),
                  isLoading: controller.billingController.isLoading.value,
                ),

                SizedBox(height: 16.h),

                // Step 2: Stripe Connect
                _buildChecklistItem(
                  index: 2,
                  title: "Finish Stripe Connect",
                  description: "Set up your payout account to receive earnings.",
                  isCompleted: controller.isStripeComplete,
                  onTap: (!controller.isFeePaid || controller.isStripeComplete) 
                      ? null 
                      : () => controller.startStripeConnect(),
                  isEnabled: controller.isFeePaid,
                  isLoading: controller.isLoading.value || controller.isPollingStripe.value,
                ),

                SizedBox(height: 48.h),

                // Final Button
                AppButton(
                  text: controller.isStripeComplete ? "Finish" : "Continue Later",
                  isPrimary: controller.isStripeComplete,
                  onPressed: () {
                    if (controller.isStripeComplete) {
                      Get.offAllNamed(AppRoutes.PROFILE_READY);
                    } else {
                      Get.offAllNamed(AppRoutes.MAIN);
                    }
                  },
                ),
                SizedBox(height: 40.h),
              ],
            ),
          )),
    );
  }

  Widget _buildChecklistItem({
    required int index,
    required String title,
    required String description,
    required bool isCompleted,
    VoidCallback? onTap,
    bool isEnabled = true,
    bool isLoading = false,
  }) {
    final bool canInteract = isEnabled && !isCompleted && !isLoading;

    return GestureDetector(
      onTap: canInteract ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isCompleted 
              ? Colors.green.withOpacity(0.05) 
              : (isEnabled ? const Color(0xFFFAF7FF) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCompleted 
                ? Colors.green.withOpacity(0.3) 
                : (isEnabled ? AppColors.primary.withOpacity(0.3) : Colors.grey[200]!),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green 
                    : (isEnabled ? AppColors.primary : Colors.grey[300]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : (isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 24.sp)
                        : Text(
                            index.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isEnabled ? AppColors.textHeading : Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isCompleted ? "Completed" : description,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: isCompleted ? Colors.green[700] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (canInteract)
              Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16.sp),
          ],
        ),
      ),
    );
  }
}
