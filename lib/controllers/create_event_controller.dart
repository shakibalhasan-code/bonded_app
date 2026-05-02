import 'dart:convert';
import 'dart:io';
import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../core/constants/app_endpoints.dart';
import '../services/api_service.dart';
import '../services/shared_prefs_service.dart';
import 'base_controller.dart';

class CreateEventController extends BaseController {
  final ApiService _apiService = ApiService();

  // Form Fields
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final fbController = TextEditingController();
  final twitterController = TextEditingController();
  final locationController = TextEditingController();
  final seatsController = TextEditingController();
  final virtualLinkController = TextEditingController();
  final priceController = TextEditingController();

  var coverImagePath = ''.obs;
  var selectedCategory = RxnString();
  var selectedDate = Rxn<DateTime>();
  var selectedTime = Rxn<TimeOfDay>();
  var isVirtual = false.obs;
  var isPaid = false.obs;
  var showPhone = true.obs;
  var showSocial = true.obs;
  var selectedCountryCode = '+880'.obs;

  // Location Data (Mocked or from Geolocator)
  var city = 'Dhaka'.obs;
  var country = 'Bangladesh'.obs;
  var venueName = 'BICC'.obs;
  var latitude = 23.7772.obs;
  var longitude = 90.3795.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['isVirtual'] == true) {
        isVirtual.value = true;
      }
      if (args['category'] != null) {
        selectedCategory.value = args['category'];
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    fbController.dispose();
    twitterController.dispose();
    locationController.dispose();
    seatsController.dispose();
    virtualLinkController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> createEvent() async {
    if (!_validateForm()) return;

    try {
      setLoading(true);

      final token = SharedPrefsService.getString('accessToken');

      // Prepare body
      final Map<String, dynamic> body = {
        "title": nameController.text,
        "description": descriptionController.text,
        "category": selectedCategory.value ?? 'Celebrations',
        "type": isVirtual.value ? "virtual" : "in_person",
        "startsAt": _getFormattedStartsAt(),
        "totalSeats": int.tryParse(seatsController.text) ?? 100,
        "isPaid": isPaid.value,
        "phoneCountryCode": selectedCountryCode.value,
        "phoneNumber": phoneController.text,
        "showPhoneToAttendees": showPhone.value,
        "facebookLink": fbController.text,
        "twitterLink": twitterController.text,
        "showSocialLinksToAttendees": showSocial.value,
        "city": city.value,
        "country": country.value,
        "venueName": venueName.value,
        "address": locationController.text,
        "location": {
          "type": "Point",
          "coordinates": [longitude.value, latitude.value],
        },
      };

      if (isPaid.value) {
        body["ticketPrice"] = double.tryParse(priceController.text) ?? 0;
      }

      if (isVirtual.value) {
        body["virtualLink"] = virtualLinkController.text;
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppUrls.baseUrl}${AppUrls.events}'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      // Add fields (flatten the JSON or send as a field)
      // Most backends expect JSON in a field or flattened
      // But the user showed a JSON body. Usually for multipart, fields are flat.
      // If the backend expects a 'data' field with JSON string:
      // request.fields['data'] = jsonEncode(body);

      // Let's assume flat fields for top-level, and nested objects as JSON strings or flattened
      body.forEach((key, value) {
        if (value is Map || value is List) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Add image file
      if (coverImagePath.value.isNotEmpty) {
        final file = File(coverImagePath.value);
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        Get.snackbar('Success', 'Event created successfully');
        Get.offNamedUntil(AppRoutes.MAIN, (route) => false);
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to create event');
      }
    } catch (e) {
      debugPrint("Error creating event: $e");
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  }

  String _getFormattedStartsAt() {
    if (selectedDate.value == null || selectedTime.value == null) {
      return DateTime.now().toIso8601String();
    }

    final date = selectedDate.value!;
    final time = selectedTime.value!;
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return dateTime.toUtc().toIso8601String();
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Event name is required');
      return false;
    }
    if (selectedCategory.value == null) {
      Get.snackbar('Error', 'Category is required');
      return false;
    }
    if (selectedDate.value == null || selectedTime.value == null) {
      Get.snackbar('Error', 'Date and Time are required');
      return false;
    }
    if (coverImagePath.value.isEmpty) {
      Get.snackbar('Error', 'Cover image is required');
      return false;
    }
    return true;
  }
}
