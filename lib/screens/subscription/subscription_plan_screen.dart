import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/subscription_controller.dart';
import '../home/home_screen.dart';
import 'payment_method_screen.dart';

class SubscriptionPlanScreen extends StatelessWidget {
  const SubscriptionPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionController());

    final List<Map<String, dynamic>> plans = [
      {
        'name': 'Free Tier',
        'price': '0.00',
        'features': [
          'Join up to 2 circles',
          'Join 2 events per month',
          'Create free events only',
          'Create free circles only',
          'Basic filters',
          'Send 2 friend requests/day',
          'Message mutual matches',
          'View event highlights',
          'Basic visibility',
        ],
      },
      {
        'name': 'Pro Tier',
        'price': '14.99',
        'features': [
          'Join unlimited circles',
          'Create paid or free circles',
          'Create paid or free events',
          'Lower platform fee (10%)',
          'Unlimited event participation',
          'Limited advanced filters',
          'Circle & event analytics (basic)',
          'Visibility Boost (10%)',
          'Unlock full interest matching',
          'Upload premium event highlights',
          'Priority listing in circles & events',
        ],
      },
      {
        'name': 'Premium Tier',
        'price': '29.99',
        'features': [
          'Everything in Pro',
          'Platform fee reduced to 5%',
          'Premium Visibility Boost (25%)',
          'Premium event & circle analytics',
          'Verified badge',
          'Advanced persona filters',
          'Premium event badge',
          'Priority support',
        ],
      },
      {
        'name': 'Host Pro',
        'price': '29.99',
        'features': [
          'Unlimited event creation',
          'Lower platform fee (e.g. 12%)',
          'Advanced event tools',
          'Circle moderation & monetization',
          'Event analytics',
          'Priority placement',
          'Early access to Bonded features',
        ],
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
          "Subscription Plan",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeading,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Get.offAll(() => const HomeScreen()),
            child: Text(
              "Skip",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              itemCount: plans.length,
              separatorBuilder: (context, index) => SizedBox(height: 20.h),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Obx(() {
                  final isSelected = controller.selectedPlan.value == plan['name'];
                  return _SubscriptionCard(
                    name: plan['name'],
                    price: plan['price'],
                    features: List<String>.from(plan['features']),
                    isSelected: isSelected,
                    onTap: () => controller.selectPlan(plan['name']),
                  );
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
            child: GestureDetector(
              onTap: () {
                Get.to(() => const PaymentMethodScreen());
              },
              child: Container(
                height: 56.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Continue",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

class _SubscriptionCard extends StatelessWidget {
  final String name;
  final String price;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubscriptionCard({
    required this.name,
    required this.price,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24), // Spacer for radio
                      Icon(
                        Icons.workspace_premium, // Crown icon
                        color: AppColors.primary,
                        size: 32.sp,
                      ),
                      _CustomRadio(isSelected: isSelected),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeading,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "\$$price",
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: " /Month",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: features.map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, color: AppColors.primary, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
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
