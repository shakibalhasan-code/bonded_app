import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../models/highlight_model.dart';
import '../services/api_service.dart';
import '../core/constants/app_endpoints.dart';
import '../core/theme/app_colors.dart';
import 'package:http/http.dart' as http;

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

  Future<void> createHighlight({
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
        files.add(await http.MultipartFile.fromPath('image', path));
      }
      for (var path in videoPaths) {
        files.add(await http.MultipartFile.fromPath('video', path));
      }

      final response = await _apiService.multipartRequest(
        'POST',
        AppUrls.eventHighlights(eventId),
        fields: fields,
        files: files,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Get.snackbar("Success", "Highlight created successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchHighlights(eventId);
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to create highlight",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error creating highlight: $e");
      Get.snackbar("Error", "Something went wrong",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isCreatingHighlight.value = false;
    }
  }

  Future<void> bookEvent(String eventId, {Map<String, dynamic>? data}) async {
    try {
      isBooking.value = true;
      final response = await _apiService.post(AppUrls.bookEvent(eventId), data ?? {});
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        _showSuccessDialog();
      } else {
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to book event",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error booking event: $e");
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isBooking.value = false;
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
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to event screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Close",
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
