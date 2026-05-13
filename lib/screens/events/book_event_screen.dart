import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/event_model.dart';
import '../../controllers/event_details_controller.dart';

class BookEventScreen extends StatefulWidget {
  const BookEventScreen({Key? key}) : super(key: key);

  @override
  State<BookEventScreen> createState() => _BookEventScreenState();
}

class _BookEventScreenState extends State<BookEventScreen> {
  int _seats = 1;
  final EventDetailsController _eventDetailsController =
      Get.find<EventDetailsController>();

  @override
  Widget build(BuildContext context) {
    final EventModel? event = Get.arguments;
    final double unitPrice = event?.price ?? 0.0;
    const double taxRate = 0.05; // 5% tax example, or 0 if not needed

    double subtotal = _seats * unitPrice;
    double tax = subtotal * taxRate;
    double total = subtotal + tax;

    final isFree = unitPrice == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Book Event",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(() {
          final busy = _eventDetailsController.isBooking.value;
          return ElevatedButton(
            onPressed: busy
                ? null
                : () {
                    if (event == null) {
                      Get.snackbar("Error", "Event details not found");
                      return;
                    }
                    _eventDetailsController.bookEvent(
                      event.id,
                      data: {'quantity': _seats},
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: busy
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isFree ? "Confirm Booking" : "Pay & Confirm",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          );
        }),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              "Secure your spot at this event! Choose the number of seats you need and proceed to confirm your booking.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            const Divider(),
            SizedBox(height: 32.h),

            Text(
              "Choose number of seats",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 24.h),

            // Seat Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCounterButton(Icons.remove, () {
                  if (_seats > 1) setState(() => _seats--);
                }),
                SizedBox(width: 32.w),
                Text(
                  _seats.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
                SizedBox(width: 32.w),
                _buildCounterButton(Icons.add, () {
                  setState(() => _seats++);
                }),
              ],
            ),
            SizedBox(height: 48.h),

            // Price Summary
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildPriceRow(
                    "Price per seat",
                    isFree ? "FREE" : "\$${unitPrice.toStringAsFixed(2)}",
                  ),
                  SizedBox(height: 16.h),
                  _buildPriceRow(
                    "$_seats Seats",
                    isFree ? "FREE" : "\$${subtotal.toStringAsFixed(2)}",
                  ),
                  if (!isFree) ...[
                    SizedBox(height: 16.h),
                    _buildPriceRow("Tax (5%)", "\$${tax.toStringAsFixed(2)}"),
                  ],
                  SizedBox(height: 16.h),
                  const Divider(),
                  SizedBox(height: 16.h),
                  _buildPriceRow(
                    "Total Amount",
                    isFree ? "FREE" : "\$${total.toStringAsFixed(2)}",
                    isTotal: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24.sp),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? const Color(0xFF1B0B3B) : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ],
    );
  }
}
