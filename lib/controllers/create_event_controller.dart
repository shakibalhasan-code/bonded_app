import 'dart:convert';
import 'dart:io';
import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../core/constants/app_endpoints.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
  var selectedEndTime = Rxn<TimeOfDay>();
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

  var circleId = RxnString();
  var isLocating = false.obs;

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
      if (args['circleId'] != null) {
        circleId.value = args['circleId'];
      }
    }
    fetchSuggestedVenues();
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

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error',
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return;
      }

      isLocating.value = true;
      Position position = await Geolocator.getCurrentPosition();
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // Reverse geocoding to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}";
        locationController.text = address;
        city.value = place.locality ?? 'Dhaka';
        country.value = place.country ?? 'Bangladesh';

        // Fetch suggested venues for this location
        fetchSuggestedVenues();
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      Get.snackbar('Error', 'Failed to get current location');
    } finally {
      setLoading(false);
    }
  }

  // Suggested Venues related state
  var suggestedVenues = <Map<String, dynamic>>[].obs;
  var isLoadingVenues = false.obs;
  var selectedVenueIndex = (-1).obs;

  Future<void> fetchSuggestedVenues() async {
    try {
      isLoadingVenues.value = true;
      final token = SharedPrefsService.getString('accessToken');

      // Use current lat/lon from the controller (filled by getCurrentLocation)
      final url =
          '${AppUrls.events}/suggested-venues?lat=${latitude.value}&lon=${longitude.value}';

      final response = await _apiService.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        suggestedVenues.assignAll(
          List<Map<String, dynamic>>.from(data['data']),
        );
      }
    } catch (e) {
      debugPrint("Error fetching suggested venues: $e");
    } finally {
      isLoadingVenues.value = false;
    }
  }

  void selectVenue(int index) {
    if (index == selectedVenueIndex.value) {
      // Deselect
      selectedVenueIndex.value = -1;
      venueName.value = '';
      // Reset if needed, or keep what was typed
    } else {
      selectedVenueIndex.value = index;
      final venue = suggestedVenues[index];
      venueName.value = venue['venueName'] ?? '';
      locationController.text = venue['address'] ?? '';
      city.value = venue['city'] ?? '';
      country.value = venue['country'] ?? '';

      if (venue['location'] != null &&
          venue['location']['coordinates'] != null) {
        final coords = venue['location']['coordinates'];
        longitude.value = (coords[0] as num).toDouble();
        latitude.value = (coords[1] as num).toDouble();
      }
    }
  }

  Future<void> createEvent(BuildContext context) async {
    if (!_validateForm()) return;

    try {
      setLoading(true);

      final token = SharedPrefsService.getString('accessToken');

      // Prepare body
      String eventDate = "";
      String eventTime = "";
      if (selectedDate.value != null &&
          selectedTime.value != null &&
          selectedEndTime.value != null) {
        final d = selectedDate.value!;
        final start = selectedTime.value!;
        final end = selectedEndTime.value!;

        eventDate =
            "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

        final startH = start.hour.toString().padLeft(2, '0');
        final startM = start.minute.toString().padLeft(2, '0');
        final endH = end.hour.toString().padLeft(2, '0');
        final endM = end.minute.toString().padLeft(2, '0');

        eventTime = "$startH:$startM-$endH:$endM";
      }

      final Map<String, dynamic> body = {
        "title": nameController.text,
        "description": descriptionController.text,
        "category": selectedCategory.value ?? 'Celebrations',
        "type": isVirtual.value ? "virtual" : "in_person",
        "eventDate": eventDate,
        "eventTime": eventTime,
        "totalSeats": int.tryParse(seatsController.text) ?? 100,
        "isPaid": isPaid.value,
        "currency": "USD",
        "phoneCountryCode": selectedCountryCode.value,
        "phoneNumber": phoneController.text,
        "showPhoneToAttendees": showPhone.value,
        "facebookLink": fbController.text,
        "twitterLink": twitterController.text,
        "showSocialLinksToAttendees": showSocial.value,
      };

      if (!isVirtual.value) {
        body["city"] = city.value;
        body["country"] = country.value;
        body["venueName"] = venueName.value;
        body["address"] = locationController.text;
        body["location"] = {
          "type": "Point",
          "coordinates": [longitude.value, latitude.value],
        };
      }

      if (isPaid.value) {
        body["ticketPrice"] = double.tryParse(priceController.text) ?? 0;
      }

      if (isVirtual.value) {
        body["virtualLink"] = virtualLinkController.text;
      }

      // Create multipart request
      final url = circleId.value != null
          ? '${AppUrls.baseUrl}${AppUrls.circleEvents(circleId.value!)}'
          : '${AppUrls.baseUrl}${AppUrls.events}';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      // Add headers
      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add JSON data field
      final jsonBody = jsonEncode(body);
      request.fields['data'] = jsonBody;

      // Debug prints
      debugPrint("Creating Event...");
      debugPrint("URL: $url");
      debugPrint("Token: $token");
      debugPrint("Payload: ${const JsonEncoder.withIndent('  ').convert(body)}");

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
      
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

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
    if (selectedDate.value == null ||
        selectedTime.value == null ||
        selectedEndTime.value == null) {
      Get.snackbar('Error', 'Date, Start Time and End Time are required');
      return false;
    }
    if (coverImagePath.value.isEmpty) {
      Get.snackbar('Error', 'Cover image is required');
      return false;
    }

    if (isVirtual.value) {
      if (virtualLinkController.text.isEmpty) {
        Get.snackbar('Error', 'Virtual link is required for virtual events');
        return false;
      }
    } else {
      if (seatsController.text.isEmpty) {
        Get.snackbar('Error', 'Total seats quantity is required');
        return false;
      }
      if (locationController.text.isEmpty) {
        Get.snackbar('Error', 'Address/Location is required');
        return false;
      }
      if (latitude.value == 0 || longitude.value == 0) {
        Get.snackbar('Error', 'Please pin a location on the map');
        return false;
      }
    }
    return true;
  }
}
