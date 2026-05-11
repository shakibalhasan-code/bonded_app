import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../controllers/subscription_controller.dart';
import 'add_card_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    final List<Map<String, dynamic>> methods = [
      {
        'id': 'credit_card',
        'name': 'Credit Card / Debit Card',
        'icon': Icons.credit_card,
        'isSvg': false,
      },
      {
        'id': 'google_pay',
        'name': 'Google Pay',
        'icon': AppAssets.googleIcon,
        'isSvg': true,
      },
      {
        'id': 'apple_pay',
        'name': 'Apple Pay',
        'icon': AppAssets.appleIcon,
        'isSvg': true,
      },
      {
        'id': 'paypal',
        'name': 'Paypal',
        'icon': Icons
            .payment, // Using generic payment icon for PayPal as asset is missing
        'isSvg': false,
      },
    ];

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
          "Payment Method",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Text(
              "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed qu",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          Divider(
            color: Colors.grey[200],
            thickness: 1,
            indent: 24.w,
            endIndent: 24.w,
          ),
          SizedBox(height: 24.h),
          // Expanded(
          //   child: ListView.separated(
          //     padding: EdgeInsets.symmetric(horizontal: 24.w),
          //     itemCount: methods.length,
          //     separatorBuilder: (context, index) => SizedBox(height: 16.h),
          //     itemBuilder: (context, index) {
          //       final method = methods[index];
          //       return Obx(() {
          //         final isSelected = controller.selectedPaymentMethod.value == method['id'];
          //         return _PaymentMethodCard(
          //           id: method['id'],
          //           name: method['name'],
          //           icon: method['icon'],
          //           isSvg: method['isSvg'],
          //           isSelected: isSelected,
          //           onTap: () => controller.selectPaymentMethod(method['id']),
          //         );
          //       });
          //     },
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          //   child: GestureDetector(
          //     onTap: () {
          //       if (controller.selectedPaymentMethod.value == 'credit_card') {
          //         Get.to(() => const AddCardScreen());
          //       } else if (controller.selectedPaymentMethod.value.isNotEmpty) {
          //         // Simulate other payment flows
          //         controller.completeSubscription(context);
          //       }
          //     },
          //     child: Obx(() => Container(
          //       height: 56.h,
          //       width: double.infinity,
          //       decoration: BoxDecoration(
          //         color: controller.selectedPaymentMethod.value.isEmpty
          //           ? AppColors.primary.withOpacity(0.05)
          //           : AppColors.primary,
          //         borderRadius: BorderRadius.circular(28.r),
          //       ),
          //       alignment: Alignment.center,
          //       child: Text(
          //         "Continue",
          //         style: GoogleFonts.inter(
          //           fontSize: 16.sp,
          //           fontWeight: FontWeight.w600,
          //           color: controller.selectedPaymentMethod.value.isEmpty
          //             ? AppColors.primary.withOpacity(0.4)
          //             : Colors.white,
          //         ),
          //       ),
          //     )),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String id;
  final String name;
  final dynamic icon;
  final bool isSvg;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.id,
    required this.name,
    required this.icon,
    required this.isSvg,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              alignment: Alignment.center,
              child: isSvg
                  ? SvgPicture.asset(icon, height: 24.h)
                  : Icon(
                      icon as IconData,
                      color: AppColors.textHeading,
                      size: 28.sp,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
            ),
            _CustomRadio(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _CustomRadio extends StatelessWidget {
  final bool isSelected;

  const _CustomRadio({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.w,
      width: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: 2,
        ),
      ),
      padding: EdgeInsets.all(3.w),
      child: isSelected
          ? Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
