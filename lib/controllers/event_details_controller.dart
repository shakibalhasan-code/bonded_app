import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../models/highlight_model.dart';
import '../services/api_service.dart';
import '../core/constants/app_endpoints.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/app_messenger.dart';
import '../core/routes/app_routes.dart';
import 'main_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../core/constants/billing_config.dart';
import '../widgets/billing/ios_payment_sheet.dart';

class EventDetailsController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxBool isLoading = false.obs;
  final RxBool isBooking = false.obs;
  final Rxn<EventModel> event = Rxn<EventModel>();

  final RxList<HighlightModel> highlights = <HighlightModel>[].obs;
  final RxBool isCreatingHighlight = false.obs;

  Future<void> fetchEventDetails(String eventId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.get("${AppUrls.events}/$eventId");
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        event.value = EventModel.fromJson(data['data']);
        fetchHighlights(eventId);
      }
    } catch (e) {
      debugPrint("Error fetching event details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setEvent(EventModel initialEvent) {
    event.value = initialEvent;
    fetchEventDetails(initialEvent.id);
  }

  Future<void> fetchHighlights(String eventId) async {
    try {
      final response = await _apiService.get(AppUrls.eventHighlights(eventId));
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> highlightsList = data['data'];
        highlights.value = highlightsList
            .map((h) => HighlightModel.fromJson(h))
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching highlights: $e");
    }
  }

  Future<bool> createHighlight({
    required String eventId,
    required String caption,
    required List<String> imagePaths,
    required List<String> videoPaths,
    List<String>? taggedAttendees,
    List<String>? taggedCircles,
    List<int>? videoDurations,
  }) async {
    try {
      isCreatingHighlight.value = true;
      
      Map<String, String> fields = {
        'caption': caption
      };

      if (taggedAttendees != null && taggedAttendees.isNotEmpty) {
        fields['taggedAttendees'] = jsonEncode(taggedAttendees);
      }
      if (taggedCircles != null && taggedCircles.isNotEmpty) {
        fields['taggedCircles'] = jsonEncode(taggedCircles);
      }
      if (videoDurations != null && videoDurations.isNotEmpty) {
        fields['videoDurationsSeconds'] = jsonEncode(videoDurations);
      }

      List<http.MultipartFile> files = [];

      for (var path in imagePaths) {
        final mimeType = lookupMimeType(path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');
        files.add(await http.MultipartFile.fromPath(
          'image',
          path,
          contentType: MediaType(mimeParts.first, mimeParts[1]),
        ));
      }
      for (var path in videoPaths) {
        final mimeType = lookupMimeType(path) ?? 'video/mp4';
        final mimeParts = mimeType.split('/');
        files.add(await http.MultipartFile.fromPath(
          'video',
          path,
          contentType: MediaType(mimeParts.first, mimeParts[1]),
        ));
      }

      final response = await _apiService.multipartRequest(
        'POST',
        AppUrls.eventHighlights(eventId),
        fields: fields,
        files: files,
      );

      final data = jsonDecode(response.body);
      debugPrint("Create highlight response: ${response.body}");
      if (data['success'] == true) {
        fetchHighlights(eventId);
        return true;
      } else {
        AppMessenger.error(data['message'] ?? "Failed to create highlight");
        return false;
      }
    } catch (e) {
      debugPrint("Error creating highlight: $e");
      AppMessenger.showError(e);
      return false;
    } finally {
      isCreatingHighlight.value = false;
    }
  }

  Future<void> bookEvent(String eventId, {Map<String, dynamic>? data}) async {
    try {
      isBooking.value = true;
      final response = await _apiService.post(AppUrls.bookEvent(eventId), data ?? {});
      final responseData = jsonDecode(response.body);

      if (responseData['success'] != true) {
        AppMessenger.error(responseData['message'] ?? "Failed to book event");
        return;
      }

      final bookingData = responseData['data'] as Map<String, dynamic>;

      if (bookingData['status'] == 'confirmed') {
        await _onBookingSuccess(eventId);
      } else if (bookingData['paymentFlow'] == 'store') {
        await _startVirtualEventPurchase(eventId, bookingData);
      } else if (bookingData['clientSecret'] != null) {
        await _startStripePayment(eventId, bookingData);
      } else {
        await _onBookingSuccess(eventId);
      }
    } catch (e) {
      debugPrint("Error booking event: $e");
      AppMessenger.showError(e);
    } finally {
      isBooking.value = false;
    }
  }

  // ── Virtual event (IAP) — demo testing sheet ───────────────────────────────
  Future<void> _startVirtualEventPurchase(
    String eventId,
    Map<String, dynamic> bookingData,
  ) async {
    final bookingId = bookingData['bookingId'];
    final platform = Platform.isAndroid ? 'google' : 'apple';
    final product = bookingData['products']?[platform];

    if (product == null || product['productId'] == null) {
      AppMessenger.error("Product configuration not found for $platform.");
      return;
    }

    final productId = product['productId'] as String;
    final displayName = product['displayName'] ?? 'Virtual Event Ticket';
    final amount = bookingData['totalAmount']?.toString() ?? '9.99';
    final currency = bookingData['currency'] ?? 'USD';

    Get.bottomSheet(
      IosPaymentSheet(
        productId: productId,
        displayName: displayName,
        price: '\$$amount $currency',
        onConfirm: () async {
          if (Get.isBottomSheetOpen ?? false) Get.back();
          await _confirmIapPurchase(
            eventId: eventId,
            bookingId: bookingId,
            platform: platform,
            productId: productId,
          );
        },
        onCancel: () {
          if (Get.isBottomSheetOpen ?? false) Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _confirmIapPurchase({
    required String eventId,
    required String bookingId,
    required String platform,
    required String productId,
  }) async {
    try {
      isBooking.value = true;
      final body = {
        'platform': platform,
        'purpose': 'virtual-event-ticket',
        'productId': productId,
        'transactionId': BillingConfig.mockTransactionId(),
        'referenceId': bookingId,
      };

      final confirmRes = await _apiService.post(AppUrls.iapConfirm, body);
      final confirmData = jsonDecode(confirmRes.body);

      if (confirmData['success'] == true) {
        await _onBookingSuccess(eventId);
      } else {
        AppMessenger.error(confirmData['message'] ?? "Failed to confirm purchase");
      }
    } catch (e) {
      debugPrint("IAP confirm error: $e");
      AppMessenger.showError(e, fallback: "Error confirming purchase. Please try again.");
    } finally {
      isBooking.value = false;
    }
  }

  // ── In-person event (Stripe) ───────────────────────────────────────────────
  Future<void> _startStripePayment(
    String eventId,
    Map<String, dynamic> bookingData,
  ) async {
    final clientSecret = bookingData['clientSecret'] as String;
    final paymentIntentId = bookingData['paymentIntentId'] as String;

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Bonded',
          style: ThemeMode.light,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      // User-dismissed sheet: stay silent, leave reservation to expire.
      if (e.error.code == FailureCode.Canceled) return;
      AppMessenger.error(
        e.error.localizedMessage ?? "Stripe payment could not be completed.",
        title: "Payment Failed",
      );
      return;
    } catch (e) {
      debugPrint("Stripe presentation error: $e");
      AppMessenger.error(
        "Unable to present payment sheet. Please try again.",
        title: "Payment Failed",
      );
      return;
    }

    await _settleStripePayment(eventId: eventId, paymentIntentId: paymentIntentId);
  }

  Future<void> _settleStripePayment({
    required String eventId,
    required String paymentIntentId,
  }) async {
    try {
      isBooking.value = true;
      final settleRes = await _apiService.post(AppUrls.settleStripe, {
        'paymentIntentId': paymentIntentId,
      });
      final settleData = jsonDecode(settleRes.body);

      if (settleData['success'] != true) {
        AppMessenger.error(settleData['message'] ?? "Payment settlement failed");
        return;
      }

      // settle status: settled | already_settled | already_paid | reservation_expired | ignored
      final status = settleData['data']?['status'] ?? 'settled';
      if (status == 'reservation_expired') {
        AppMessenger.warning(
          "Your seats were released before payment completed. Please book again.",
          title: "Reservation Expired",
        );
        return;
      }

      await _onBookingSuccess(eventId);
    } catch (e) {
      debugPrint("Stripe settle error: $e");
      // Webhook is the backend's fallback path — still treat as success-pending.
      AppMessenger.info(
        "Payment received. Finalizing your booking — please check your tickets shortly.",
        title: "Confirming…",
      );
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> _onBookingSuccess(String eventId) async {
    // Refresh event so seat counts/availability reflect the new booking.
    fetchEventDetails(eventId);
    _showSuccessDialog();
  }

  /// Close any open dialogs, return to MainWrapper, and switch the bottom-nav
  /// to the Events tab (index 4) so the user lands on their tickets/events.
  void _goToEventsTab() {
    if (Get.isDialogOpen ?? false) Get.back();
    Get.offAllNamed(AppRoutes.MAIN);
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeIndex(4);
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 48.sp),
            ),
            SizedBox(height: 20.h),
            Text(
              "Booking Confirmed",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B0B3B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Your ticket has been confirmed successfully. Enjoy your event!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _goToEventsTab,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "View My Events",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
