import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../core/theme/app_colors.dart';

class WalletDashboardCard extends StatefulWidget {
  final double balance;
  final bool isConnected;
  final VoidCallback onConnect;

  const WalletDashboardCard({
    Key? key,
    required this.balance,
    this.isConnected = false,
    required this.onConnect,
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
                    "Your balance",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
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
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.white70, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text("VISA",
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp)),
                  SizedBox(width: 8.w),
                  // Mastercard logo simulation
                  Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                  ),
                  Transform.translate(
                    offset: Offset(-8.w, 0),
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _isMasked
                ? "\$ ••••••••"
                : "\$${widget.balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: GoogleFonts.inter(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: widget.isConnected ? () {} : widget.onConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.isConnected ? Icons.logout : Icons.link, size: 18),
                SizedBox(width: 8.w),
                Text(
                  widget.isConnected ? "Withdraw" : "Connect Stripe",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
