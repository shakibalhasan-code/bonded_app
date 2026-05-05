import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../core/theme/app_colors.dart';

class WalletDashboardCard extends StatefulWidget {
  final WalletModel? wallet;
  final bool isConnected;
  final bool isOnboarding;
  final bool isChecking;
  final VoidCallback onConnect;
  final VoidCallback onCheckStatus;

  const WalletDashboardCard({
    Key? key,
    this.wallet,
    this.isConnected = false,
    this.isOnboarding = false,
    this.isChecking = false,
    required this.onConnect,
    required this.onCheckStatus,
  }) : super(key: key);

  @override
  State<WalletDashboardCard> createState() => _WalletDashboardCardState();
}

class _WalletDashboardCardState extends State<WalletDashboardCard> {
  bool _isMasked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E44AD), Color(0xFF7128D0)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Total Available",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => setState(() => _isMasked = !_isMasked),
                    child: Icon(
                      _isMasked
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white.withOpacity(0.5), size: 24.sp),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _isMasked
                ? "\$ ••••••••"
                : "\$${(widget.wallet?.availableBalance ?? 0.00).toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: GoogleFonts.inter(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _buildMiniBalance(
                "Pending",
                widget.wallet?.pendingBalance ?? 0.00,
                Icons.schedule_outlined,
              ),
              SizedBox(width: 24.w),
              _buildMiniBalance(
                "On-Hold",
                widget.wallet?.onHoldBalance ?? 0.00,
                Icons.lock_clock_outlined,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: widget.isOnboarding && !widget.isConnected
                ? Column(
                    key: const ValueKey('onboarding'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.isChecking)
                            SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                            Icon(Icons.info_outline,
                                color: Colors.white.withOpacity(0.8),
                                size: 16.sp),
                          SizedBox(width: 8.w),
                          Text(
                            widget.isChecking
                                ? "Verifying connection..."
                                : "Awaiting Stripe setup completion",
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed:
                            widget.isChecking ? null : widget.onCheckStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          disabledBackgroundColor:
                              Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                        ),
                        child: widget.isChecking
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Text(
                                "Check Status",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                ),
                              ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    key: const ValueKey('connected_action'),
                    onPressed: widget.isConnected ? () {} : widget.onConnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            widget.isConnected
                                ? Icons.check_circle
                                : Icons.link,
                            size: 18),
                        SizedBox(width: 8.w),
                        Text(
                          widget.isConnected
                              ? "Stripe Connected"
                              : "Connect Stripe",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBalance(String label, double amount, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 14.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          _isMasked
              ? "\$ •••"
              : "\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: transaction.isCredit 
                    ? Colors.green.withOpacity(0.12) 
                    : Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                transaction.isCredit ? Icons.south_west : Icons.north_east,
                color: transaction.isCredit ? Colors.green : Colors.red,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B0B3B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    transaction.transactionId,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${transaction.isCredit ? '+' : ''}${transaction.amount}\$",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: transaction.isCredit ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  transaction.date,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
